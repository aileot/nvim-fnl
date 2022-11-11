(local {: contains?} (require :my.utils))

(local Rule (require :nvim-autopairs.rule))
(local cond (require :nvim-autopairs.conds))

[(-> (Rule " " " " [:-lisp
                    :-fennel
                    :-clojure
                    :-scheme
                    :-markdown
                    :-org
                    :-text])
   (: :with_pair (fn [opts]
                   (let [{: line : col} opts
                         pair (line:sub (- col 1) col)]
                     (contains? ["()" "[]" "{}"] pair)))))
 ;; Move out brackets by close key
 (-> (Rule "( " " )")
   (: :use_key ")")
   (: :with_pair #false)
   (: :with_move (cond.after_regex ".%)")))
 (-> (Rule "{ " " }")
   (: :use_key "}")
   (: :with_pair #false)
   (: :with_move (cond.after_regex ".%}")))
 (-> (Rule "[ " " ]")
   (: :use_key "]")
   (: :with_pair #false)
   (: :with_move (cond.after_regex ".%]")))]
