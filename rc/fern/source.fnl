;; TOML: browse.toml
;; Repo: lambdalisue/fern.vim

(import-macros {: setlocal! : augroup! : au! : nmap! : xmap!} :my.macros)

(set vim.g.fern#disable_default_mappings true)

(lambda fern-action [action ?opt]
  (: "<Plug>(fern-action-%s)" ;
     :format (if ?opt (.. action ":" ?opt) action)))

(lambda keep-cursor [str]
  "Keep cursor in Fern buffer."
  (.. str :<C-w>p))

(fn setup-keymaps [_au-args]
  (nmap! [:nowait :<buffer> :ex] :g? (fern-action :help))
  (nmap! [:nowait :<buffer> :ex] :z? (fern-action :help :all))
  (nmap! [:nowait :<buffer> :ex] :<C-g> (fern-action :cancel))
  (nmap! [:nowait :<buffer> :ex] :R (fern-action :reload :all))
  ;; Open
  (nmap! [:nowait :<buffer> :ex] :<CR> (fern-action :open-or-enter))
  (nmap! [:nowait :<buffer> :ex] :o (fern-action :open :below))
  (nmap! [:nowait :<buffer> :ex] :s (fern-action :open :below))
  (nmap! [:nowait :<buffer> :ex] :O (fern-action :open :right))
  (nmap! [:nowait :<buffer> :ex] :gO (fern-action :open :tabedit))
  (nmap! [:nowait :<buffer> :ex] :a (keep-cursor (fern-action :open :bottom)))
  (nmap! [:nowait :<buffer> :ex] :A (keep-cursor (fern-action :open :rightest)))
  (nmap! [:nowait :<buffer> :ex] :gA (.. (fern-action :open :tabedit) :gT))
  ;; Create New
  (nmap! [:nowait :<buffer> :ex] :cd (fern-action :new-dir))
  (nmap! [:nowait :<buffer> :ex] :cf (fern-action :new-file))
  (nmap! [:nowait :<buffer> :ex] "%" (fern-action :new-file))
  ;; Navigation
  (nmap! [:nowait :<buffer> :ex] :h (fern-action :leave))
  (nmap! [:nowait :<buffer> :ex] :l (fern-action :enter))
  ;; Folder
  (nmap! [:nowait :<buffer> :ex] :zc (fern-action :collapse))
  (nmap! [:nowait :<buffer> :ex] :zo (fern-action :expand :stay))
  (nmap! [:nowait :<buffer> :ex] :gd (fern-action :focus :parent))
  ;; Manipulate
  (nmap! [:nowait :<buffer> :ex] :x (fern-action :move))
  (nmap! [:nowait :<buffer> :ex] :cc (fern-action :copy))
  (nmap! [:nowait :<buffer> :ex] :dd (fern-action :trash))
  (nmap! [:nowait :<buffer> :ex] :D (fern-action :remove))
  (nmap! [:nowait :<buffer> :ex] :yy (fern-action :clipboard-copy))
  (nmap! [:nowait :<buffer> :ex] :Y (fern-action :yank :bufname))
  ;; Mark
  (xmap! [:nowait :<buffer> :ex] :m (fern-action :mark :toggle))
  (nmap! [:nowait :<buffer> :ex] :mm (fern-action :mark :toggle))
  (nmap! [:nowait :<buffer> :ex] :m<BS> (fern-action :mark :clear))
  (nmap! [:nowait :<buffer> :ex] :m<C-h> (fern-action :mark :clear))
  ;; Misc
  (nmap! [:nowait :<buffer> :ex] "." (fern-action :repeat))
  (nmap! [:nowait :<buffer> :ex] :z. (fern-action :hidden :toggle)))

(fn setup-options [_au-args]
  (setlocal! :number false)
  (setlocal! :signcolumn :no))

(augroup! :rcFernSource ;
          (au! :FileType [:fern] setup-options)
          (au! :FileType [:fern] setup-keymaps))
