(import-macros {: setglobal! : setlocal! : augroup! : au!} :my.macros)

;; (lambda locate-data-dir [name]
;;   ;; Ensure to expand environment variable.
;;   (let [data-home (vim.fn.expand :$XDG_STATE_HOME/nvim)
;;         dir (.. data-home name)]
;;     (assert (str? dir) (.. "dir must be string, got " (type dir)))
;;     (when-not (vim.fn.isdirectory dir) ;
;;               (let [ans (vim.fn.confirm (.. "Create a new directory \"" dir
;;                                             "\"?" "&No\n&yes"))]
;;                 (if (= ans 2)
;;                     (vim.fn.mkdir dir :p)
;;                     (vim.notify :abort))))
;;     dir))

(setglobal! :undoFile true)
(setglobal! :swapFile false)
(setglobal! :writeBackup true)
;; Note: Persistent data is saved to $XDG_STATE_HOME/nvim/ by default with
;; reasonable default paths.
;; https://github.com/neovim/neovim/pull/15583
;; (setglobal! :undoDir (locate-data-dir :/undo/))
;; (setglobal! :directory (locate-data-dir :/swap//))
;; (setglobal! :backupDir (locate-data-dir :/backup//))
;; Note: 'backupskip' accepts no `{}` pattern: with them in it,
;; `E220: Missing }` will be thrown on BufWrite.
(setglobal! :backupSkip "*/tmp/*,*/.git/*,*/node_module/*")
;; (setglobal! :backupCopy "yes") ;; (default: "auto")
;; (setglobal! :backupExt "") ;; (default: "~")

(do
  (fn enable-swapfile-on-change []
    (au! :myBackupFiles/ToggleSwapfile
         [:TextChanged :TextChangedI :TextChangedP]
         [:<buffer> :once :desc "Enable swapfile on any change"]
         "silent! setlocal swapfile"))
  (fn remove-swapfile []
    (when (and vim.bo.swapfile (not vim.bo.modified))
      ;; Note: swapfile is removed when &swapfile becomes false.
      (setlocal! :swapFile false)
      (enable-swapfile-on-change)))

  (augroup! :myBackupFiles/ToggleSwapfile ;
            (au! :BufWritePost remove-swapfile)
            (au! :BufRead enable-swapfile-on-change)))

;; (augroup! :myBackupFiles/RecoverBackup
;;           (au! :BufWinEnter "*/.git/{config,hooks/*}"
;;             (setlocal! :backupskip "*/{tmp,.git,node_module}/*")))

;; (augroup! :myBackupFiles/KeepUndofilesAwayFromBufferList
;;   (au! :BufWinEnter [(: (.. vim.go.undodir "/*") :gsub "/+" "/")]
;;        [:desc "Don't add undo files to the buffer list."]
;;        "setlocal bufhidden=wipe"))
