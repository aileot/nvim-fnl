;; TOML: essential.toml
;; Repo: nvim-treesitter/nvim-treesitter

(import-macros {: dec : augroup! : au! : setlocal! : imap! : xmap! : <Lua>*}
               :my.macros)

(local {: contains?} (require :my.utils))

(local {: setup} (require :nvim-treesitter.configs))

(setup {;; :parser_install_dir (expand :$NVIM_CACHE_HOME/treesitter)
        :ensure_installed (require :rc.treesitter.parsers)
        :highlight {:enable true
                    :additional_vim_regex_highlighting (comment [:toml])}
        :indent {:enable true}
        :incremental_selection {:enable true
                                :keymaps (comment {;;:init_selection :<Space>v
                                                   ;;:scope_incremental :g<C-a>
                                                   :node_decremental :g<C-x>
                                                   :node_incremental :g<C-a>})}})

(lambda blockwise? []
  (-> (vim.fn.getregtype) (: :sub 1 1) (= "\022")))

(xmap! [:expr] :<C-x>
       #(if (blockwise?) :<C-x>
            (<Lua>* "require'nvim-treesitter.incremental_selection'.node_decremental()")))

(xmap! [:expr] :<C-a>
       #(if (blockwise?) :<C-a>
            (<Lua>* "require'nvim-treesitter.incremental_selection'.node_incremental()")))

(fn smart-undo-break [keys]
  "Return key sequence which breaks undo-block after `keys` if cursor is in
  such node as comment or string.
  @param keys string
  @return string"
  (let [row (dec (vim.fn.line "."))
        col-before (- (vim.fn.col ".") 2)
        in-writing? ;
        (match (pcall vim.treesitter.get_node_at_pos 0 row col-before false)
          ;; Note: It must fail in filetype where no parser is available.
          (true node-data)
          (let [node (node-data:type)
                filetype vim.bo.filetype]
            (or (contains? [:comment :string] node)
                (and (contains? [:help] filetype) (contains? [:word] node))
                (and (contains? [:markdown
                                 :pandoc
                                 :pandoc.markdown
                                 :markdown.pandoc]
                                filetype)
                     (not (contains? [:code_span
                                      :code_fence_content
                                      :indented_code_block
                                      :fenced_code_block
                                      :inline_link
                                      :link_destination]
                                     node))))))]
    (if in-writing?
        (.. keys :<C-g>u)
        keys)))

(imap! [:expr] "," #(smart-undo-break ","))
(imap! [:expr] "." #(smart-undo-break "."))
(imap! [:expr] ";" #(smart-undo-break ";"))
(imap! [:expr] ":" #(smart-undo-break ":"))
(imap! [:expr] "!" #(smart-undo-break "!"))
(imap! [:expr] "?" #(smart-undo-break "?"))

(augroup! :rcTreesitterSetFold
  (au! :FileType [:pattern (require :rc.treesitter.filetypes-to-fold)]
       (fn []
         (let [fdm vim.wo.foldexpr]
           (when (= fdm :0)
             (setlocal! :foldMethod :expr)
             (setlocal! :foldExpr "nvim_treesitter#foldexpr()"))))))
