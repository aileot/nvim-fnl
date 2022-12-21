;; WIP
(import-macros {: when-not
                : augroup!
                : au!
                : wo!
                : nmap!
                : unmap!
                : valid-buf?} :my.macros)

(local {: contains? : buf-get-mapargs : del-augroup!} (require :my.utils))

(lambda immutable-buf? [bufnr]
  (and (valid-buf? bufnr) ;
       (not (. vim.bo bufnr :modifiable))))

(lambda viewer-mode-makes-sense? [bufnr]
  (and (valid-buf? bufnr) ;
       (contains? ["" :help :terminal] (. vim.bo bufnr :buftype))))

(local buf-keymaps {:d :<C-d>
                    :u :<C-u>
                    :D :<C-f>
                    :U :<C-b>
                    :<C-x> :<C-o>
                    :<C-a> :<C-i>})

(lambda set-viewer-keymaps [bufnr]
  (let [any-buf-keymap? (accumulate [buf-keymap? false ;
                                     lhs _ (pairs buf-keymaps) ;
                                     &until buf-keymap?]
                          (buf-get-mapargs bufnr :n lhs))]
    (when-not any-buf-keymap?
      (each [lhs rhs (pairs buf-keymaps)]
        (nmap! [:buffer bufnr :nowait :<command>] lhs rhs))
      (let [id (augroup! (.. "myLazyViewerModeUnmapIfModifiable#" bufnr))]
        (au! id :OptionSet [:modifiable]
             #(when-not (immutable-buf? bufnr)
                (each [lhs _ (pairs buf-keymaps)]
                  (pcall #(unmap! bufnr :n lhs)))
                (del-augroup! id)))))))

(lambda switch-winlocal-options [bufnr]
  (let [e? (immutable-buf? bufnr)
        wo-table {:signcolumn (if e? :no vim.go.signcolumn)}]
    (each [_ win-id (ipairs (vim.fn.win_findbuf bufnr))]
      (each [name val (pairs wo-table)]
        (wo! win-id name val)))))

(lambda switch-viewer-mode [bufnr]
  (when (immutable-buf? bufnr)
    (set-viewer-keymaps bufnr)
    (switch-winlocal-options bufnr)
    (augroup! (.. "myLazyViewerModeSwitchWindowLocalOptions#" bufnr)
      (au! [:BufWinEnter :BufWinLeave] [:buffer bufnr]
           #(switch-winlocal-options bufnr)))))

(lambda try-viewer-mode [{: buf}]
  (when (viewer-mode-makes-sense? buf)
    (switch-viewer-mode buf)))

(augroup! :myLazyViewerMode
  (au! :BufWinEnter `try-viewer-mode)
  (au! :OptionSet [:modifiable] [:desc "Start viewer-mode"] `try-viewer-mode))
