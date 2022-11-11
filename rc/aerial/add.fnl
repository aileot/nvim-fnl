;; TOML: browse.toml
;; Repo: stevearc/aerial.nvim

(import-macros {: nnoremap! : <Cmd>} :my.macros)

(nnoremap! :<Space>eo [:desc "Enumerate symbols in Outline"]
           (<Cmd> "AerialToggle right"))
