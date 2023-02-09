;; TOML: browse.toml
;; Repo: lambdalisue/fern.vim

(import-macros {: g!
                : setlocal!
                : augroup!
                : au!
                : nmap!
                : xmap!
                : <Plug>
                : <Cmd>} :my.macros)

(g! "fern#disable_default_mappings" true)
(g! "fern#default_hidden" true)

(lambda <Fern> [action ?opt]
  (: "<Plug>(fern-action-%s)" ;
     :format (if ?opt (.. action ":" ?opt) action)))

(lambda <new>keep-cursor [str]
  "Keep cursor in Fern buffer."
  (.. str :<C-w>p))

;; Note: Suppose &shell should hardly change after loading this file.
(local save-shell vim.go.shell)
(lambda <new>start-fish [opt]
  (.. (<Cmd> "set shell=fish") ;
      (<Fern> :terminal opt) ;
      (<Cmd> (.. "set shell=" save-shell)) ;
      :i))

(fn setup-keymaps [_au-args]
  (nmap! [:nowait :<buffer>] :g? (<Fern> :help))
  (nmap! [:nowait :<buffer>] :z? (<Fern> :help :all))
  (nmap! [:nowait :<buffer>] :<C-g> (<Fern> :cancel))
  ;; Mnemonic: Update
  (nmap! [:nowait :<buffer>] :U (<Fern> :reload :all))
  ;; Open
  (nmap! [:nowait :<buffer>] :<CR> (<Fern> :open-or-enter))
  (nmap! [:nowait :<buffer>] :o (<Fern> :open :below))
  (nmap! [:nowait :<buffer>] :s (<Fern> :open :below))
  (nmap! [:nowait :<buffer>] :O (<Fern> :open :right))
  (nmap! [:nowait :<buffer>] :gO (<Fern> :open :tabedit))
  (nmap! [:nowait :<buffer>] :a (<new>keep-cursor (<Fern> :open :bottom)))
  (nmap! [:nowait :<buffer>] :A (<new>keep-cursor (<Fern> :open :rightest)))
  (nmap! [:nowait :<buffer>] :gA &vim (.. (<Fern> :open :tabedit) :gT))
  ;; Create New
  (nmap! [:nowait :<buffer>] :cd (<Fern> :new-dir))
  (nmap! [:nowait :<buffer>] :cf (<Fern> :new-file))
  (nmap! [:nowait :<buffer>] "%" (<Fern> :new-file))
  ;; Navigation
  (nmap! [:nowait :<buffer>] :h (<Fern> :leave))
  (nmap! [:nowait :<buffer>] :l (<Fern> :enter))
  ;; Folder
  (nmap! [:nowait :<buffer>] :zc (<Fern> :collapse))
  (nmap! [:nowait :<buffer>] :zo (<Fern> :expand :in))
  (nmap! [:nowait :<buffer>] :gd (<Fern> :focus :parent))
  ;; Manipulate
  (nmap! [:nowait :<buffer>] :R (<Fern> :rename :below))
  (nmap! [:nowait :<buffer>] :dd (<Fern> :trash))
  (nmap! [:nowait :<buffer>] :D (<Fern> :remove))
  (nmap! [:nowait :<buffer>] :yy (<Fern> :clipboard-copy))
  (nmap! [:nowait :<buffer>] :x (<Fern> :clipboard-move))
  (nmap! [:nowait :<buffer>] :p (<Fern> :clipboard-paste))
  (nmap! [:nowait :<buffer>] :P (<Fern> :clipboard-paste))
  (nmap! [:nowait :<buffer>] :Y (<Fern> :yank :bufname))
  ;; Mark
  (xmap! [:nowait :<buffer>] :m (<Fern> :mark :toggle))
  (nmap! [:nowait :<buffer>] :mm (<Fern> :mark :toggle))
  (nmap! [:nowait :<buffer>] :m<BS> (<Fern> :mark :clear))
  (nmap! [:nowait :<buffer>] :m<C-h> (<Fern> :mark :clear))
  ;; Terminal
  (nmap! [:nowait :<buffer>] :<Space>te (<new>start-fish :edit))
  (nmap! [:nowait :<buffer>] :<Space>ts (<new>start-fish :split))
  (nmap! [:nowait :<buffer>] :<Space>tv (<new>start-fish :vsplit))
  (nmap! [:nowait :<buffer>] :<Space>tt (<new>start-fish :tabedit))
  ;; Misc
  (nmap! [:nowait :<buffer>] "." (<Fern> :repeat))
  (nmap! [:nowait :<buffer>] :z. (<Fern> :hidden :toggle))
  ;; lambdalisue/fern-mapping-git.vim
  (nmap! [:nowait :<buffer>] "<<" (<Plug> :fern-action-git-stage))
  (nmap! [:nowait :<buffer>] ">>" (<Plug> :fern-action-git-unstage)))

(fn setup-options [_au-args]
  (setlocal! :number false)
  (setlocal! :signColumn :no))

(augroup! :rcFernSource
  (au! :FileType [:fern] setup-options)
  (au! :FileType [:fern] setup-keymaps)
  (au! :FileType [:fern-replacer]
       #(do
          (nmap! [:nowait :<buffer> :expr] :ZZ
                 ;; Note: Otherwise, fern also close fern buffer itself.
                 #(if vim.bo.modified
                      (<Cmd> :up)
                      :ZQ)))))
