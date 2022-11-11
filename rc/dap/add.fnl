;; TOML: debug.toml
;; Repo: mfussenegger/nvim-dap

(import-macros {: nnoremap!} :my.macros)

(fn toggle-debug-breakpoint []
  (let [{: toggle_breakpoint} (require :dap)]
    (toggle_breakpoint)))

(nnoremap! :mb toggle-debug-breakpoint)
(nnoremap! :<F9> toggle-debug-breakpoint)

(fn continue-debug []
  (let [filetype vim.bo.filetype
        dap-continue (if (= filetype :lua)
                         (. (require :osv) :launch)
                         (. (require :dap) :continue))]
    (dap-continue)))

(nnoremap! :mc continue-debug)
(nnoremap! :<F5> continue-debug)
