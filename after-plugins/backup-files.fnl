(import-macros {: set! : setlocal! : augroup! : au!} :my.macros)

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

(set! :undoFile true)
(set! :swapFile false)
(set! :writeBackup true)
;; Note: Persistent data is saved to $XDG_STATE_HOME/nvim/ by default with
;; reasonable default paths.
;; https://github.com/neovim/neovim/pull/15583
;; (set! :undoDir (locate-data-dir :/undo/))
;; (set! :directory (locate-data-dir :/swap//))
;; (set! :backupDir (locate-data-dir :/backup//))
;; Note: 'backupskip' accepts no `{}` pattern: with them in it,
;; `E220: Missing }` will be thrown on BufWrite.
(set! :backupSkip "*.log,*/tmp/*,*/.git/*,*/node_module/*")
;; (set! :backupCopy "yes") ;; (default: "auto")
;; (set! :backupExt "") ;; (default: "~")

(do
  (lambda enable-swapfile-on-change [{: group : buf}]
    (au! group [:TextChanged :TextChangedI :TextChangedP]
         [:buffer buf :once :desc "Enable swapfile on any change"]
         "silent! setlocal swapfile"))
  (let [group (augroup! :myBackupFilesToggleSwapfile)]
    (au! group :BufReadPost [:desc "Enable swapfile on change"]
         enable-swapfile-on-change)
    (au! group :BufWritePost [:desc "Remove swapfile"]
         #(when (and vim.bo.swapfile (not vim.bo.modified))
            ;; Note: swapfile is removed when &swapfile becomes false.
            (setlocal! :swapFile false)
            (enable-swapfile-on-change $)))))

;; (augroup! :myBackupFilesRecoverBackup
;;           (au! :BufWinEnter "*/.git/{config,hooks/*}"
;;             (setlocal! :backupskip "*/{tmp,.git,node_module}/*")))

;; (augroup! :myBackupFilesKeepUndofilesAwayFromBufferList
;;   (au! :BufWinEnter [(: (.. vim.go.undodir "/*") :gsub "/+" "/")]
;;        [:desc "Don't add undo files to the buffer list."]
;;        "setlocal bufhidden=wipe"))
