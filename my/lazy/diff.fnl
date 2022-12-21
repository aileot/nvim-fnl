(import-macros {: printf : augroup! : au! : set! : nmap! : has?} :my.macros)
;; cspell:ignoreRegExp :i[a-z]+

(set! :diffOpt [:filler
                :vertical
                :closeoff
                :hiddenoff
                "foldcolumn:0"
                :followwrap
                :internal
                :indent-heuristic
                "algorithm:histogram"])

(when (has? :nvim-0.9.0)
  (set! :diffOpt+ "linematch:60"))

(nmap! :<Space>odx [:desc "[diff] Toggle diff detection exactness"]
       #(let [simpler-opts [:iblank :icase :iwhiteall]
              simpler-diff? (vim.go.diffopt:match :iwhite)
              msg (printf "[diff] detection becomes %s"
                          (if simpler-diff? "more rigorous" :simpler))]
          (vim.notify msg)
          (if simpler-diff?
              (set! :diffOpt- simpler-opts)
              (set! :diffOpt+ simpler-opts))))

(augroup! :myLazyDiff
  (au! [:InsertLeave :BufWritePost] [:desc "Update diff automatically"]
       #(when vim.wo.diff
          (vim.cmd.diffupdate))))
