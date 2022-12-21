;; Ref: $VIMRUNTIME/ftplugin/gitcommit.vim

(import-macros {: ->str
                : buf-augroup!
                : au!
                : nmap!
                : imap!
                : <Cmd>
                : feedkeys!
                : echo!} :my.macros)

(local {: set-undoable! : erase-buf} (require :my.utils))

(local msg-patterns
       {:new-commit "^%s*# Please enter the commit message"
        :first-rebase-msg "# This is the 1st commit message:"
        :rest-rebase-msg "# This is the commit message #%d+:"})

(lambda set-options []
  (set-undoable! :report 1000)
  (set-undoable! :number false)
  (set-undoable! :signcolumn :no)
  (set-undoable! :bufhidden :wipe)
  (set-undoable! :formatoptions (+ vim.opt_local.formatoptions
                                   ;; t: Auto-wrap as &textwidth
                                   [:t])))

(lambda set-keymaps []
  (imap! [:<buffer>] :<C-q> (<Cmd> :x))
  (nmap! [:<buffer> :desc "Erase git-commitmsg"] :ZQ `erase-buf)
  (nmap! [:<buffer> :desc "Erase git-commitmsg"] :Zq `erase-buf)
  (nmap! [:<buffer> :desc "Erase git-commitmsg"] :<C-w>c `erase-buf))

(buf-augroup! :ftGitcommit
  (au! :QuitPre
       [:<buffer> :desc "Discard commit if cursor is in another window"]
       #(let [cur-id (vim.api.nvim_get_current_win)
              commit-id (vim.fn.bufwinid $.match)]
          (when (not= cur-id commit-id)
            (erase-buf $.buf)))))

(lambda reposition-window []
  (vim.cmd.wincmd :J)
  (vim.cmd.resize 25))

(lambda start-cursor-at-2nd-commitmsg! [bufnr]
  (let [min-row-to-start-2nd 6]
    (when (< min-row-to-start-2nd (vim.api.nvim_buf_line_count bufnr))
      (let [commit-msg-2nd "# This is the commit message #2:"
            lines (vim.api.nvim_buf_get_lines bufnr min-row-to-start-2nd -1
                                              true)
            ?row-of-git-squash-2nd (accumulate [_ nil ;
                                                row line (ipairs lines) ;
                                                &until (: line :match "^#")]
                                     (when (= line commit-msg-2nd)
                                       row))]
        (when ?row-of-git-squash-2nd
          (let [expected-row (+ 2 min-row-to-start-2nd ?row-of-git-squash-2nd)]
            (vim.cmd (->str expected-row))))))))

(lambda setup []
  (set-options)
  (set-keymaps)
  (reposition-window)
  (let [first-non-blank-line (vim.fn.getline (vim.fn.nextnonblank 1))
        commit-type (if (first-non-blank-line:match (. msg-patterns :new-commit))
                        :new-commit
                        (first-non-blank-line:match (. msg-patterns
                                                       :first-rebase-msg))
                        :rebasing ;
                        (first-non-blank-line:match "^%s*[^#]") :amending
                        (echo! "undefined commit type is detected" :ErrorMsg))]
    (match commit-type
      :new-commit (feedkeys! :ggi :ni)
      :rebasing (start-cursor-at-2nd-commitmsg! (vim.api.nvim_get_current_buf)))))

(vim.schedule setup)

nil
