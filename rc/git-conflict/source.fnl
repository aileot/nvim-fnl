;; TOML: git.toml
;; Repo: akinsho/git-conflict.nvim

(import-macros {: augroup! : au! : nmap! : unmap! : <Plug>} :my.macros)

(local git-conflict (require :git-conflict))

(git-conflict.setup {:default_mappings false
                     :disable_diagnostics true
                     :highlights {:incoming :DiffText :current :DiffAdd}})

(lambda set-keymaps-to-resolve [buf]
  (let [keymaps {;; Diff Push
                 :dp (<Plug> :git-conflict-ours)
                 ;; Diff Obtain
                 :do (<Plug> :git-conflict-theirs)
                 :co (<Plug> :git-conflict-ours)
                 :ct (<Plug> :git-conflict-theirs)
                 :cb (<Plug> :git-conflict-both)
                 :c<BS> (<Plug> :git-conflict-none)
                 "[c" (<Plug> :git-conflict-prev-conflict)
                 "]c" (<Plug> :git-conflict-next-conflict)}]
    (each [lhs rhs (pairs keymaps)]
      (nmap! [:buffer buf] lhs &vim rhs))
    (augroup! (.. "rcGitConflictPostUnmapAfterResolved#" buf)
      (au! :User [:GitConflictResolved]
           #(each [lhs _ (pairs keymaps)]
              (unmap! buf :n lhs))))))

(augroup! :rcGitConflictPost
  (au! :User [:GitConflictDetected]
       #(let [msg (.. "Conflict detected in " $.file)]
          (vim.notify msg vim.log.levels.WARN)
          (set-keymaps-to-resolve $.buf))))
