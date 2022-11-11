;; TOML: default_mapping.toml
;; Repo: folke/which-key.nvim

(import-macros {: nnoremap! : xnoremap! : <Cmd>} :my.macros)

;; Show all the mappings.
(nnoremap! :<C-S-Space> (<Cmd> :WhichKey))
(xnoremap! :<C-S-Space> (<Cmd> "WhichKey '' v"))
