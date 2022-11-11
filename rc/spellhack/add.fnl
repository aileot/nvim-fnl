;; TOML: insert.toml
;; Repo: aileot/vim-spellhack

(import-macros {: imap! : map-operator!} :my.macros)

(imap! :<C-x>s "<C-g>u<Plug>(spellhack-suggest)")
(imap! :<C-x><C-s> "<C-g>u<Plug>(spellhack-suggest)")
(map-operator! :gs "<Plug>(spellhack-suggest)")
