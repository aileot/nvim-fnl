;; TOML: insert.toml
;; Repo: windwp/nvim-autopairs

(local autopairs (require :nvim-autopairs))
(local Rule (require :nvim-autopairs.rule))
(local cond (require :nvim-autopairs.conds))

(autopairs.setup {:disable_filetype [:TelescopePrompt :frecency]
                  :check_ts true
                  :ts_config ; Set ts-nodes to disable in the nodes, or set `false`.
                  (comment {:lua [:string] :java false})})

(local lisps [:lisp :fennel :clojure :scheme])

;; Disable some default rules in lisp.
;; () and {} is balanced by parinfer.
(each [_ key (ipairs ["'" "`" "(" "{"])]
  (let [rule (autopairs.get_rule key)]
    (if (?. rule 1)
        ;; The first rule is default rule.
        (tset rule 1 :not_filetypes lisps)
        (tset rule :not_filetypes lisps))))

(each [_ key (ipairs ["\""])]
  (let [rule (autopairs.get_rule key)]
    (if (?. rule 1)
        (tset rule 1 :move_cond #false)
        (tset rule :move_cond #false))))

(local excluding-lisps [:-lisp :-fennel :-clojure :-scheme])
(autopairs.add_rules [(-> (Rule "<" ">" excluding-lisps)
                          ;; To insert a type to generic type like `Vector<string>`
                          (: :with_pair (cond.before_regex "%a")))])

(autopairs.add_rules (require :rc.autopairs.rules.lisp))
(autopairs.add_rules (require :rc.autopairs.rules.regex))
(autopairs.add_rules (require :rc.autopairs.rules.quotes))
(autopairs.add_rules (require :rc.autopairs.rules.vimrc))
(autopairs.add_rules (require :rc.autopairs.rules.table))
(autopairs.add_rules (require :rc.autopairs.rules.remove))
(autopairs.add_rules (require :rc.autopairs.rules.spaces))
