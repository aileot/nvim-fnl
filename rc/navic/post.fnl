;; TOML: lsp.toml
;; Repo: SmiteshP/nvim-navic

(import-macros {: augroup! : au!} :my.macros)

;; cspell:words navic
(local navic (require :nvim-navic))

(navic.setup)

(augroup! :rcNavicPost
          (au! :LspAttach [:desc "Attach navic to the buffer"]
               (fn [args]
                 (let [bufnr args.buf
                       ?id (?. args :data :client_id)
                       ?client (vim.lsp.get_client_by_id ?id)]
                   (when (?. ?client :server_capabilities
                             :documentSymbolProvider)
                     (navic.attach ?client bufnr))))))
