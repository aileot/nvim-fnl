;; TOML: memo.toml
;; Repo: mickael-menu/zk-nvim

(import-macros {: evaluate : augroup! : au! : nmap! : <Cmd>} :my.macros)

(local telescope? (pcall require :telescope))

;; Note: It also activate zk-lsp.
(-> (require :zk) ;
    (. :setup) ;
    (evaluate {:picker (when telescope?
                         :telescope)}))

(augroup! :rcZkSetup
  (au! :FileType [:markdown]
       (fn [{: buf &as a}]
         (when (a.file:find vim.env.ZK_NOTEBOOK_DIR 1 true)
           (nmap! :<CR>z<C-b>
                  [:buffer buf :desc "[zk] Show backlinks in buffer"]
                  (<Cmd> :ZkBacklinks))
           (nmap! :<CR>z<C-f> [:buffer buf :desc "[zk] Show links in buffer"]
                  (<Cmd> :ZkLinks))))))
