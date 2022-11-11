(import-macros {: str->keycodes
                : nmap!
                : xmap!
                : map!
                : nnoremap!
                : xnoremap!
                : cnoremap!
                : noremap-operator!
                : <Cmd>} :my.macros)

;; Set blackhole register to the next operator input by prefix `<Space>`
(nmap! :<Space> "\"_")
(xmap! :<Space> "\"_")

;; (nnoremap! :p "p`]")
;; (nnoremap! :p "]p`]")
;; `P` but adjust indent to the current line.
(nnoremap! :P "]P")

;; Repeatable `xp`
;; TODO: Speed up
(let [repeatable-xp #(vim.fn.repeat#set (str->keycodes "<Cmd>undojoin<CR>\"_xp"))]
  (nnoremap! [:expr] :p #(if (vim.fn.eval "@\" ==# @-")
                             (do
                               (repeatable-xp)
                               "p`]")
                             "]p`]")))

;; Replace current line with a blankline.
(nnoremap! :dD :0d$)
(nnoremap! [:expr :desc "Repeatable `dk`"] :dk
           #(.. :dk ;
                (if (= (vim.fn.line ".") (vim.fn.line "$")) ;
                    :k "") ;
                (<Cmd> "call repeat#set('dk')")))

;; Yank/Put
(nnoremap! :Y :y$)
(noremap-operator! :<S-Space>y "\"+y")
(noremap-operator! :<S-Space>Y "\"+y$")

(noremap-operator! :<S-Space>P "\"+]P")
(noremap-operator! :<C-Space>P "\"*]P")
(nnoremap! :<S-Space>p "\"+]p`]")
(xnoremap! :<S-Space>p "\"+]p")
(nnoremap! :<C-Space>p "\"*]p`]")
(xnoremap! :<C-Space>p "\"*]p")

;; Cmap Convenience ///1
;; Note: Vim regards <C-_> as <C-/>)
(map! [:i :c :l :t] :<C-r><C-_> :<C-r>/)

(cnoremap! "<C-r><C-;>" "<C-r>:")
(cnoremap! "<C-r><C-'>" "<C-r>\"")
(cnoremap! "<C-r><C-\\>" "<C-r>\"")
(cnoremap! "<C-r>;" "<C-r>:")
(cnoremap! "<C-r>'" "<C-r>\"")
(cnoremap! "<C-r>\\" "<C-r>\"")
(cnoremap! :<C-r><CR> "<C-r>\"")
