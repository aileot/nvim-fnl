;; TOML: lsp.toml
;; Repo: aznhe21/actions-preview.nvim

(local lsp (require :my.lsp))

(set lsp.code-actions #(let [{: code_actions} (require :actions-preview)]
                         (code_actions)))

(set lsp.range-code-actions #(let [{: code_actions} (require :actions-preview)]
                               (code_actions)))
