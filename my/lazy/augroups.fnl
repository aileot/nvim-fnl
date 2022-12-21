(import-macros {: when-not
                : ->nil
                : printf
                : join
                : executable?
                : directory?
                : mkdir
                : augroup!
                : au!
                : feedkeys!} :my.macros)

(local {: contains? : confirm?} (require :my.utils))

(augroup! :myAugKillKeyChain
  (au! :FocusLost ;
       ;; TODO: Stop Operator-pending mode on FocusLost.
       #(when (= (vim.fn.mode) :n)
          (feedkeys! :<Esc> :ni))))

(augroup! :myAugManageMultiInstance
  ;; (au! VimLeave :wshada!) ;
  (au! :FocusGained [:desc "Keep buffers up-to-date"]
       #(vim.schedule_wrap vim.cmd.checktime)))

(augroup! :myAugRestoreCursor
  (au! :BufReadPost #(when (and (= vim.bo.buftype "")
                                (not= vim.bo.filetype :git)
                                (<= 1 (vim.fn.line "'\"") (vim.fn.line "$")))
                       (vim.cmd "normal! g`\"zz"))))

(augroup! :myAugRemoveTrailingWhiteSpaces
  ;; Note: Sometimes it's undesirable to be triggered on BufWritePre instead.
  (au! :BufWritePost #(let [save-view (vim.fn.winsaveview)]
                        (vim.cmd "0s/\\v%^(\\n)+//e")
                        (vim.cmd "%s/\\v(\\n)+%$//e")
                        (match vim.bo.filetype
                          :markdown (do
                                      (vim.cmd "%s/\\s\\@<!\\s$//e")
                                      (vim.cmd "%s/\\s\\{3,}$/  /e"))
                          _ (vim.cmd "%s/\\s\\+$//e"))
                        (vim.fn.winrestview save-view))))

(augroup! :myAugSuppressNoisyListcharsInInsertmode
  (au! :InsertLeave "setlocal listchars+=trail:")
  (au! :InsertEnter "setlocal listchars-=trail:"))

;; (augroup! :myAugWriteImmediatelyOnRead
;;   (au! :FileReadPre #(let [file $.file]
;;                        (when (vim.fn.filewritable file)
;;                          (vim.cmd.update file)))))

(augroup! :myAugAutoWindowResize
  (au! :VimResized "wincmd ="))

(if (executable? :xdg-open)
    (augroup! :myAugOpenByAnotherProgram
      (au! :BufRead ["*.{ico,icns}"] "!xdg-open %:p")
      (au! :BufRead ["*.{jpg,jpeg,png,gif}"] "!xdg-open %:p")))

(if (executable? :fcitx5-remote)
    (augroup! :myAugDisableFcitx5InVim
      (au! :FocusGained #(vim.fn.system "fcitx5-remote -c")))
    (executable? :fcitx-remote)
    (augroup! :myAugDisableFcitxInVim
      (au! :FocusGained #(vim.fn.system "fcitx-remote -c"))))

(augroup! :myAugAutoToggleXinput
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ Touchpad"))
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint"))
  (au! [:FocusLost :VimLeave]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint")))

(augroup! :myAugOpenQuickfix
  (au! :QuickFixCmdPost [:cexpr] "bot copen | au WinLeave <buffer> :cclose")
  (au! :QuickFixCmdPost [:lexpr] "bot lopen | au WinLeave <buffer> :lclose")
  (au! :QuickFixCmdPost [:lhelpgrep] :lwindow)
  (au! :QuickFixCmdPost [:grep :helpgrep] :cwindow))

(augroup! :myAugOverrideSourceCmd
  (au! :SourceCmd [:/etc/systemd/*] "!systemctl --user daemon-reload &")
  (au! :SourceCmd [:Xmodmap] "!setxkbmap && xmodmap <afile>:p &")
  (au! :SourceCmd ["*/Xresources{,.d/*}"] "!xrdb ~/.Xresources &")
  (au! :SourceCmd [:*/i3/*] "!i3-msg restart &")
  (au! :SourceCmd [:*/polybar/*] "!$XDG_CONFIG_HOME/polybar/launch.sh &")
  (au! :SourceCmd ["*/{fcitx5,libskk}/*"] "!fcitx5-remote -r &"))

(augroup! :myAugSuggestMkdir
  (au! :BufWritePre ;
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
                  (mkdir dir))))))))

(augroup! :myAugAutoChdirForCmdline
  (au! [:CmdLineEnter :CmdWinEnter] "silent! cd %:p:h"))

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

(augroup! :myAugKillZombies
  (au! :VimLeavePre ;
       #(let [cmd ;; Note: To use shell pipe, the arg must be a string.
              (join " "
                    ["pgrep --runstates Z"
                     "| kill -9"
                     "&& notify-send 'nvim zombi processes are all killed'"])]
          (vim.fn.jobstart cmd))))

(augroup! :myAugOnYank
  (au! :TextYankPost [:desc "Highlight on yank"]
       #(->nil (pcall vim.highlight.on_yank {:timeout 450})))
  (au! :TextYankPost [:desc "Tell the last register update"]
       #(let [operator vim.v.event.operator
              event-regname vim.v.event.regname
              reg-name (if (and (= "\"" event-regname) (= :y operator)) :0
                           event-regname)
              raw-reg-type vim.v.event.regtype
              reg-type (if (raw-reg-type:match "\022") :Block
                           (match raw-reg-type
                             :v :Charater
                             :V :Line
                             _ (error (.. "unexpected regtype: " raw-reg-type))))
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
          (vim.notify msg))))

(augroup! :myAugTerminalDeleteWindowsOnExit
  (au! :TermClose ["term://*"] ;
       #(let [term-bufnr $.buf
              term-win-ids (vim.fn.win_findbuf term-bufnr)]
          (each [_ id (ipairs term-win-ids)]
            ;; Note: nvim_win_close instead fails to close the last
            ;; window
            ;; Note: Trigger QuitPre a bit earlier for vim-confirm-quit
            ;; Hack: Sometimes it causes "E37: No write since last change".
            ;; Why does it happens on terminal buffer?
            ;; Ref: https://github.com/neovim/neovim/issues/7291
            (vim.fn.win_execute id "doautocmd QuitPre\nsilent! noautocmd quit!")))))
