;; TOML: memo.toml
;; Repo: dhruvasagar/vim-table-mode

(import-macros {: augroup! : au! : textobj-map! : <Plug>} :my.macros)

(textobj-map! [:remap] :iq (<Plug> :table-mode-cell-text-object-i))
(textobj-map! [:remap] :aq (<Plug> :table-mode-cell-text-object-a))

(augroup! :rcTableModeAdd
  (au! [:TextChanged :InsertLeave] ["*.{wiki,md,org,txt}"]
       [:desc "Realign Table"]
       #(when (-> (vim.fn.getline ".")
                  (: :match "^%s*|.*|%s*$"))
          (vim.cmd.TableModeRealign))))
