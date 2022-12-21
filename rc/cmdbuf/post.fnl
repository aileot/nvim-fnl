;; TOML: default.toml
;; Repo: notomo/cmdbuf.nvim

(import-macros {: setlocal! : augroup! : au! : nmap! : expand} :my.macros)

(local cmdbuf (require :cmdbuf))

(fn set-cmdbuf-options! []
  (setlocal! :bufhidden :wipe))

(fn execute-and-exit! []
  (cmdbuf.execute)
  (when (-> (expand "%:p") (: :match "^cmdbuf://"))
    (vim.cmd.quit)))

(fn set-cmdbuf-mappings! []
  (nmap! [:<buffer>] ":" ":")
  (nmap! [:<buffer>] "/" "/")
  (nmap! [:<buffer>] "?" "?")
  (nmap! [:<buffer>] :dd `cmdbuf.delete)
  (nmap! [:<buffer>] :cc #(do
                            (cmdbuf.delete)
                            (vim.cmd "normal! i")))
  (nmap! [:<buffer>] :<CR> `execute-and-exit!)
  (nmap! [:<buffer>] :ZZ `execute-and-exit!))

(augroup! :rcCmdbufPost
  (au! :User [:CmdbufNew] [:desc "[cmdbuf] Set up local options"]
       #(do
          (set-cmdbuf-options!)
          (set-cmdbuf-mappings!)
          (augroup! :rcCmdbufCloseOnLeave
            (au! :WinLeave [:buffer $.buf] :quit)))))
