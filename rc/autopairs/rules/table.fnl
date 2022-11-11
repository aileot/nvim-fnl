;; TOML: insert.toml
;; Repo: windwp/nvim-autopairs

(local Rule (require :nvim-autopairs.rule))
(local cond (require :nvim-autopairs.conds))
(local ts-cond (require :nvim-autopairs.ts-conds))

;; Note: The provided conds/ts_conds functions return in either boolean or
;; `nil`, and nvim-autopairs regards `nil` as `true` internally; thus, you
;; should care if return value is either `false` or `not false`.
(fn in-table? [opts]
  (let [in-table [:table :field :table_constructor]]
    (and (not= false ((cond.not_after_regex ".") opts)) ts-cond
         (not= false (ts-cond.is_ts_node in-table) opts)
         (= false (ts-cond.is_ts_node [:comment]) opts))))

[(-> (Rule ": " "," [:-lua :-gitcommit :-pullrequest :-fennel :-lisp :-clojure])
     (: :with_cr #false)
     (: :with_pair in-table?))
 (-> (Rule " = " "," [:lua])
     (: :with_cr #false)
     (: :with_pair in-table?))]
