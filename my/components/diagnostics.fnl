(local *severity* vim.diagnostic.severity)

(fn get-diagnostics [?bufnr severity]
  (let [bufnr (or ?bufnr 0)]
    (vim.diagnostic.get bufnr {: severity})))

(fn count-error [?bufnr]
  (length (get-diagnostics ?bufnr *severity*.ERROR)))

(fn count-warn [?bufnr]
  (length (get-diagnostics ?bufnr *severity*.WARN)))

(fn count-info [?bufnr]
  (length (get-diagnostics ?bufnr *severity*.INFO)))

(fn count-hint [?bufnr]
  (length (get-diagnostics ?bufnr *severity*.HINT)))

{: count-error : count-warn : count-info : count-hint}
