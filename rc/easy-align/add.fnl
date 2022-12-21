;; TOML: operator.toml
;; Repo: junegunn/vim-easy-align

(import-macros {: range-map! : range-map! : <Plug>} :my.macros)

;; Excerpt:
;; * Filter
;;   1. in interactive mode <C-f>: type g/pat/ or v/pat/
;;   2. in command-line, after :EasyAlign,
;;      put `{'filter': 'g/pat/'}`, or g/pat/ or v/pat/
;;      (just type only '/')); no need to type '\/')

;; Mnemonic: Queue up
(range-map! [:expr :remap] :<BSlash>q
            (fn []
              (pcall vim.fn.repeat#set "\\<Plug>(EasyAlign)")
              (<Plug> :EasyAlign)))

(range-map! [:remap] :<BSlash>Q (<Plug> :align-by-spaces))
(range-map! [:expr] (<Plug> :align-by-spaces)
                (fn []
                  (pcall vim.fn.repeat#set "\\<Plug>(align-by-spaces)")
                  ":EasyAlign *\\ ig[]<CR>"))
