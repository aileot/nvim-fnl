;; TOML: appearance.toml
;; Repo: uga-rosa/ccc.nvim

(import-macros {: imap! : nmap! : <Plug> : <Cmd>} :my.macros)

(imap! [:remap] :<C-x>c (<Plug> :ccc-insert))

(nmap! :<Space>cp (<Cmd> :CccPick))
