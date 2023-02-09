(import-macros {: augroup! : au!} :my.macros)

(augroup! :myLazyDiagnostic
  (au! :DiagnosticChanged [:desc "Focus on more severe diagnostics"]
       #(match (?. $.data :diagnostics)
          diagnostics
          ;; Note: Be careful what number represents each severity. Get the
          ;; values at $VIMRUNTIME/lua/vim/diagnostic.lua,
          ;;  ERROR: 1
          ;;  WARN:  2
          ;;  INFO:  3
          ;;  HINT:  4
          (let [threshold vim.diagnostic.severity.WARN
                max-severity (accumulate [sev vim.diagnostic.severity.HINT ;
                                          _ d (pairs diagnostics) ;
                                          &until (<= sev threshold)]
                               d.severity)
                over-threshold? (<= max-severity threshold)
                opts {:source (if over-threshold? true
                                  :if_many {:min threshold})
                      :severity (when over-threshold?
                                  {:min threshold})}]
            (vim.diagnostic.config {:underline opts
                                    :signs opts
                                    :virtual_text opts
                                    :float {:wrap false
                                            ;; :header false
                                            :source opts.source
                                            :severity opts.severity}})))))
