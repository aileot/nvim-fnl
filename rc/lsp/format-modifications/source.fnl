;; TOML: lsp.toml
;; Repo: joechrisellis/lsp-format-modifications.nvim

(import-macros {: augroup! : au!} :my.macros)

(augroup! :rcLspFormatModificationsPost
  (au! :LspAttach
       #(match-try (?. $.data :client_id)
          id
          (vim.lsp.get_client_by_id id)
          (where client
                 (?. client :server_capabilities
                     :documentRangeFormattingProvider))
          (let [{: attach} (require :lsp-format-modifications)]
            (attach client $.buf {:format_on_save false})))))
