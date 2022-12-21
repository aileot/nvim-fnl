;; TOML: git.toml
;; Repo: tpope/vim-fugitive

(import-macros {: printf : command! : nmap! : <Cmd> : echo! : expand}
               :my.macros)

(local {: contains? : confirm? : git : git-tracking? : execute!}
       (require :my.utils))

(command! :Gv [:bar :bang] ;
          "exe <count> <mods> 'Gvsplit<bang>' <q-args>"
          {:nargs "*"
           :range -1
           :addr :other
           :complete "customlist,fugitive#ReadComplete"})

;; cspell:word Gupdate
(command! :Gupdate [:bar :desc "Stage only if modified"]
          ;; Note: Useful with `:argdo`, `:cdo`, and so on.
          "if &modified | Gw | endif")

(nmap! :ZD #(let [path (expand "%:p")]
              (when (confirm? (printf "Delete %s?" path))
                (vim.cmd "silent update")
                (if (git-tracking? path)
                    (vim.cmd.GDelete)
                    (vim.cmd.Delete)))))

(nmap! [:desc "[git] :read current buffer to HEAD:%"] :<Space>gE
       #(when (confirm? ":read HEAD:%?")
          (vim.cmd.Gread "HEAD:%")
          (vim.cmd.update)))

(nmap! [:desc "[git] reset this repository to HEAD~"] :<Space>gR
       #(when (confirm? "Reset this repository to \"HEAD~\"?")
          (vim.cmd.Git "reset HEAD~")))

(nmap! [:desc "[git] unstage current file"] :<Space>gu
       (<Cmd> "silent Git reset HEAD %"))

(nmap! [:desc "[git] unstage all files"] :<Space>gU
       (<Cmd> "silent Git reset HEAD"))

(nmap! :<Space>gS (<Cmd> "tab Git"))
(nmap! [:desc "[git] show status on right"] :<Space>gs (<Cmd> :Git))

;; Rebase
(nmap! :<Space>grr (<Cmd> "Git rebase --continue"))
(nmap! :<Space>grs (<Cmd> "Git rebase --skip"))
(nmap! :<Space>gra (<Cmd> "Git rebase --abort"))
(nmap! :<Space>gre (<Cmd> "Git rebase --edit-todo"))
(nmap! :<Space>gr<Space> [:desc "[git] populate cmdline with `:Git rebase `"]
       ":<C-u>Git rebase ")

;; Remote

(nmap! :<Space>grf (<Cmd> "Git fetch --all"))
(nmap! :<Space>grf (<Cmd> "Git fetch --unshallow"))

(nmap! :<Space>grp #(echo! (git [:pull])))

(nmap! :<Space>grP (<Cmd> "Git push"))

(lambda nothing-staged? [path]
  (let [diff-cached (git [:diff :--cached] path)
        no-diff? (= 0 (length diff-cached))]
    no-diff?))

(lambda git-commit [?git-commit-flags]
  (let [amending? (when ?git-commit-flags
                    (contains? ?git-commit-flags :--amend))
        path (expand "%:p")]
    (if (and (not amending?) (nothing-staged? path))
        (vim.notify "[git] nothing staged yet" vim.log.levels.WARN)
        (and amending? (contains? ?git-commit-flags :--no-edit)
             (not (confirm? "[git] amend the staged changes?")))
        nil
        (let [git-args (printf "commit %s"
                               (if ?git-commit-flags
                                   (table.concat ?git-commit-flags " ")
                                   ""))]
          (execute! [:Git git-args] [:wincmd :J] [:resize :25])))))

(nmap! [:desc "[git] edit commit"] :<Space>gcc `git-commit)
(nmap! [:desc "[git] amend to last commit"] :<Space>gca
       #(git-commit [:--amend]))

(nmap! [:desc "[git] squash to last commit"] :<Space>gce
       #(git-commit [:--amend :--no-edit]))
