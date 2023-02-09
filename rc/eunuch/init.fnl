;; TOML: shell.toml
;; Repo: tpope/vim-eunuch

(local {: git-tracking? : alias!} (require :my.utils))

(alias! :mv #(if (git-tracking?) :GMove :Move))
(alias! :vm #(if (git-tracking?) :GMove :Move))
(alias! :rm #(if (git-tracking?) :GRemove :Remove))
(alias! :cp :Copy)
