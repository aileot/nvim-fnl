;; TOML: operator.toml
;; Repo: junegunn/vim-easy-align

(import-macros {: g!} :my.macros)

(g! :easy_align_delimiters
     {";" {:pattern ";" :left_margin 0 :stick_to_left true}})
