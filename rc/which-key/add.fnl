;; TOML: default_mapping.toml
;; Repo: folke/which-key.nvim

(import-macros {: nmap! : xmap! : <Cmd>} :my.macros)

;; Show all the mappings.
(nmap! :<C-S-Space> (<Cmd> :WhichKey))
(xmap! :<C-S-Space> (<Cmd> "WhichKey '' v"))
