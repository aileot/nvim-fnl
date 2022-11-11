(import-macros {: printf : nnoremap! : map-all! : setglobal! : au! : echo!} :my.macros)

(pcall #(map-all! [:unique] :<C-h> :<BS>))

;; Disable ///1
(nnoremap! :q :<Nop>)
(nnoremap! :Q :<Nop>)

(nnoremap! [:expr :desc "Toggle macro recording"] :<S-CR>
           (fn []
             ;; Note: autocmd to notify on RecordingEnter/Leave instead is useless.
             (let [register (vim.fn.reg_recording)
                   start-recording? (= "" register)
                   msg (if start-recording? "[macro] recording register:"
                           (printf "[macro] recorded to \"%s\"" register))]
               (if start-recording?
                   (do
                     (echo! msg)
                     :q)
                   (do
                     (vim.schedule #(echo! msg))
                     :q)))))

(nnoremap! [:expr :desc "Execute macro with &lazyredraw"] "@" ;
           (fn []
             ;; Note: Enable &lazyredraw only during macro execution; permanent
             ;; &lazyredraw could cause display errors.
             (setglobal! :lazyRedraw)
             (au! nil :CursorHold [:once] #(setglobal! :lazyRedraw false))
             "@"))

; omap/xmap should not move in display line.
(nnoremap! :j :gj)
(nnoremap! :k :gk)
(nnoremap! :gj :j)
(nnoremap! :gk :k)

(nnoremap! [:desc "Sync file if modified, or write"] :<Space>w
           #(if vim.bo.modified
                (vim.cmd.update)
                (vim.cmd.checktime)))

(nnoremap! [:desc "Close all the other folds"] :zU :zMzv)
