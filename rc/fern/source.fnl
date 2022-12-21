;; TOML: browse.toml
;; Repo: lambdalisue/fern.vim

(import-macros {: g! : setlocal! : augroup! : au! : nmap! : xmap! : <Plug>}
               :my.macros)

(g! "fern#disable_default_mappings" true)
(g! "fern#default_hidden" true)

(lambda fern-action [action ?opt]
  (: "<Plug>(fern-action-%s)" ;
     :format (if ?opt (.. action ":" ?opt) action)))

(lambda keep-cursor [str]
  "Keep cursor in Fern buffer."
  (.. str :<C-w>p))

;; Note: Suppose &shell should hardly change after loading this file.
(local save-shell vim.go.shell)
(lambda start-fish [opt]
  (.. "<Cmd>set shell=fish<CR>" ;
      (fern-action :terminal opt) ;
      "<Cmd>set shell=" save-shell :<CR>i))

(fn setup-keymaps [_au-args]
  (nmap! [:nowait :<buffer>] :g? (fern-action :help))
  (nmap! [:nowait :<buffer>] :z? (fern-action :help :all))
  (nmap! [:nowait :<buffer>] :<C-g> (fern-action :cancel))
  ;; Mnemonic: Update
  (nmap! [:nowait :<buffer>] :U (fern-action :reload :all))
  ;; Open
  (nmap! [:nowait :<buffer>] :<CR> (fern-action :open-or-enter))
  (nmap! [:nowait :<buffer>] :o (fern-action :open :below))
  (nmap! [:nowait :<buffer>] :s (fern-action :open :below))
  (nmap! [:nowait :<buffer>] :O (fern-action :open :right))
  (nmap! [:nowait :<buffer>] :gO (fern-action :open :tabedit))
  (nmap! [:nowait :<buffer>] :a (keep-cursor (fern-action :open :bottom)))
  (nmap! [:nowait :<buffer>] :A (keep-cursor (fern-action :open :rightest)))
  (nmap! [:nowait :<buffer>] :gA (.. (fern-action :open :tabedit) :gT))
  ;; Create New
  (nmap! [:nowait :<buffer>] :cd (fern-action :new-dir))
  (nmap! [:nowait :<buffer>] :cf (fern-action :new-file))
  (nmap! [:nowait :<buffer>] "%" (fern-action :new-file))
  ;; Navigation
  (nmap! [:nowait :<buffer>] :h (fern-action :leave))
  (nmap! [:nowait :<buffer>] :l (fern-action :enter))
  ;; Folder
  (nmap! [:nowait :<buffer>] :zc (fern-action :collapse))
  (nmap! [:nowait :<buffer>] :zo (fern-action :expand :in))
  (nmap! [:nowait :<buffer>] :gd (fern-action :focus :parent))
  ;; Manipulate
  (nmap! [:nowait :<buffer>] :R (fern-action :rename :below))
  (nmap! [:nowait :<buffer>] :dd (fern-action :trash))
  (nmap! [:nowait :<buffer>] :D (fern-action :remove))
  (nmap! [:nowait :<buffer>] :yy (fern-action :clipboard-copy))
  (nmap! [:nowait :<buffer>] :x (fern-action :clipboard-move))
  (nmap! [:nowait :<buffer>] :p (fern-action :clipboard-paste))
  (nmap! [:nowait :<buffer>] :Y (fern-action :yank :bufname))
  ;; Mark
  (xmap! [:nowait :<buffer>] :m (fern-action :mark :toggle))
  (nmap! [:nowait :<buffer>] :mm (fern-action :mark :toggle))
  (nmap! [:nowait :<buffer>] :m<BS> (fern-action :mark :clear))
  (nmap! [:nowait :<buffer>] :m<C-h> (fern-action :mark :clear))
  ;; Terminal
  (nmap! [:nowait :<buffer>] :<Space>te (start-fish :edit))
  (nmap! [:nowait :<buffer>] :<Space>ts (start-fish :split))
  (nmap! [:nowait :<buffer>] :<Space>tv (start-fish :vsplit))
  (nmap! [:nowait :<buffer>] :<Space>tt (start-fish :tabedit))
  ;; Misc
  (nmap! [:nowait :<buffer>] "." (fern-action :repeat))
  (nmap! [:nowait :<buffer>] :z. (fern-action :hidden :toggle))
  ;; lambdalisue/fern-mapping-git.vim
  (nmap! [:nowait :<buffer>] "<<" (<Plug> :fern-action-git-stage))
  (nmap! [:nowait :<buffer>] ">>" (<Plug> :fern-action-git-unstage)))

(fn setup-options [_au-args]
  (setlocal! :number false)
  (setlocal! :signcolumn :no))

(augroup! :rcFernSource
  (au! :FileType [:fern] `setup-options)
  (au! :FileType [:fern] `setup-keymaps))
