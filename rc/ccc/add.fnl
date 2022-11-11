;; TOML: appearance.toml
;; Repo: uga-rosa/ccc.nvim

(import-macros {: imap! : nnoremap! : <Cmd>} :my.macros)

(imap! :<C-x>c "<Plug>(ccc-insert)")

(nnoremap! :<Space>cp (<Cmd> :CccPick))
