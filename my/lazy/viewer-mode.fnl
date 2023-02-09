;; WIP
(import-macros {: when-not
                : augroup!
                : au!
                : setlocal!
                : nmap!
                : unmap!
                : valid-buf?} :my.macros)

(local {: contains? : buf-get-mapargs : del-augroup!} (require :my.utils))

(lambda immutable-buf? [bufnr]
  (not (. vim.bo bufnr :modifiable)))

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
  "Set buffer-local keymaps for viewer-mode. The keymaps are to be restored
  when the buffer gets back to be editable."
  (let [any-buf-keymap? (accumulate [buf-keymap? false ;
                                     lhs _ (pairs buf-keymaps) ;
                                     &until buf-keymap?]
                          (buf-get-mapargs bufnr :n lhs))]
    (when-not any-buf-keymap?
      (each [lhs rhs (pairs buf-keymaps)]
        (nmap! [:buffer bufnr :nowait] lhs &vim rhs))
      (let [id (augroup! (.. "myLazyViewerModeUnmapIfModifiable#" bufnr))]
        (au! id :OptionSet [:modifiable]
             #(when-not (immutable-buf? bufnr)
                (each [lhs _ (pairs buf-keymaps)]
                  (pcall #(unmap! bufnr :n lhs)))
                (del-augroup! id)))))))

(lambda switch-winlocal-options [bufnr]
  (let [immutable? (immutable-buf? bufnr)
        wo-options {:signColumn (if immutable? :no vim.go.signcolumn)
                    :concealLevel (if immutable? 2 vim.go.conceallevel)
                    :concealCursor (if immutable? :nc vim.go.concealcursor)}]
    (each [_ win (ipairs (vim.fn.win_findbuf bufnr))]
      (each [name val (pairs wo-options)]
        ;; Note: vim.wo instead doesn't work expectedly as most of them do not
        ;; mean global-local options. Therefore, the interfaces instead are
        ;; useless:
        ;;   - vim.wo
        ;;   - vim.api.nvim_set_option_value()
        ;;   - vim.api.win_set_option() -- deprecated
        ;;   - vim.fn.setwinvar()
        ;; See https://github.com/neovim/neovim/pull/20288.
        (vim.api.nvim_win_call win #(setlocal! (name:lower) val))))))

(lambda try-viewer-mode [{: buf}]
  (when (viewer-mode-makes-sense? buf)
    (switch-winlocal-options buf)
    (when (immutable-buf? buf)
      (set-viewer-keymaps buf)))
  ;; Note: Not to return true at the end of autocmd in case.
  nil)

(augroup! :myLazyViewerMode
  ;; Note: autocmd on OptionSet cannot set buf-locally.
  (au! :OptionSet [:modifiable]
       [:desc "Try Viewer mode if it makes sense in current buf"]
       try-viewer-mode)
  (au! [:BufWinEnter :BufWinleave]
       [:desc "Try Viewer mode if it makes sense in current buf"]
       try-viewer-mode))
