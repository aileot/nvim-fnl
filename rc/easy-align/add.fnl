;; TOML: operator.toml
;; Repo: junegunn/vim-easy-align

(import-macros {: map-operator! : nnoremap! : xnoremap! : <Cmd> : <C-u>}
               :my.macros)

;; Excerpt:
;; * Filter
;;   1. in interactive mode <C-f>: type g/pat/ or v/pat/
;;   2. in command-line, after :EasyAlign,
;;      put `{'filter': 'g/pat/'}`, or g/pat/ or v/pat/
;;      (just type only '/')); no need to type '\/')

;; Mnemonic: Queue up
(map-operator! [:expr] :<BSlash>q
               (fn []
                 (pcall vim.fn.repeat#set "\\<Plug>(EasyAlign)")
                 "<Plug>(EasyAlign)"))

(map-operator! :<BSlash>Q "<Plug>(align-by-spaces)")
(nnoremap! [:expr] "<Plug>(align-by-spaces)"
           (fn []
             (pcall vim.fn.repeat#set "\\<Plug>(align-by-spaces)")
             (<Cmd> "EasyAlign *\\ ig[]")))

(xnoremap! [:expr] "<Plug>(align-by-spaces)"
           (fn []
             (pcall vim.fn.repeat#set "\\<Plug>(align-by-spaces)")
             (<C-u> "*EasyAlign *\\ ig[]")))
