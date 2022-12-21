;; TOML: treesitter.toml
;; Repo: nvim-treesitter/nvim-treesitter-context

(local {: setup} (require :treesitter-context))

(setup {:enable true
        :max_lines 4
        ;; outer|inner
        :trim_scope :outer
        :min_window_height 15})
