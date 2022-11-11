(import-macros {: augroup! : au! : setlocal! : nnoremap! : invalid-buf?}
               :my.macros)

(local {: del-augroup!} (require :my.utils))

(macro my-lsp [key ...]
  (string.format "<Cmd>%s['%s'](%s)<CR>" ;
                 "lua require'my.lsp'" key (table.concat [...] " ")))

(lambda set-keymaps [_client bufnr]
  (nnoremap! [:ex :buffer bufnr] :gd (my-lsp :definitions))
  (nnoremap! [:ex :buffer bufnr] :gD (my-lsp :declarations))
  (nnoremap! [:ex :buffer bufnr] :gr (my-lsp :references))
  (nnoremap! [:ex :buffer bufnr] :gy (my-lsp :type-definitions))
  (nnoremap! [:ex :buffer bufnr] :gY (my-lsp :implementations))
  (nnoremap! [:ex :buffer bufnr] :g<C-i> (my-lsp :incoming-calls))
  (nnoremap! [:ex :buffer bufnr] :g<C-o> (my-lsp :outgoing-calls))
  (nnoremap! [:ex :buffer bufnr] :cs (my-lsp :rename))
  (nnoremap! [:ex :buffer bufnr] "<C-]>" (my-lsp :hover))
  (nnoremap! [:ex :buffer bufnr] "g<C-]>" (my-lsp :signature-help))
  (nnoremap! [:ex :buffer bufnr] :<Space>ea (my-lsp :code-actions))
  (nnoremap! [:ex :buffer bufnr] :<Space>ex (my-lsp :document-diagnostics))
  (nnoremap! [:ex :buffer bufnr] :<Space>eX (my-lsp :workspace-diagnostics))
  (nnoremap! [:ex :buffer bufnr] :<Space>es (my-lsp :document-symbols))
  (nnoremap! [:ex :buffer bufnr] :<Space>eS (my-lsp :workspace-symbols)))

(lambda set-options [_client bufnr]
  (when (= "" vim.bo bufnr :omnifunc)
    (setlocal! :omnifunc "v:lua.vim.lsp.omnifunc")))

(local paused-clients {})
(lambda subscribe-events [_client bufnr]
  (let [id (augroup! (.. :rcLspConfig/OnAttach bufnr))]
    (au! id :OptionSet [:readonly :modifiable]
         #(if (invalid-buf? bufnr) (pcall del-augroup! id)
              (if (or (?. vim.bo bufnr :readonly)
                      (not (?. vim.bo bufnr :modifiable)))
                  (let [?clients (vim.lsp.get_active_clients {: bufnr})]
                    (when ?clients
                      (vim.lsp.stop_client ?clients)
                      (tset paused-clients bufnr ?clients)))
                  (let [?clients (. paused-clients bufnr)]
                    (when ?clients
                      (each [_ c (pairs ?clients)]
                        (vim.lsp.start_client c))
                      (tset paused-clients bufnr nil))))))))

{: set-keymaps
 : set-options
 :set-default (lambda [client bufnr]
                (set-options client bufnr)
                (set-keymaps client bufnr)
                (subscribe-events client bufnr))}
