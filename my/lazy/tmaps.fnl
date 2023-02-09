(import-macros {: tmap!} :my.macros)

;; Send a space behind.
(tmap! :<S-Space> :<Space><Left>)

(tmap! :<C-CR> :<CR>)
(tmap! "<C-;>" "<Right>;")
(tmap! :<C-Space> :<Right><Space>)

(fn <SID>insert-from-register [char]
  (.. "<C-BSlash><C-n>\"" char :pi))

;; Insert the contents of a register as in Insert mode.

(tmap! [:expr] :<C-r> #(<SID>insert-from-register (vim.fn.getcharstr)))
(tmap! :<C-r><C-0> (<SID>insert-from-register :0))
(tmap! :<C-r><Space> (<SID>insert-from-register "+"))
(tmap! :<C-r><C-Space> (<SID>insert-from-register "+"))
(tmap! :<C-r><S-Space> (<SID>insert-from-register "*"))
(tmap! "<C-r>:" (<SID>insert-from-register ":"))
(tmap! "<C-r><C-;>" (<SID>insert-from-register ":"))
(tmap! "<C-r><C-:>" (<SID>insert-from-register ":"))

(macro <SID>imitate-alt-esc [key]
  (.. :<C-BSlash><C-n> key))

(tmap! [:remap] :<M-h> (<SID>imitate-alt-esc :h))
(tmap! [:remap] :<M-j> (<SID>imitate-alt-esc :j))
(tmap! [:remap] :<M-k> (<SID>imitate-alt-esc :k))
(tmap! [:remap] :<M-l> (<SID>imitate-alt-esc :l))

(tmap! [:remap] :<M-Space> (<SID>imitate-alt-esc :<Space>))
(tmap! [:remap] :<M-BSlash> (<SID>imitate-alt-esc :<BSlash>))

(tmap! [:remap] "<M-:>" (<SID>imitate-alt-esc ":"))
(tmap! [:remap] "<M-;>" (<SID>imitate-alt-esc ";"))
(tmap! [:remap] "<M-,>" (<SID>imitate-alt-esc ","))
