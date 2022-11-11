(import-macros {: when-not
                : if-not
                : augroup!
                : au!
                : nmap!
                : unmap!
                : valid-buf?} :my.macros)

(local {: contains? : buf-get-mapargs} (require :my.utils))

(lambda editable? [bufnr]
  (and (valid-buf? bufnr) ;
       (?. vim.bo bufnr :modifiable) ;
       (not (?. vim.bo bufnr :readonly))))

(lambda readonly-mode-makes-sense? [bufnr]
  ;; FIXME: It's not rigorous on window-local option detection.
  (and (not vim.wo.diff) ;
       (contains? ["" :help] (?. vim.bo bufnr :buftype))))

(local buf-keymaps {:d :<C-d>
                    :u :<C-u>
                    :D :<C-f>
                    :U :<C-b>
                    :<C-x> :<C-o>
                    :<C-a> :<C-i>})

(lambda set-readonly-keymaps [bufnr]
  (let [any-buf-keymap? (accumulate [buf-keymap? false ;
                                     lhs _ (pairs buf-keymaps) ;
                                     &until buf-keymap?]
                          (buf-get-mapargs bufnr :n lhs))]
    (when-not any-buf-keymap?
      (each [lhs rhs (pairs buf-keymaps)]
        (nmap! [:buffer bufnr :nowait :<command>] lhs rhs))
      (augroup! (.. :myLazyReadonlyMode/UnmapIfWritable/ bufnr)
        (au! :OptionSet [:readonly :modifiable]
             #(if-not (valid-buf? bufnr)
                true
                (when (editable? bufnr)
                  (each [lhs _ (pairs buf-keymaps)]
                    (pcall #(unmap! bufnr :n lhs)))
                  ;; Note: Return `true` to deletes the autocmd
                  true)))))))

(lambda sync-readonly-and-modifiable [bufnr name new-val]
  (match name
    :readonly (tset vim.bo bufnr :modifiable (not new-val))
    :modifiable (tset vim.bo bufnr :readonly (not new-val))))

(lambda switch-winlocal-options [bufnr]
  (let [e? (editable? bufnr)
        wo-table {:signcolumn (if e? vim.go.signcolumn :no)}]
    (each [_ win-id (ipairs (vim.fn.win_findbuf bufnr))]
      (let [wo (. vim.wo win-id)]
        (each [name val (pairs wo-table)]
          (tset wo name val))))))

(lambda switch-readonly-mode [bufnr]
    (when-not (editable? bufnr)
      (set-readonly-keymaps bufnr))
    (switch-winlocal-options bufnr)
    (augroup! (.. :myLazyReadonlyMode/SwitchWindowLocalOptions/ bufnr)
      (au! [:BufWinEnter :BufWinLeave] [:buffer bufnr]
           #(switch-winlocal-options bufnr))))

(augroup! :myLazyReadonlyMode ; Same augroup name as that to load this module.
  (au! :OptionSet [:modifiable :readonly] [:desc "Start readonly-mode"]
       #(when (and (valid-buf? $.buf)
                   (readonly-mode-makes-sense? $.buf))
          (sync-readonly-and-modifiable $.buf $.match vim.v.option_new)
          (switch-readonly-mode $.buf))))
