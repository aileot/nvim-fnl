;; TOML: treesitter.toml
;; Repo: nvim-treesitter/playground

(import-macros {: au! : nmap! : <Cmd> : <C-u>} :my.macros)

;; Note: <Cmd> instead fails to invoke TSCaptureUnderCursor; either does <C-u>
;; fail with "silent".
(nmap! :<Space>et [:desc "[treesitter] Enumerate TS capture"]
       (<C-u> :TSCaptureUnderCursor))
(nmap! :<Space>eT [:desc "[treesitter] Enumerate TS nodes in tree"]
       (<Cmd> :TSPlaygroundToggle))

(do
  (var ?id nil)
  (nmap! :<Space>ot [:desc "[treesitter] Toggle TS capture mode"]
         #(set ?id
               ;; TODO: Dismiss the popup just after deleting autocmd.
               (if ?id (vim.api.nvim_del_autocmd ?id)
                   (do
                     (vim.cmd :TSCaptureUnderCursor)
                     (au! nil :CursorMoved :TSCaptureUnderCursor))))))
