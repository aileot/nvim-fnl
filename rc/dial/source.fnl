;; TOML: default_mapping.toml
;; Repo: monaqa/dial.nvim

(local {: augends} (require :dial.config))
(local rules (require :rc.dial.rules))

(augends:register_group rules)
