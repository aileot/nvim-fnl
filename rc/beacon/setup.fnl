;; TOML: appearance.toml
;; Repo: DanilaMihailov/beacon.nvim

(import-macros {: g! : hi!} :my.macros)

(hi! :Beacon {:ctermbg :Magenta :bg "#d142db"})

(g! :beacon_size 120)
(g! :beacon_shrink false)
(g! :beacon_timeout 1500)
