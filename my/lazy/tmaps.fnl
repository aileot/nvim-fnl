(import-macros {: tmap!} :my.macros)

;; Send a space behind.
(tmap! :<S-Space> :<Space><Left>)

(tmap! :<C-CR> :<CR>)
(tmap! "<C-;>" "<Right>;")
(tmap! :<C-Space> :<Right><Space>)

(fn insert-from-register [char]
  (.. "<C-BSlash><C-n>\"" char :pi))

;; Insert the contents of a register as in Insert mode.

(tmap! [:expr] :<C-r> #(insert-from-register (vim.fn.getcharstr)))
(tmap! :<C-r><C-0> (insert-from-register :0))
(tmap! :<C-r><Space> (insert-from-register "+"))
(tmap! :<C-r><C-Space> (insert-from-register "+"))
(tmap! :<C-r><S-Space> (insert-from-register "*"))
(tmap! "<C-r>:" (insert-from-register ":"))
(tmap! "<C-r><C-;>" (insert-from-register ":"))
(tmap! "<C-r><C-:>" (insert-from-register ":"))

(macro imitate-alt-esc [key]
  (.. :<C-BSlash><C-n> key))

(tmap! [:remap] :<M-h> (imitate-alt-esc :h))
(tmap! [:remap] :<M-j> (imitate-alt-esc :j))
(tmap! [:remap] :<M-k> (imitate-alt-esc :k))
(tmap! [:remap] :<M-l> (imitate-alt-esc :l))

(tmap! [:remap] :<M-Space> (imitate-alt-esc :<Space>))
(tmap! [:remap] :<M-BSlash> (imitate-alt-esc :<BSlash>))

(tmap! [:remap] "<M-:>" (imitate-alt-esc ":"))
(tmap! [:remap] "<M-;>" (imitate-alt-esc ";"))
(tmap! [:remap] "<M-,>" (imitate-alt-esc ","))
