(import-macros {: str->keycodes
                : nmap!
                : xmap!
                : map!
                : nmap!
                : xmap!
                : cmap!
                : range-map!} :my.macros)

;; Set blackhole register to the next operator input by prefix `<Space>`
(nmap! :<Space> "\"_")
(xmap! :<Space> "\"_")

;; (nmap! :p "p`]")
;; (nmap! :p "]p`]")
;; `P` but adjust indent to the current line.
(nmap! :P "]P")

;; Repeatable `xp`
;; TODO: Speed up
(let [repeatable-xp #(pcall vim.fn.repeat#set (str->keycodes "<Cmd>undojoin<CR>\"_xp"))]
  (nmap! [:expr] :p #(if (vim.fn.eval "@\" ==# @-")
                         (do
                           (repeatable-xp)
                           "p`]")
                         "]p`]")))

;; Replace current line with a blankline.
(nmap! :dD :0d$)

;; Yank/Put
(nmap! :Y :y$)
(range-map! :<S-Space>y "\"+y")
(range-map! :<S-Space>Y "\"+y$")

(range-map! :<S-Space>P "\"+]P")
(range-map! :<C-Space>P "\"*]P")
(nmap! :<S-Space>p "\"+]p`]")
(xmap! :<S-Space>p "\"+]p")
(nmap! :<C-Space>p "\"*]p`]")
(xmap! :<C-Space>p "\"*]p")

;; Cmap Convenience ///1
;; Note: Vim regards <C-_> as <C-/>)
(map! [:i :c :l :t] :<C-r><C-_> :<C-r>/)

(cmap! "<C-r><C-;>" "<C-r>:")
(cmap! "<C-r><C-'>" "<C-r>\"")
(cmap! "<C-r><C-\\>" "<C-r>\"")
(cmap! "<C-r>;" "<C-r>:")
(cmap! "<C-r>'" "<C-r>\"")
(cmap! "<C-r>\\" "<C-r>\"")
(cmap! :<C-r><CR> "<C-r>\"")
