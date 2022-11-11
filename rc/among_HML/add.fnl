;; TOML: motion.toml
;; Repo: aileot/vim-among_HML

(import-macros {: noremap-operator! : noremap-motion!} :my.macros)

;; Jump to 1/4 of visible lines
(noremap-motion! :K #(vim.fn.among_HML#jump (/ 1 4)))

;; Jump to 3/4 of visible lines
(noremap-motion! :J #(vim.fn.among_HML#jump (/ 3 4)))

(noremap-operator! [:desc "Run &keywordprg to the word"] :gK :K)

(noremap-operator! [:desc "Scroll to 1/10"] :z<C-t>
                   #(vim.fn.among_HML#scroll (/ 1 10)))

(noremap-operator! [:desc "Scroll to 9/10"] :z<C-b>
                   #(vim.fn.among_HML#scroll (/ 9 10)))
