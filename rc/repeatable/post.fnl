;; TOML: motion.toml
;; Repo: aileot/nvim-repeatable

(import-macros {: map-motion! : <Cmd>} :my.macros)

(local RepeatableMotion (require :nvim-repeatable.motion))

(local semicolon (RepeatableMotion.new [";" ","]))

;; cspell:ignore zzzv
(map-motion! [:expr] "]]" #(-> (semicolon:register ["]]zzzv" "[[zzzv"])
                               (: :init)))

(map-motion! [:expr] "]]" #(-> (semicolon:register ["[[zzzv" "]]zzzv"])
                               (: :init)))

(map-motion! [:expr] "][" #(-> (semicolon:register ["][zzzv" "[]zzzv"])
                               (: :init)))

(map-motion! [:expr] "[]" #(-> (semicolon:register ["[]zzzv" "][zzzv"])
                               (: :init)))

;; (map-motion! [:expr :desc "Jump to the next misspelled word"] "]s"
;;              #(-> (semicolon:register ["]s" "[s"])
;;                   (: :init)))

;; (map-motion! [:expr :desc "Jump to the prev misspelled word"] "[s"
;;              #(-> (semicolon:register ["[s" "]s"])
;;                   (: :init)))

(map-motion! [:expr :desc "Jump to the older in change list"] "g;"
             #(-> (semicolon:register ["g;zv" "g,zv"])
                  (: :init)))

(map-motion! [:expr :desc "Jump to the newer in change list"] "g,"
             #(-> (semicolon:register ["g,zv" "g;zv"])
                  (: :init)))

;; f/t ///1
(map-motion! [:expr] :f
             #(-> (semicolon:register ["<Plug>(leap-;)" "<Plug>(leap-,)"])
                  (: :init "<Plug>(leap-f)")))

(map-motion! [:expr] :t
             #(-> (semicolon:register ["<Plug>(leap-;)" "<Plug>(leap-,)"])
                  (: :init "<Plug>(leap-t)")))

(map-motion! [:expr] :F
             #(-> (semicolon:register ["<Plug>(leap-;)" "<Plug>(leap-,)"])
                  (: :init "<Plug>(leap-F)")))

(map-motion! [:expr] :T
             #(-> (semicolon:register ["<Plug>(leap-;)" "<Plug>(leap-,)"])
                  (: :init "<Plug>(leap-T)")))

;; Diff ///1
(map-motion! [:expr :desc "Jump to prev diff line"] "[c"
             #(let [[forward backward] ;
                    (if vim.wo.diff ["[c" "]c"]
                        (let [available? (pcall require :gitsigns)]
                          (if available?
                              ;; Note: motion function is not allowed in `expr`
                              ;; mapping.
                              [(<Cmd> "lua require'gitsigns'.prev_hunk()")
                               (<Cmd> "lua require'gitsigns'.next_hunk()")]
                              ["[c" "]c"])))]
                (-> (semicolon:register [forward backward])
                    (: :init))))

(map-motion! [:expr :desc "Jump to next diff line"] "]c"
             #(let [[forward backward] ;
                    (if vim.wo.diff ["]c" "[c"]
                        (let [available? (pcall require :gitsigns)]
                          (if available?
                              ;; Note: motion function is not allowed in `expr`
                              ;; mapping.
                              [(<Cmd> "lua require'gitsigns'.next_hunk()")
                               (<Cmd> "lua require'gitsigns'.prev_hunk()")]
                              ["]c" "[c"])))]
                (-> (semicolon:register [forward backward])
                    (: :init))))

;; Diagnostics ///1
(let [diagnostic-config {:wrap false
                         :severity {:min vim.diagnostic.severity.WARN}}]
  ;; Mnemonic: X mark to incorrect position.
  (map-motion! [:desc "Jump to prev diagnostic position"] "[x"
               #(-> (semicolon:register [#(vim.diagnostic.goto_prev diagnostic-config)
                                         #(vim.diagnostic.goto_next diagnostic-config)])
                    (: :init)))
  (map-motion! [:desc "Jump to next diagnostic position"] "]x"
               #(-> (semicolon:register [#(vim.diagnostic.goto_next diagnostic-config)
                                         #(vim.diagnostic.goto_prev diagnostic-config)])
                    (: :init))))

(let [diagnostic-config {:wrap false}]
  (map-motion! [:desc "Jump to prev diagnostic position"] "[X"
               #(-> (semicolon:register [#(vim.diagnostic.goto_prev diagnostic-config)
                                         #(vim.diagnostic.goto_next diagnostic-config)])
                    (: :init)))
  (map-motion! [:desc "Jump to next diagnostic position"] "]X"
               #(-> (semicolon:register [#(vim.diagnostic.goto_next diagnostic-config)
                                         #(vim.diagnostic.goto_prev diagnostic-config)])
                    (: :init))))
