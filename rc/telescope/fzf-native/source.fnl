;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope-fzf-native.nvim

(local telescope (require :telescope))

(telescope.setup {:extensions {:fzf {:fuzzy true
                                     :override_file_sorter true
                                     :override_generic_sorter true
                                     ;; "smart_case"|"ignore_case"|"respect_case"
                                     :case_mode :smart_case}}})

(telescope.load_extension :fzf)
