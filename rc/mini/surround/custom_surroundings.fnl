;; TOML: operator.toml
;; Repo: echasnovski/mini.surround

(macro prompt [msg]
  `(let [surround# (require :mini.surround)]
     (surround#.user_input ,msg)))

(macro ts-input [opts]
  `(let [surround# (require :mini.surround)]
     (surround#.gen_spec.input.treesitter ,opts)))

{;; Help: MiniSurround.config
 ;; Help: MiniSurround.gen_spec
 ;; Help: MiniSurround-search-algorithm
 ;; Note: "input" for searching in "delete" and "replace"
 ;; Note: "output" for yielding in "add" and "replace"
 ;; Function
 :f {:input #(let [[extractor remover] (if vim.bo.lisp
                                           ["(%[^%(%)%[%]{}]+.*)"
                                            "^%(.-().*()%)$"]
                                           (= vim.bo.filetype :make)
                                           ["($%w+.*)" "^%(.-().*()%)$"]
                                           ["[%w_%.][%w_%.]+%b()"
                                            "^.-%(().*()%)$"])]
               [extractor remover])
     :output #(match (prompt "Input function name")
                name (let [left-template (if vim.bo.lisp "(%s "
                                             (= vim.bo.filetype :make) "($%s "
                                             "%s(")]
                       {:left (left-template:format name) :right ")"}))}}
