;; TOML: browse.toml
;; Repo: tamago324/lir-git-status.nvim

(local git-status (require :lir.git_status))

(git-status.setup {:show_ignored true})
