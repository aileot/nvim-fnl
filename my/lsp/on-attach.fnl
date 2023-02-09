(import-macros {: evaluate
                : augroup!
                : au!
                : setlocal!
                : map!
                : invalid-buf?
                : printf} :my.macros)

(local {: del-augroup! : capitalize} (require :my.utils))

(lambda set-keymaps [client-id buf]
  (fn lsp-map! [lhs method]
    (let [c (vim.lsp.get_client_by_id client-id)
          desc (printf "[lsp] %s" (capitalize method))]
      (when (c.supports_method method)
        (map! :n lhs [:desc desc :buffer buf]
              #(-> (require :my.lsp)
                   (. method)
                   (evaluate $...))))))

  (lsp-map! :gd :definition)
  (lsp-map! :gD :declaration)
  (lsp-map! :gr :references)
  (lsp-map! :gy :typeDefinition)
  (lsp-map! :gY :implementation)
  (lsp-map! :g<C-i> :incomingCalls)
  (lsp-map! :g<C-o> :outgoingCalls)
  (lsp-map! :cs :rename)
  (lsp-map! "<C-]>" :hover)
  (lsp-map! "g<C-]>" :signatureHelp)
  (lsp-map! :<Space>ea :codeAction)
  (lsp-map! :<Space>ex :documentDiagnostics)
  (lsp-map! :<Space>eX :workspaceDiagnostics)
  (lsp-map! :<Space>es :documentSymbols)
  (lsp-map! :<Space>eS :workspaceSymbols))

(lambda set-options [_client-id buf]
  (when (= "" (. vim.bo buf :omnifunc))
    (setlocal! :omnifunc "v:lua.vim.lsp.omnifunc")))

(local paused-clients {})
(lambda subscribe-events [_client-id buf]
  (let [id (augroup! (.. :myLspOnAttach buf))]
    (au! id :OptionSet [:readonly :modifiable]
         #(if (invalid-buf? buf) (pcall del-augroup! id)
              (if (or (. vim.bo buf :readonly)
                      (not (. vim.bo buf :modifiable)))
                  (match (vim.lsp.get_active_clients {: buf})
                    clients (do
                              (vim.lsp.stop_client clients)
                              (tset paused-clients buf clients)))
                  (match (?. paused-clients buf)
                    clients (do
                              (each [_ c (pairs clients)]
                                (assert c.config.cmd ;
                                        (.. "expects `config.cmd` key\ndump:\n"
                                            (vim.inspect c)))
                                (vim.lsp.start_client c.config))
                              (tset paused-clients buf nil))))))))

{: set-keymaps
 : set-options
 :set-default (lambda [client-id buf]
                (set-options client-id buf)
                (set-keymaps client-id buf)
                (subscribe-events client-id buf))}
