;; TOML: appearance.toml
;; Repo: lewis6991/satellite.nvim

(local {: setup} (require :satellite))

(setup {:current_only true
        :winblend 20
        :zindex 40
        :excluded_filetypes [""]
        :width 1
        :handlers {:search {:enable true}
                   :diagnostic {:enable true}
                   :gitsigns {:enable true}
                   :marks {:enable true :show_builtins true}}})
