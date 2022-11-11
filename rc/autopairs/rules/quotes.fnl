(local Rule (require :nvim-autopairs.rule))
(local cond (require :nvim-autopairs.conds))

[;; Type Annotation
 (-> (Rule "\"'" "'" [:lua])
     ;; "'|'"
     (: :with_pair cond.after_text "\""))
 (-> (Rule "'\"" "\"" [:lua])
     ;; '"|"'
     (: :with_pair cond.after_text "'"))
 ;; Start comment in Vimscript
 (-> (Rule "\"" "\"" :vim)
     (: :use_key :<Space>)
     (: :with_pair (cond.after_text "\""))
     (: :replace_endpair (fn [opt]
                           (let [line opt.line
                                 preceding-chars (line:sub 1 opt.col)]
                             (if (preceding-chars:match "\"\"$") :<Del>
                                 :<Right>)))))
 ;; Escaped double quotes pair.
 (-> (Rule "\\\"" "\\\"")
     (: :with_pair #true))]
