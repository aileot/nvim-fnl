;; TOML: default_mapping.toml
;; Repo: yaronkh/vim-winmanip

(import-macros {: g! : nmap! : <Plug>} :my.macros)

(g! :winmanip_disable_key_mapping true)

(nmap! :<C-w>H (<Plug> :MoveWinToPrevTab))
(nmap! :<C-w>L (<Plug> :MoveWinToNextTab))
