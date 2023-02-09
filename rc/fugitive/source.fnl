;; TOML: git.toml
;; Repo: tpope/vim-fugitive

(import-macros {: unless
                : augroup!
                : au!
                : setlocal!
                : unmap!
                : nmap!
                : xmap!
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
      (augroup! :rcFugitiveSourceRestoreCursor
        (au! :BufWinLeave [:<buffer>] [:once]
             #(vim.schedule #(vim.fn.win_gotoid id)))))))

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
  (xmap! [:buffer bufnr] :c :sc)
  (nmap! [:buffer bufnr :desc "Stage the last window buffer"] :S
         #(execute! [:wincmd :p] :Gw [:wincmd :p] [:normal :gs] [:normal! :zz]))
  (nmap! [:buffer bufnr] :R git-reset-to-cursor-hash)
  ;; FIXME: Override default local keymaps.
  (let [id (augroup! (.. :rcFugitiveSourceOverwriteKeymaps bufnr))]
    (au! id [:FileType] [:buffer bufnr]
         #(defer 1000
                 (fn []
                   (pcall unmap-fugitive-keymaps $.buf))))))

(augroup! :rcFugitiveSource
  (au! :BufRead [patterns.fugitive-hash] "setlocal buftype=nofile")
  (au! :FileType [:fugitive :fugitiveblame]
       [:desc "Set local options for fugitive-buffer"]
       (fn []
         (setlocal! :wrap false)
         (setlocal! :number false)
         (setlocal! :signColumn :no)
         (setlocal! :bufHidden :wipe)))
  (au! :FileType [:fugitive] reposition-cursor-in-fugitive-buffer)
  (au! :FileType [:fugitive :gitcommit] remember-cursor-position)
  (au! :FileType [:fugitive] [:desc "Set up keymaps for git-index"]
       #(setup-fugitive-keymaps $.buf)))
