;; TOML: lsp.toml
;; Repo: aznhe21/actions-preview.nvim

(local {: setup} (require :actions-preview))

(setup {:diff {;; Note: Action is supposed to make rather small difference.
               :algorithm :patience
               :ignore_whitespace true}
        :telescope (let [telescope (require :telescope.themes)]
                     (telescope.get_dropdown {:winblend 20
                                              :initial_mode :normal}))})
