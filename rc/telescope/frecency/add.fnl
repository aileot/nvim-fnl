;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope-frecency.nvim

(import-macros {: nil? : noremap-operator!} :my.macros)

(noremap-operator! :<Space>zf
                   (fn []
                     (when (nil? (?. package.loaded :telescope :_extensions
                                     :frecency))
                       (let [telescope (require :telescope)]
                         (telescope.load_extension :frecency)))
                     (vim.cmd.Telescope :frecency)))
