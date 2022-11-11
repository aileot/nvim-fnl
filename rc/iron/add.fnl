;; TOML: shell.toml
;; Repo: hkupty/iron.nvim

(import-macros {: nnoremap! : <Cmd>} :my.macros)

(nnoremap! :<Space>rs (<Cmd> "IronRepl"))
