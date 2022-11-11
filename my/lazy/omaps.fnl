(import-macros {: onoremap! : omap! : noremap-textobj! : <Cmd>} :my.macros)

(local {: contains?} (require :my.utils))

(onoremap! :gv (<Cmd> "normal! gv"))

(omap! :iv :vi)
(omap! :av :va)
(omap! :iV :Vi)
(omap! :aV :Va)
(omap! :i<C-v> :<C-v>i)
(omap! :a<C-v> :<C-v>a)

;; Exclude the spaces outside of the quotes
(noremap-textobj! "a'" "2i'")
(noremap-textobj! "a\"" "2i\"")
(noremap-textobj! "a`" "2i`")

;; Interruptions
(onoremap! :Y :<Esc>y$)
(onoremap! :D :<Esc>D)
(onoremap! :C :<Esc>C)

;; Linewise operator
(onoremap! "{" "V{k")
(onoremap! "}" "V}k")
(onoremap! "[z" "V[z")
(onoremap! "]z" "V]z")

(onoremap! [:expr :desc "k but stuck to current line"] :k
           (fn []
             (let [operator vim.v.operator
                   exceptions [:c :d :gq :gw]
                   motion (if (contains? exceptions operator) ;
                              :k :kj)]
               (pcall vim.fn.repeat#set (.. operator motion))
               motion)))
