;; TOML: motion.toml
;; Repo: ggandor/leap.nvim

(import-macros {: motion-map! : omap!} :my.macros)

(macro leap! [?opts]
  `(let [{:leap leap#} (require :leap)]
     (leap# ,(or ?opts {}))))

;; Note: `<Tab>` just after `leap()` resumes the last match.

(motion-map! "<Plug>(leap-f)" ;
             (fn []
               (motion-map! "<Plug>(leap-;)" "<Plug>(leap-f)<Tab>")
               (motion-map! "<Plug>(leap-,)" "<Plug>(leap-F)<Tab>")
               (leap!)))

(motion-map! "<Plug>(leap-F)" ;
             (fn []
               (motion-map! "<Plug>(leap-;)" "<Plug>(leap-F)<Tab>")
               (motion-map! "<Plug>(leap-,)" "<Plug>(leap-f)<Tab>")
               (leap! {:backward true})))

(motion-map! "<Plug>(leap-t)" ;
             (fn []
               (motion-map! "<Plug>(leap-;)" "<Plug>(leap-t)<Tab>")
               (motion-map! "<Plug>(leap-,)" "<Plug>(leap-T)<Tab>")
               (leap! {:offset -1})))

(motion-map! "<Plug>(leap-T)" ;
             (fn []
               (motion-map! "<Plug>(leap-;)" "<Plug>(leap-T)<Tab>")
               (motion-map! "<Plug>(leap-,)" "<Plug>(leap-t)<Tab>")
               (leap! {:backward true :offset 1})))

(omap! "<Plug>(leap-f)" ;
       (fn []
         (motion-map! "<Plug>(leap-;)" "<Plug>(leap-f)<Tab>")
         (motion-map! "<Plug>(leap-,)" "<Plug>(leap-F)<Tab>")
         (leap! {:inclusive_op true})))

(omap! "<Plug>(leap-t)" ;
       (fn []
         (motion-map! "<Plug>(leap-;)" "<Plug>(leap-t)<Tab>")
         (motion-map! "<Plug>(leap-,)" "<Plug>(leap-T)<Tab>")
         (leap!)))
