;; TOML: browse.toml
;; Repo: kana/vim-altr

(import-macros {: nmap!} :my.macros)

(nmap! "]a" "<Plug>(altr-forward)")
(nmap! "[a" "<Plug>(altr-back)")
;
(nmap! "<C-w>]a" "<C-w>s<Plug>(altr-forward)")
(nmap! "<C-w>[a" "<C-w>s<Plug>(altr-back)")
(nmap! "<C-w>]A" "<C-w>v<Plug>(altr-forward)")
(nmap! "<C-w>[A" "<C-w>v<Plug>(altr-back)")
;
(nmap! "]<C-w>a" "<C-w>s<Plug>(altr-forward)")
(nmap! "[<C-w>a" "<C-w>s<Plug>(altr-back)")
(nmap! "]<C-w>A" "<C-w>v<Plug>(altr-forward)")
(nmap! "[<C-w>A" "<C-w>v<Plug>(altr-back)")
