;; TOML: telescope.toml
;; Repo: prochri/telescope-all-recent.nvim

(import-macros {: evaluate} :my.macros)

;; Note: Get the default at telescope-all-recent/default.lua.
(-> (require :telescope-all-recent)
    (. :setup)
    (evaluate {:pickers {:find_files {:sorting :recent}
                         :git_files {:sorting :recent}}}))
