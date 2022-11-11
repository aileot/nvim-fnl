;; TOML: insert.toml
;; Repo: windwp/nvim-autopairs

(local Rule (require :nvim-autopairs.rule))
(local cond (require :nvim-autopairs.conds))
(local ts-cond (require :nvim-autopairs.ts-conds))

(local lisps [:lisp :fennel :clojure :scheme])

;; All the rules are supposed to work with parinfer.

[(-> (Rule "*" "*" [:lisp])
     (: :with_pair (cond.not_before_regex "%S")))
 (-> (Rule "`" "`" lisps)
     (: :with_pair (ts-cond.is_ts_node [:comment :string])))
 ;; Note: Balance pair where parinfer doesn't work.
 (-> (Rule "(" ")" lisps)
     (: :with_pair (ts-cond.is_ts_node [:comment :string])))
 (-> (Rule "{" "}" lisps)
     (: :with_pair (ts-cond.is_ts_node [:comment :string])))]
