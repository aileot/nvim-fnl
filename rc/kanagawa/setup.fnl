;; TOML: colorschemes.toml
;; Repo: rebelot/kanagawa.nvim

(import-macros {: evaluate} :my.macros)

(-> (require :kanagawa)
    (. :setup)
    (evaluate {:dimInactive true
               ;; Get rid of default attributes other than in Comment.
               :keywordStyle {}
               :statementStyle {}
               :variablebuilinStyle {}}))
