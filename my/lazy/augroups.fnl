(import-macros {: when-not
                : printf
                : executable?
                : directory?
                : evaluate
                : mkdir
                : augroup!
                : au!
                : setlocal!
                : feedkeys!} :my.macros)

(local {: confirm? : find-root : del-augroup!} (require :my.utils))

(local aug-id (augroup! :myAugroup))
(macro autocmd! [...]
  `(au! aug-id ,...))

(autocmd! :LspAttach [:desc "Set up default options and keymaps on LSP"]
          (fn [{: data &as a}]
            (match-try data
              {: client_id}
              (-> (require :my.lsp.on-attach)
                  (. :set-default)
                  (evaluate client_id a.buf)))))

(autocmd! :FocusLost [:desc "Kill keychain"]
          ;; TODO: Stop Operator-pending mode on FocusLost.
          #(when (= (vim.fn.mode) :n)
             (feedkeys! :<Esc> :ni)))

(autocmd! :BufReadPost [:desc "Restore Cursor"]
          #(when (and (= vim.bo.buftype "") (not= vim.bo.filetype :git)
                      (<= 1 (vim.fn.line "'\"") (vim.fn.line "$")))
             (vim.cmd "normal! g`\"zz")))

(autocmd! :BufWritePost [:desc "Remove trailing whitespaces"]
          ;; Note: Sometimes it's undesirable to be triggered on BufWritePre instead.
          #(let [save-view (vim.fn.winsaveview)]
             (vim.cmd "0s/\\v%^(\\n)+//e") ; Remove blank at the top.
             (vim.cmd "%s/\\v(\\n)+%$//e") ; Remove blank at the bottom.
             (match vim.bo.filetype
               :markdown (do
                           ;; Remove signle whitespaces at the end of lines.
                           (vim.cmd "%s/\\s\\@<!\\s$//e")
                           ;; Just leave two whitespaces if three or more
                           ;; there.
                           (vim.cmd "%s/\\s\\{3,}$/  /e"))
               _ (vim.cmd "%s/\\s\\+$//e"))
             (vim.fn.winrestview save-view)))

(autocmd! [:BufNewFile :BufReadPost] [:desc "Add current root to &path"]
          #(when (= "" vim.bo.buftype)
             (let [root (find-root $.file)]
               (setlocal! :path^ [root (.. root "/*") (.. root "/*/*")]))))

(autocmd! :FileReadPre [:desc "`:write %:p` on being read"]
          #(let [file $.file]
             (when (vim.fn.filewritable file)
               (vim.cmd.update file))))

(autocmd! [:VimResized :TabEnter] [:desc "Resize window"] "wincmd =")

(when (executable? :xdg-open)
  (autocmd! :BufReadPost ["*.{ico,icns,jpg,jpeg,png,gif}"]
            [:desc "Open in another program"] "!xdg-open %:p"))

;; (if (executable? :fcitx5-remote)
;;     (autocmd! :FocusGained [:desc "Disable fcitx5 in vim"]
;;               #(vim.fn.system [:fcitx5-remote :-c]))
;;     (executable? :fcitx-remote)
;;     (autocmd! :FocusGained [:desc "Disable fcitx in vim"]
;;               #(vim.fn.system [:fcitx-remote :-c])))

(autocmd! :BufWritePre [:desc "Suggest `mkdir -p`"]
          #(when (and (= "" vim.bo.buftype) ;
                      (not ($.file:match "^%S+://")))
             (let [dir (vim.fs.dirname $.match)]
               (when-not (directory? dir)
                 (let [root (accumulate [?root nil ;
                                         path (vim.fs.parents dir) ;
                                         &until ?root]
                              (when (directory? path)
                                path))
                       msg (printf "\"%s\" misses \"%s/\". Create?"
                                   (vim.fn.fnamemodify root ":~")
                                   (dir:sub (+ 2 (length root))))
                       force? (= 1 vim.v.cmdbang)]
                   (when (or force? (confirm? msg))
                     (mkdir dir)))))))

(autocmd! [:CmdLineEnter :CmdWinEnter] [:desc "cd on entering cmdline"]
          "silent! cd %:p:h")

(autocmd! :VimLeavePre [:desc "Kill zombi processes"]
          #(let [cmd ;; Note: To use shell pipe, the arg must be a string.
                 (table.concat ["pgrep --runstates Z"
                                "| kill -9"
                                "&& notify-send 'nvim zombi processes are all killed'"]
                               " ")]
             (vim.fn.jobstart cmd)))

(autocmd! :TextYankPost [:desc "Highlight on yank"]
          #(vim.highlight.on_yank {:timeout 450}))

(autocmd! :TextYankPost [:desc "Tell the last register update"]
          #(let [operator vim.v.event.operator
                 event-regname vim.v.event.regname
                 reg-name (if (and (= "\"" event-regname) (= :y operator)) :0
                              event-regname)
                 raw-reg-type vim.v.event.regtype
                 reg-type (if (raw-reg-type:match "\022") :Block
                              (match raw-reg-type
                                :v :Charater
                                :V :Line
                                _ (error (.. "unexpected regtype: "
                                             raw-reg-type))))
                 operated (match operator
                            :y :Yanked
                            :d :Deleted
                            :c :Cut
                            "" :Done
                            _ (error (.. "unexpected operator: " operator)))
                 sep " ﰲ"
                 contents (-> vim.v.event.regcontents
                              (table.concat sep)
                              (: :gsub "%s+" " "))
                 msg (-> (.. operated ;
                             " @" (if (= "" reg-name) "\"" reg-name) ;
                             " in " reg-type ": " contents)
                         (: :sub 1 vim.v.echospace))]
             (vim.notify msg)))

(autocmd! :TermClose ["term://*"] [:desc "Delete terminal windows on exit"]
          #(let [term-bufnr $.buf
                 term-win-ids (vim.fn.win_findbuf term-bufnr)]
             (each [_ id (ipairs term-win-ids)]
               ;; Note: nvim_win_close instead fails to close the last
               ;; window
               ;; Note: Trigger QuitPre a bit earlier for vim-confirm-quit
               ;; Hack: Sometimes it causes "E37: No write since last change".
               ;; Why does it happens on terminal buffer?
               ;; Ref: https://github.com/neovim/neovim/issues/7291
               (vim.fn.win_execute id
                                   "doautocmd QuitPre\nsilent! noautocmd quit!"))))

(augroup! :myAugLazyShada
  (au! [:BufWritePost :CmdlineLeave]
       [:desc "Activate shada write on particular events"]
       (fn [a]
         ;; Note: If &shada is non-empty, 'shada' is read upon startup and
         ;; written on exiting Vim.
         (autocmd! [:FocusLost] [:desc "Write shada on additional events"]
                   :wshada)
         (pcall del-augroup! a.group))))

(autocmd! :FocusGained [:desc "Keep buffers up-to-date"]
          #(vim.schedule_wrap vim.cmd.checktime))

(augroup! :myAugAutoToggleXinput
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ Touchpad"))
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint"))
  (au! [:FocusLost :VimLeave]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint")))

(augroup! :myAugOpenQuickfix
  (au! :QuickFixCmdPost [:cexpr] :copen)
  (au! :QuickFixCmdPost [:lexpr] :lopen)
  (au! :QuickFixCmdPost [:lhelpgrep] :lwindow)
  (au! :QuickFixCmdPost [:grep :helpgrep] :cwindow))

(augroup! :myAugOverrideSourceCmd
  (au! :SourceCmd [:/etc/systemd/*] "!systemctl --user daemon-reload &")
  (au! :SourceCmd [:Xmodmap] "!setxkbmap && xmodmap <afile>:p &")
  (au! :SourceCmd ["*/Xresources{,.d/*}"] "!xrdb ~/.Xresources &")
  (au! :SourceCmd [:*/i3/*] "!i3-msg restart &")
  (au! :SourceCmd [:*/polybar/*] "!$XDG_CONFIG_HOME/polybar/launch.sh &")
  (au! :SourceCmd ["*/{fcitx5,libskk}/*"] "!fcitx5-remote -r &"))

(let [;; Note: \v magic will be used
      messy-commands [:h
                      :q
                      :x
                      :w
                      :e
                      :up
                      :checktime
                      :checkhealth
                      :G?Delete
                      :G?Move]
      messy-patterns []
      total-messy-vim-patterns (icollect [_ cmd (ipairs messy-commands) ;
                                          &into messy-patterns]
                                 (.. "\\v^\\s*" cmd ">!?"))
      command-patterns-to-keep-without-args [:TSUpdate]]
  (augroup! :myAugKeepCleanHistory
    (au! [:CmdLineLeave :CmdWinLeave] [":"] [:desc "Clean up command history"]
         #(let [last-cmd (vim.fn.histget ":" -1)]
            (each [_ pattern (ipairs total-messy-vim-patterns)]
              (vim.schedule (fn []
                              (vim.fn.histdel ":" pattern))))
            (each [_ cmd (ipairs command-patterns-to-keep-without-args)]
              (let [restore-pattern (.. "^%s*(.*" cmd ")%s+%S+.*$")
                    ?new-cmd (last-cmd:match restore-pattern)]
                (vim.schedule (fn []
                                (when ?new-cmd
                                  (vim.fn.histdel ":" cmd)
                                  (vim.fn.histadd ":" (.. ?new-cmd " ")))))))))
    (au! [:CmdLineLeave :CmdWinLeave] ["[/?]"]
         [:desc "Clean up search pattern"]
         #(vim.schedule (fn []
                          (vim.fn.histdel vim.v.event.cmdtype "^.\\+$"))))))
