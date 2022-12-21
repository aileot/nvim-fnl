(import-macros {: augroup! : au! : setlocal! : nmap! : invalid-buf?} :my.macros)

(local {: del-augroup!} (require :my.utils))

(macro my-lsp [key ...]
  (string.format "<Cmd>%s['%s'](%s)<CR>" ;
                 "lua require'my.lsp'" key (table.concat [...] " ")))

(lambda set-keymaps [_client bufnr]
  (nmap! [:buffer bufnr] :gd (my-lsp :definitions))
  (nmap! [:buffer bufnr] :gD (my-lsp :declarations))
  (nmap! [:buffer bufnr] :gr (my-lsp :references))
  (nmap! [:buffer bufnr] :gy (my-lsp :type-definitions))
  (nmap! [:buffer bufnr] :gY (my-lsp :implementations))
  (nmap! [:buffer bufnr] :g<C-i> (my-lsp :incoming-calls))
  (nmap! [:buffer bufnr] :g<C-o> (my-lsp :outgoing-calls))
  (nmap! [:buffer bufnr] :cs (my-lsp :rename))
  (nmap! [:buffer bufnr] "<C-]>" (my-lsp :hover))
  (nmap! [:buffer bufnr] "g<C-]>" (my-lsp :signature-help))
  (nmap! [:buffer bufnr] :<Space>ea (my-lsp :code-actions))
  (nmap! [:buffer bufnr] :<Space>ex (my-lsp :document-diagnostics))
  (nmap! [:buffer bufnr] :<Space>eX (my-lsp :workspace-diagnostics))
  (nmap! [:buffer bufnr] :<Space>es (my-lsp :document-symbols))
  (nmap! [:buffer bufnr] :<Space>eS (my-lsp :workspace-symbols)))

(lambda set-options [_client bufnr]
  (when (= "" (. vim.bo bufnr :omnifunc))
    (setlocal! :omnifunc "v:lua.vim.lsp.omnifunc")))

(local paused-clients {})
(lambda subscribe-events [_client bufnr]
  (let [id (augroup! (.. :rcLspConfigOnAttach bufnr))]
    (au! id :OptionSet [:readonly :modifiable]
         #(if (invalid-buf? bufnr) (pcall del-augroup! id)
              (if (or (. vim.bo bufnr :readonly)
                      (not (. vim.bo bufnr :modifiable)))
                  (match (vim.lsp.get_active_clients {: bufnr})
                    clients (do
                              (vim.lsp.stop_client clients)
                              (tset paused-clients bufnr clients)))
                  (match (?. paused-clients bufnr)
                    clients (do
                              (each [_ c (pairs clients)]
                                (assert c.config.cmd ;
                                        (.. "expects `config.cmd` key\ndump:\n"
                                            (vim.inspect c)))
                                (vim.lsp.start_client c.config))
                              (tset paused-clients bufnr nil))))))))

{: set-keymaps
 : set-options
 :set-default (lambda [client bufnr]
                (set-options client bufnr)
                (set-keymaps client bufnr)
                (subscribe-events client bufnr))}
