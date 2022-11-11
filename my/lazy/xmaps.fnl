(import-macros {: xnoremap! : xmap!} :my.macros)

(xmap! :iv :vi)
(xmap! :av :va)
(xmap! :iV :Vi)
(xmap! :aV :Va)
(xmap! :i<C-v> :<C-v>i)
(xmap! :a<C-v> :<C-v>a)

;; ;; Keep visualized area after fold manipulation.
;; (xnoremap! :zo :zogv)
;; (xnoremap! :zO :zOgv)
;; (xnoremap! :zr :zrgv)
;; (xnoremap! :zR :zRgv)

;; ;; Note: All the folded lines will be selected.
;; (xnoremap! :zc :zcgv)
;; (xnoremap! :zC :zCgv)
;; (xnoremap! :zm :zmgv)
;; (xnoremap! :zM :zMgv)

;; Sort ///1
(macro xnoremap-sort! [suffix sort-flags desc]
  (assert-compile (= :string (type suffix))
                  (.. "suffix must be string, got" (type suffix)) suffix)
  (let [sort-prefix :<BSlash>s
        reverse-suffix (string.upper suffix)]
    `(do
       (xnoremap! [:desc ,desc] ,(.. sort-prefix suffix) ;
                  ,(string.format ":sort %s<CR>" sort-flags))
       ;; Define reverse sort mapping with upper-case suffix
       (xnoremap! [:desc ,(.. "Reverse " desc)]
                  ,(.. sort-prefix reverse-suffix) ;
                  ,(string.format ":sort! %s<CR>" sort-flags)))))

(xnoremap-sort! :a :u "Sort Alphabetic order")
(xnoremap-sort! :i :ui "Sort Case-Insensitive Alphabetic order")
(xnoremap-sort! :n :un "Sort on the first decimal number")
(xnoremap-sort! :f :uf "Sort on the Float")
(xnoremap-sort! :x :ux "Sort on the first hexadecimal number")
(xnoremap-sort! :o :uo "Sort on the first octal number")
(xnoremap-sort! :b :ub "Sort on the first binary number")
