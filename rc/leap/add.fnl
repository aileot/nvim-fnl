;; TOML: motion.toml
;; Repo: ggandor/leap.nvim

(import-macros {: noremap-motion! : onoremap!} :my.macros)

(macro leap! [?opts]
  `(let [{:leap leap#} (require :leap)]
     (leap# ,(or ?opts {}))))

;; Note: `<CR>` just after `leap()` resumes the last match.

(noremap-motion! "<Plug>(leap-f)" ;
                 (fn []
                   (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-f)<CR>")
                   (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-F)<CR>")
                   (leap!)))

(noremap-motion! "<Plug>(leap-F)" ;
                 (fn []
                   (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-F)<CR>")
                   (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-f)<CR>")
                   (leap! {:backward true})))

(noremap-motion! "<Plug>(leap-t)" ;
                 (fn []
                   (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-t)<CR>")
                   (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-T)<CR>")
                   (leap! {:offset -1})))

(noremap-motion! "<Plug>(leap-T)" ;
                 (fn []
                   (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-T)<CR>")
                   (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-t)<CR>")
                   (leap! {:backward true :offset 1})))

(onoremap! "<Plug>(leap-f)" ;
           (fn []
             (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-f)<CR>")
             (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-F)<CR>")
             (leap! {:inclusive_op true})))

(onoremap! "<Plug>(leap-t)" ;
           (fn []
             (noremap-motion! "<Plug>(leap-;)" "<Plug>(leap-t)<CR>")
             (noremap-motion! "<Plug>(leap-,)" "<Plug>(leap-T)<CR>")
             (leap!)))
