;; TOML: shell.toml
;; Repo: hkupty/iron.nvim

(import-macros {: nmap! : <Cmd>} :my.macros)

(nmap! :<Space>rs (<Cmd> "IronRepl"))
