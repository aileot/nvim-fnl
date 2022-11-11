;; TOML: ftplugin.toml
;; Repo: gpanders/nvim-parinfer

(import-macros {: g! : augroup! : au! : imap!} :my.macros)

(g! :parinfer_no_maps true)
(g! :parinfer_force_balance true)

(fn set-keymaps [bufnr]
  (imap! [:buffer bufnr] :<C-S-t> "<Plug>(parinfer-tab)")
  (imap! [:buffer bufnr] :<C-S-d> "<Plug>(parinfer-backtab)"))

(augroup! :rcParinferSource
  (au! :OptionSet [:lisp] #(set-keymaps $.buf))
  (au! :FileType #(when vim.bo.lisp
                    (set-keymaps $.buf))))
