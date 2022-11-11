;; TOML: git.toml
;; Repo: tpope/vim-fugitive

(import-macros {: printf : command! : nnoremap! : <Cmd> : echo!} :my.macros)

(local {: contains? : confirm? : git : git-tracking? : execute!}
       (require :my.utils))

(local expand vim.fn.expand)

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

(command! :Gush [:bang :nargs "?"]
          "exe '<mods> Git push' (<q-args> ==# '' ? 'origin HEAD' : <q-args>)"
          {:addr :tabs :complete "customlist,fugitive#PushComplete"})

(command! :Gull [:bang :nargs "?"] ;
          "<mods> Git pull <args>"
          {:addr :tabs :complete "customlist,fugitive#PushComplete"})

(nnoremap! :ZD #(let [path (expand "%:p")]
                  (when (confirm? (printf "Delete %s?" path))
                    (vim.cmd "silent update")
                    (if (git-tracking? path)
                        (vim.cmd.GDelete)
                        (vim.cmd.Delete)))))

(nnoremap! [:desc "Unstage current file"] :<Space>gu
           (<Cmd> "silent Git reset HEAD %"))

(nnoremap! [:desc "Unstage all files"] :<Space>gU
           (<Cmd> "silent Git reset HEAD"))

(nnoremap! :<Space>gS (<Cmd> "tab Git"))
(nnoremap! [:desc "Show git status on right"] :<Space>gs (<Cmd> :Git))

;; Remote
(nnoremap! :<Space>grf (<Cmd> "Git fetch --all"))
(nnoremap! :<Space>grf (<Cmd> "Git fetch --unshallow"))

(nnoremap! :<Space>grp #(echo! (git [:pull])))

(nnoremap! :<Space>grP (<Cmd> "Git push"))

(lambda nothing-staged? [path]
  (let [diff-cached (git [:diff :--cached] path)
        no-diff? (= 0 (length diff-cached))]
    no-diff?))

(lambda git-commit [?git-commit-flags]
  (let [amending? (when ?git-commit-flags
                    (contains? ?git-commit-flags :--amend))
        path (expand "%:p")]
    (if (and (not amending?) (nothing-staged? path))
        (vim.notify "[Git] nothing staged yet" vim.log.levels.WARN)
        (and amending? (contains? ?git-commit-flags :--no-edit)
             (not (confirm? "[Git] Amend the staged changes?")))
        nil
        (let [git-args (printf "commit %s"
                               (if ?git-commit-flags
                                   (table.concat ?git-commit-flags " ")
                                   ""))]
          (execute! [:Git git-args] [:wincmd :J] [:resize :25])))))

(nnoremap! [:desc "[Git] edit commit"] :<Space>gcc git-commit)
(nnoremap! [:desc "[Git] amend to last commit"] :<Space>gca
           #(git-commit [:--amend]))

(nnoremap! [:desc "[Git] squash to last commit"] :<Space>gce
           #(git-commit [:--amend :--no-edit]))
