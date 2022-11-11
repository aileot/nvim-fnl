(import-macros {: when-not
                : ->nil
                : printf
                : join
                : executable?
                : directory?
                : mkdir
                : augroup!
                : au!
                : doautocmd!
                : feedkeys!} :my.macros)

(local {: confirm?} (require :my.utils))

(augroup! :myAugroup/KillKeyChain
  (au! :FocusLost ;
       ;; TODO: Stop Operator-pending mode on FocusLost.
       #(when (= (vim.fn.mode) :n)
          (feedkeys! :<Esc> :ni))))

(augroup! :myAugroup/ManageMultiInstance
  ;; (au! VimLeave :wshada!) ;
  (au! :FocusGained [:desc "Keep buffers up-to-date"]
       #(vim.schedule_wrap vim.cmd.checktime)))

(augroup! :myAugroup/RestoreCursor
  (au! :BufReadPost ;
       #(when (and (= vim.bo.buftype "") (not= vim.bo.filetype :git))
          (do
            (when (<= 1 (vim.fn.line "'\"") (vim.fn.line "$"))
              (vim.cmd "normal! g`\"zz"))))))

(augroup! :myAugroup/DismissUnfocusedCursorlines
  (au! :WinEnter "setlocal cursorline")
  (au! :WinLeave "setlocal nocursorline"))

(augroup! :myAugroup/SuppressNoisyListcharsInInsertmode
  (au! :InsertLeave "setlocal listchars+=trail:")
  (au! :InsertEnter "setlocal listchars-=trail:"))

;; (augroup! :myAugroup/WriteImmediatelyOnRead
;;   (au! :FileReadPre #(let [file $.file]
;;                        (when (vim.fn.filewritable file)
;;                          (vim.cmd.update file)))))

(augroup! :myAugroup/AutoWindowResize
  (au! :VimResized "wincmd ="))

(if (executable? :xdg-open)
    (augroup! :myAugroup/OpenByAnotherProgram
      (au! :BufRead ["*.{ico,icns}"] "!xdg-open %:p")
      (au! :BufRead ["*.{jpg,jpeg,png,gif}"] "!xdg-open %:p")))

(if (executable? :fcitx5-remote)
    (augroup! :myAugroup/DisableFcitx5InVim
      (au! :FocusGained #(vim.fn.system "fcitx5-remote -c")))
    (executable? :fcitx-remote)
    (augroup! :myAugroup/DisableFcitxInVim
      (au! :FocusGained #(vim.fn.system "fcitx-remote -c"))))

(augroup! :myAugroup/AutoToggleXinput
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ Touchpad"))
  (au! [:InsertEnter :TermEnter]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint"))
  (au! [:FocusLost :VimLeave]
       #(vim.fn.system "xinput disable Elan\\ TrackPoint")))

(augroup! :myAugroup/OpenQuickfix
  (au! :QuickFixCmdPost [:cexpr] "bot copen | au WinLeave <buffer> :cclose")
  (au! :QuickFixCmdPost [:lexpr] "bot lopen | au WinLeave <buffer> :lclose")
  (au! :QuickFixCmdPost [:lhelpgrep] :lwindow)
  (au! :QuickFixCmdPost [:grep :helpgrep] :cwindow))

(augroup! :myAugroup/OverrideSourceCmd
  (au! :SourceCmd [:/etc/systemd/*] "!systemctl --user daemon-reload &")
  (au! :SourceCmd [:Xmodmap] "!setxkbmap && xmodmap <afile>:p &")
  (au! :SourceCmd ["*/Xresources{,.d/*}"] "!xrdb ~/.Xresources &")
  (au! :SourceCmd [:*/i3/*] "!i3-msg restart &")
  (au! :SourceCmd [:*/polybar/*] "!$XDG_CONFIG_HOME/polybar/launch.sh &")
  (au! :SourceCmd ["*/{fcitx5,libskk}/*"] "!fcitx5-remote -r &"))

(augroup! :myAugroup/FixTypoOnWrite
  ;; Typo for `:w!`.
  (au! :BufWriteCmd [:pattern ["~" "`" :1 "@"] :nested] :w))

(augroup! :myAugroup/SuggestMkdir
  (au! :BufWritePre ;
       #(when (and (= "" vim.bo.buftype) ;
                   (not ($.file:match "^%S+://")))
          (let [dir (vim.fs.dirname $.file)]
            (when-not (directory? dir)
              (let [root (accumulate [?root nil ;
                                      path (vim.fs.parents dir) ;
                                      &until ?root]
                           (when (directory? path)
                             path))
                    msg (printf "\"%s\" misses \"%s/\". Create?" root
                                (dir:sub (+ 2 (length root))))
                    force? (= 1 vim.v.cmdbang)]
                (when (or force? (confirm? msg))
                  (mkdir dir))))))))

(augroup! :myAugroup/AutoChdirForCmdline
  (au! [:CmdLineEnter :CmdWinEnter] "silent! cd %:p:h"))

(augroup! :myAugroup/KillZombies
  (au! :VimLeavePre ;
       #(let [cmd ;; Note: To use shell pipe, the arg must be a string.
              (join " "
                    ["pgrep --runstates Z"
                     "| kill -9"
                     "&& notify-send 'nvim zombi processes are all killed'"])]
          (vim.fn.jobstart cmd))))

(do
  (lambda activate-readonly-mode []
    (when (or vim.bo.readonly (not vim.bo.modifiable))
      (require :my.lazy.readonly-mode)
      (doautocmd! :OptionSet :readonly)))
  (augroup! :myAugroup/LazyReadonlyMode
    (au! :BufWinEnter [:desc "Tell if readonly"] activate-readonly-mode)
    (au! :OptionSet [:modifiable :readonly] [:once]
         #(vim.schedule activate-readonly-mode))))

(augroup! :myAugroup/OnYank
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

(augroup! :myAugroup/Terminal/DeleteWindowsOnExit
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
