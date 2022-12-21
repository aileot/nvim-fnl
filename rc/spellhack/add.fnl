;; TOML: insert.toml
;; Repo: aileot/vim-spellhack

(import-macros {: imap! : range-map!} :my.macros)

(imap! [:remap] :<C-x>s "<C-g>u<Plug>(spellhack-suggest)")
(imap! [:remap] :<C-x><C-s> "<C-g>u<Plug>(spellhack-suggest)")
(range-map! [:remap] :gs "<Plug>(spellhack-suggest)")
