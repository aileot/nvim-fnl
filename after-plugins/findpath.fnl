(import-macros {: setglobal! : setlocal! : augroup! : au!} :my.macros)

;; &path for `:find`
;; Help: |file-searching|
;; Note: ';' for upward search:
;; `/usr/share/nvim;/usr` will search in /usr, ;/usr/share, /usr/share/nvim.
;; (default: .,/usr/include,,)
;; '.': relative to the directory of the current file
;; '':  current directory); keep empty between two commas (i.e., set path+=,,)
(setglobal! :path ",,./*,../")
(setglobal! :isFname- ",")
(setglobal! :isFname+ "@-@")

;; (macro include-expr [fname]
;;   `(let [pat-env-path# "%$[^/]*"]
;;      (doto ,fname ;
;;            (: :gsub "@$" "") ;
;;            ;; (: :gsub "^\\/" "") ;
;;            (: :gsub pat-env-path# #(expand $)))))

;; (setglobal! :includeexpr "v:lua.string.gsub(v:fname)")

(augroup! :myFindPath
  (au! :FileType [:sh] #(setlocal! :path^ :/usr/bin))
  (au! :FileType [:go] #(setlocal! :path^ "$GOPATH/src/*,/usr/lib/go/src/*"))
  (au! :FileType [:python]
       #(setlocal! :path^
                   "~/.local/lib/python*/site-packages/*,/usr/lib/python*/*"))
  (au! :FileType [:dosini] #(setlocal! :suffixesadd :.conf))
  ;; Apache
  (au! [:BufNewFile :BufRead] [:*/httpd/*] #(setlocal! :path^ :/etc/httpd/*))
  (au! [:BufNewFile :BufRead] [:*/lampp/*] #(setlocal! :path^ :/etc/lampp/*))
  ;; GHQ
  (au! [:BufNewFile :BufRead] [:$GHQ_ROOT/*/*/*] `vim.fn.my#path#ghq)
  ;; Dotfiles
  (au! :TermOpen `vim.fn.my#path#vimrc)
  (au! :FileType `vim.fn.my#path#vimrc)
  (au! [:BufNewFile :BufRead] ["*/{*vim,dein}/*"] `vim.fn.my#path#vimrc)
  (au! [:BufNewFile :BufRead] ["*/{.config,dotfiles}/*"]
       `vim.fn.my#path#dotfiles))
