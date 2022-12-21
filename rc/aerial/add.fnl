;; TOML: browse.toml
;; Repo: stevearc/aerial.nvim

(import-macros {: nmap! : <Cmd>} :my.macros)

(nmap! :<Space>ei [:desc "Enumerate Indices"] (<Cmd> "AerialToggle right"))
