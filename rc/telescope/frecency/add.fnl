;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope-frecency.nvim

(import-macros {: nil? : range-map!} :my.macros)

(range-map! :<Space>zf [:desc "[telescope] Frecency"]
            #(when (nil? (?. package.loaded :telescope :_extensions :frecency))
               (let [telescope (require :telescope)]
                 (telescope.load_extension :frecency))
               (vim.cmd.Telescope :frecency)))
