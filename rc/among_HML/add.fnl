;; TOML: motion.toml
;; Repo: aileot/vim-among_HML

(import-macros {: augroup! : au! : range-map! : motion-map!} :my.macros)

;; Jump to 1/4 of visible lines
(motion-map! :K #(vim.fn.among_HML#jump (/ 1 4)))

;; Jump to 3/4 of visible lines
(motion-map! :J #(vim.fn.among_HML#jump (/ 3 4)))

(range-map! [:desc "Run &keywordprg to the word"] :gK :K)

(range-map! [:desc "Scroll to 1/10"] :z<C-t>
            #(vim.fn.among_HML#scroll (/ 1 10)))

(range-map! [:desc "Scroll to 9/10"] :z<C-b>
            #(vim.fn.among_HML#scroll (/ 9 10)))

(augroup! :rcAmongHMLAdd
  (au! :InsertEnter [:desc "Scroll to make spaces below"]
       #(let [pumheight vim.go.pumheight
              threshold (if (< 0 pumheight) pumheight 10)
              rest-height (- (vim.fn.winheight 0) (vim.fn.winline))]
          (when (< rest-height threshold)
            (vim.fn.among_HML#scroll (/ 3 7))))))
