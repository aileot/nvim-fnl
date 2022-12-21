;; TOML: motion.toml
;; Repo: andymass/vim-matchup

;; Ref: $VIMRUNTIME/pack/dist/opt/matchit/plugin/matchit.vim

(import-macros {: g! : nmap! : <Cmd>} :my.macros)

(g! :loaded_matchit true)
(g! :loaded_matchparen true)

(nmap! "<BSlash>d%" "<Plug>(matchup-ds%)")
(nmap! "<BSlash>c%" "<Plug>(matchup-cs%)")
(nmap! :z<C-g> (<Cmd> :MatchupWhereAmI??))
