;; TOML: git.toml
;; Repo: tpope/vim-fugitive

(import-macros {: unless
                : ->str
                : augroup!
                : au!
                : setlocal!
                : unmap!
                : nnoremap!
                : xnoremap!
                : feedkeys!
                : defer} :my.macros)

(local {: contains? : confirm? : execute!} (require :my.utils))

(local patterns {;; Note: `git//` won't match any so that `git-index` is useless.
                 ;; :git-index "fugitive:///*/git//"
                 :fugitive-hash "fugitive:///*/.git//*"
                 :commit-msg :COMMIT_EDITMSG})

;; Disable keymaps to `y<C-g>` and `<C-r><C-g>`.

(set vim.g.fugitive_no_maps true)

(fn git-reset-to-cursor-hash []
  (let [cursor-line (vim.fn.getline ".")
        ?hash (cursor-line:match "^%x+")]
    (when (and ?hash (confirm? (.. "[Git] reset to " ?hash)))
      (execute! [:Git :reset ?hash] [:e! (comment "Ensure to update index")]))))

(fn get-commit-win-id []
  (vim.fn.bufwinid :COMMIT_EDITMSG))

(fn shred-git-commit-buffer []
  (let [id (get-commit-win-id)]
    (vim.fn.win_execute id "silent %delete _\nupdate")))

(fn discard-git-commit []
  (let [id (get-commit-win-id)]
    (shred-git-commit-buffer)
    (vim.fn.win_execute id :quit)))

(fn reposition-cursor-in-fugitive-buffer []
  (execute! [:wincmd :L] [:vertical :resize 70])
  (let [sections [:Staged :Unstaged :Untracked]]
    (accumulate [row 0 ;
                 _ section (ipairs sections) &until (< 0 row)]
      (vim.fn.search (.. "^" section) :cew)))
  (vim.schedule #(when (= :n (vim.fn.mode))
                   (feedkeys! :zz :ni))))

(fn remember-cursor-position []
  (let [winnr (vim.fn.winnr "#")
        id (vim.fn.win_getid winnr)
        filetype (vim.fn.getwinvar id :&filetype)]
    (unless (contains? [:fugitive :gitcommit] filetype)
      (augroup! :rcFugitiveSource/RestoreCursor
        (au! :BufWinLeave [:<buffer>] [:once]
             #(vim.schedule #(vim.fn.win_gotoid id)))))))

(lambda start-cursor-at-2nd-commitmsg [bufnr]
  (let [commit-msg-2nd "# This is the commit message #2:"
        min-row-to-start-2nd 6
        lines (vim.api.nvim_buf_get_lines bufnr min-row-to-start-2nd -1 true)
        git-squash? (-> lines (. 1) (= commit-msg-2nd))]
    (when git-squash?
      (let [row-2nd-commit-msg ;
            (accumulate [?row nil ;
                         r line (ipairs lines) &until ?row]
              (when (= commit-msg-2nd line)
                r))
            expected-row (+ 2 row-2nd-commit-msg)]
        (execute! (->str expected-row) :stopinsert)))))

(lambda unmap-fugitive-keymaps [bufnr]
  (unmap! bufnr "" :j)
  (unmap! bufnr "" :k)
  (unmap! bufnr "" :J)
  (unmap! bufnr "" :K)
  (unmap! bufnr "" "*")
  (unmap! bufnr "" "#")
  (unmap! bufnr "" :gq))

(lambda setup-fugitive-keymaps [bufnr]
  ;; Note: Without `s`, stage visualized files and continue to
  ;; `cc/ce/ca`.
  (xnoremap! [:buffer bufnr] :c :sc)
  (nnoremap! [:buffer bufnr :desc "Stage the last window buffer"] :S
             #(execute! [:wincmd :p] :Gw [:wincmd :p] [:normal :gs]
                        [:normal! :zz]))
  (nnoremap! [:buffer bufnr] :R git-reset-to-cursor-hash)
  (let [id (augroup! (.. :rcFugitiveSource/OverwriteKeymaps bufnr))]
    (au! id [:FileType] [:buffer bufnr]
         #(defer 1000
                 (fn []
                   (pcall unmap-fugitive-keymaps $.buf))))))

(augroup! :rcFugitiveSource
  (au! :QuitPre [patterns.commit-msg]
       [:desc "Discard commit if cursor is in another window"]
       #(let [cur-id (vim.api.nvim_get_current_win)
              commit-id (vim.fn.bufwinid $.match)]
          (when (not= cur-id commit-id)
            (shred-git-commit-buffer))))
  (au! :BufRead [patterns.fugitive-hash] "setlocal buftype=nofile")
  (au! :FileType [:fugitive :fugitiveblame]
       [:desc "Set local options for fugitive-buffer"]
       (fn []
         (setlocal! :number false)
         (setlocal! :signColumn :no)
         (setlocal! :bufHidden :wipe)))
  (au! :FileType [:fugitive] reposition-cursor-in-fugitive-buffer)
  (au! :FileType [:fugitive :gitcommit] remember-cursor-position)
  (au! :FileType [:gitcommit] [:desc "Start cursor at the 2nd commit message"]
       #(vim.schedule (fn []
                        (start-cursor-at-2nd-commitmsg $.buf))))
  (au! :FileType [:gitcommit]
       (fn []
         (nnoremap! [:<buffer>] :ZQ discard-git-commit)
         (nnoremap! [:<buffer>] :Zq discard-git-commit)
         (nnoremap! [:<buffer>] :<C-w>c discard-git-commit)))
  (au! :FileType [:fugitive] [:desc "Set up keymaps for git-index"]
       #(setup-fugitive-keymaps $.buf)))
