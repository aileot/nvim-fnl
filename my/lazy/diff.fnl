(import-macros {: printf : augroup! : au! : setglobal! : nnoremap! : has?}
               :my.macros)
;; cspell:ignoreRegExp :i[a-z]+

(setglobal! :diffOpt [:filler
                      :vertical
                      :closeoff
                      :hiddenoff
                      "foldcolumn:0"
                      :followwrap
                      :internal
                      :indent-heuristic
                      "algorithm:histogram"])

(when (has? :nvim-0.9.0)
  (setglobal! :diffOpt+ "linematch:60"))

(nnoremap! :<Space>odx [:desc "[diff] Toggle diff detection exactness"]
           #(let [simpler-opts [:iblank :icase :iwhiteall]
                  simpler-diff? (vim.go.diffopt:match :iwhite)
                  msg (printf "[diff] detection becomes %s"
                              (if simpler-diff? "more rigorous" :simpler))]
              (vim.notify msg)
              (if simpler-diff?
                  (setglobal! :diffOpt- simpler-opts)
                  (setglobal! :diffOpt+ simpler-opts))))

(augroup! :myLazy/Diff
  (au! [:InsertLeave :BufWritePost] [:desc "Update diff automatically"]
       #(when vim.wo.diff
          vim.cmd.diffupdate)))
