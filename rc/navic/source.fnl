;; TOML: lsp.toml
;; Repo: SmiteshP/nvim-navic

(import-macros {: augroup! : au!} :my.macros)

;; cspell:words navic

(local navic (require :nvim-navic))

(navic.setup)

(augroup! :rcNavicPost
  (au! :LspAttach [:desc "Attach navic to the buffer"]
       #(let [bufnr $.buf
              ?id (?. $.data :client_id)
              (ok? ?client) (vim.lsp.get_client_by_id ?id)]
          (when (and ok? (?. ?client :server_capabilities
                             :documentSymbolProvider))
            (navic.attach ?client bufnr)))))
