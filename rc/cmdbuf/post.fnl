;; TOML: default.toml
;; Repo: notomo/cmdbuf.nvim

(import-macros {: setlocal! : augroup! : au! : nnoremap! : expand} :my.macros)

(local cmdbuf (require :cmdbuf))

(fn set-cmdbuf-options! []
  (setlocal! :bufhidden :wipe)
  (augroup! :rcCmdbufCloseOnLeave
    (au! :WinLeave [:<buffer>] :quit)))

(fn execute-and-exit! []
  (cmdbuf.execute)
  (when (-> (expand "%:p") (: :match "^cmdbuf://"))
    (vim.cmd.quit)))

(fn set-cmdbuf-mappings! []
  (nnoremap! [:<buffer>] ":" ":")
  (nnoremap! [:<buffer>] "/" "/")
  (nnoremap! [:<buffer>] "?" "?")
  (nnoremap! [:<buffer>] :dd cmdbuf.delete)
  (nnoremap! [:<buffer>] :cc
             #(do
                (cmdbuf.delete)
                (vim.cmd "normal! i")))
  (nnoremap! [:<buffer>] :<CR> execute-and-exit!)
  (nnoremap! [:<buffer>] :ZZ execute-and-exit!))

(augroup! :rcCmdbufSetupOnEntry
  (au! :User [:CmdbufNew] #(do
                             (set-cmdbuf-options!)
                             (set-cmdbuf-mappings!))))
