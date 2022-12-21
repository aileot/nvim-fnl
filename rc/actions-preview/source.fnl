;; TOML: lsp.toml
;; Repo: aznhe21/actions-preview.nvim

(local {: setup} (require :actions-preview))

(local lsp (require :my.lsp))

(set lsp.code-actions #(let [{: code_actions} (require :actions-preview)]
                         (code_actions)))

(set lsp.range-code-actions #(let [{: code_actions} (require :actions-preview)]
                               (code_actions)))

(setup {:diff {;; Note: Action is supposed to make rather small difference.
               :algorithm :patience
               :ignore_whitespace true}
        :telescope (let [telescope (require :telescope.themes)]
                     (telescope.get_dropdown {:winblend 20
                                              :initial_mode :normal}))})
