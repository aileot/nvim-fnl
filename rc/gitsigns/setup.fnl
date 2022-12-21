;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(import-macros {: when-not : augroup! : au!} :my.macros)

(local {: contains?} (require :my.utils))

(local gitsigns (require :gitsigns))

(local use-signcolumn? (not (contains? [:no :number] vim.go.signcolumn)))

(fn toggle-diff [enable?]
  (gitsigns.toggle_word_diff enable?)
  (gitsigns.toggle_linehl enable?))

(augroup! :rcGitSignsSetup/ToggleWordDiff
  (au! [:BufWinEnter :BufEnter] [:desc "[gitsigns] Enable diff"]
       #(vim.schedule (fn []
                        (when (contains? [:gitcommit] vim.bo.filetype)
                          (toggle-diff true)
                          (au! nil [:BufWinLeave] [:<buffer> :once]
                               #(toggle-diff false))))))
  (au! [:InsertEnter] [:desc "[gitsigns] Disable diff"]
       #(vim.schedule (fn []
                        (when-not (contains? [:gitcommit] vim.bo.filetype)
                          (toggle-diff false))))))

;; cspell: word numhl,linehl

(gitsigns.setup {:watch_gitdir {:interval 1000 :follow_files true}
                 ;; :attach_to_untracked false
                 :update_debounce 800
                 :diff_opts {:vertical true}
                 ;; Blame
                 :current_line_blame false
                 :current_line_blame_opts {:virt_text true
                                           ;; "eol"|"overlay"|"right_align"
                                           :virt_text_pos :right_align
                                           :delay 1000}
                 :current_line_blame_formatter " <abbrev_sha>: <summary>"
                 ;; Note: Keep sign priority bigger than that of diagnosis,
                 ;; which also stands out in virtual texts.
                 :sign_priority 20
                 :signcolumn use-signcolumn?
                 :numhl (not use-signcolumn?)
                 :linehl false
                 :word_diff false
                 :signs {:untracked {:numhl :GitSignsUntrackedNr :text ""}
                         :topdelete {:nunhl :GitSignsTopDeleteNr}
                         :changedelete {:nunhl :GitSignsChangeDeleteNr}}})
