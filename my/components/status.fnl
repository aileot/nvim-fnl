(import-macros {: when-not : ->num : printf} :my.macros)

(local dap {})

(fn dap.status []
  (let [(ok? {: status}) (pcall require :dap)]
    (when ok?
      (status))))

(local lsp {})

(fn get-attached-clients [?bufnr]
  (let [clients (vim.lsp.buf_get_clients (or ?bufnr 0))]
    (icollect [_ client (pairs clients)]
      (string.gsub client.name "%-language%-?server" ""))))

(fn lsp.progress []
  (when-not (?. package.loaded :fidget)
            (let [(ok? lsp-status) (pcall require :lsp-status)]
              (when ok?
                (let [progress (lsp-status.status_progress)]
                  (when (not= "" progress)
                    progress))))))

(fn lsp.names []
  "Show attached lsp server names."
  (let [bufnr (->num vim.g.actual_curbuf)
        client-names (get-attached-clients bufnr)]
    (if (= 0 (length client-names)) "[no client]"
        (or (lsp.progress) (printf "[%s]" (table.concat client-names " "))))))

(fn vim.last-command []
  (let [last-cmd (vim.fn.getreg ":") ;
        editor-width vim.go.columns
        max-width (* editor-width (/ 1 6))
        len (length last-cmd)
        ellipsis ""]
    (if (< max-width len) (.. ":" (last-cmd:sub 1 max-width) ellipsis)
        (< 0 len) (.. ":" last-cmd))))

{: dap : lsp : vim}
