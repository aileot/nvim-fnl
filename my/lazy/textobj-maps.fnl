(import-macros {: omap! : xmap! : textobj-map! : <Cmd>} :my.macros)

(omap! :gv (<Cmd> "normal! gv"))

(textobj-map! :iv :vi)
(textobj-map! :av :va)
(textobj-map! :iV :Vi)
(textobj-map! :aV :Va)
(textobj-map! :i<C-v> :<C-v>i)
(textobj-map! :a<C-v> :<C-v>a)

;; Exclude the spaces outside of the quotes
(textobj-map! "a'" "2i'")
(textobj-map! "a\"" "2i\"")
(textobj-map! "a`" "2i`")

;; Select current line Without <NL>.
;; Ref: https://neovim.discourse.group/t/autocmd-to-keep-cursor-position-on-yank/2982/3
(omap! "<Plug>(textobj-line-0)" (<Cmd> "normal! 0v$"))
(omap! "<Plug>(textobj-line-^)" (<Cmd> "normal! _vg_"))
(xmap! "<Plug>(textobj-line-0)" [:silent] ":normal! 0v$<CR>")
(xmap! "<Plug>(textobj-line-^)" [:silent] ":normal! _vg_<CR>")

;; Interruptions
(omap! :Y :<Esc>y$)
(omap! :D :<Esc>D)
(omap! :C :<Esc>C)

;; ;; Keep visualized area after fold manipulation.
;; (xmap! :zo :zogv)
;; (xmap! :zO :zOgv)
;; (xmap! :zr :zrgv)
;; (xmap! :zR :zRgv)

;; ;; Note: All the folded lines will be selected.
;; (xmap! :zc :zcgv)
;; (xmap! :zC :zCgv)
;; (xmap! :zm :zmgv)
;; (xmap! :zM :zMgv)

;; To extend visualized area in another window.
(xmap! :<M-h> :<Esc><C-w>hgvo)
(xmap! :<M-j> :<Esc><C-w>jgvo)
(xmap! :<M-k> :<Esc><C-w>kgvo)
(xmap! :<M-l> :<Esc><C-w>lgvo)

;; Sort ///1
(macro xmap-sort! [suffix sort-flags desc]
  (assert-compile (= :string (type suffix))
                  (.. "suffix must be string, got" (type suffix)) suffix)
  (let [sort-prefix :<BSlash>s
        reverse-suffix (string.upper suffix)]
    `(do
       (xmap! ,(.. sort-prefix suffix) [:desc ,desc]
              ,(string.format ":sort %s<CR>" sort-flags))
       ;; Define reverse sort mapping with upper-case suffix
       (xmap! ,(.. sort-prefix reverse-suffix) [:desc ,(.. "Reverse " desc)]
              ,(string.format ":sort! %s<CR>" sort-flags)))))

(xmap-sort! :a :u "Sort Alphabetic order")
(xmap-sort! :i :ui "Sort Case-Insensitive Alphabetic order")
(xmap-sort! :n :un "Sort on the first decimal number")
(xmap-sort! :f :uf "Sort on the Float")
(xmap-sort! :x :ux "Sort on the first hexadecimal number")
(xmap-sort! :o :uo "Sort on the first octal number")
(xmap-sort! :b :ub "Sort on the first binary number")
