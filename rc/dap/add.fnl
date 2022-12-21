;; TOML: debug.toml
;; Repo: mfussenegger/nvim-dap

(import-macros {: nmap! : <Lua>} :my.macros)

(nmap! :mb (<Lua> "require'dap'.toggle_breakpoint()"))
(nmap! :<F9> (<Lua> "require'dap'.toggle_breakpoint()"))

(fn continue-debug []
  (let [filetype vim.bo.filetype
        dap-continue (if (= filetype :lua)
                         (. (require :osv) :launch)
                         (. (require :dap) :continue))]
    (dap-continue)))

(nmap! :mc `continue-debug)
(nmap! :<F5> `continue-debug)
