;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(local gitsigns (require :gitsigns))

;; cspell: word numhl,linehl
(gitsigns.setup {:watch_gitdir {:interval 1000 :follow_files true}
                 ;; :attach_to_untracked false
                 :update_debounce 400
                 :status_formatter nil
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
                 :numhl false
                 :linehl false
                 :signcolumn true
                 :signs {:add {:text "│"
                               :hl :DiffAdd
                               :numhl :DiffAddNr
                               :linehl :DiffAddLn}
                         :change {:text "│"
                                  :hl :DiffChange
                                  :numhl :DiffChangeNr
                                  :linehl :DiffChangeLn}
                         :delete {:text "_"
                                  :hl :DiffDelete
                                  :numhl :DiffDeleteNr
                                  :linehl :DiffDeleteLn}
                         :topdelete {:text "‾"
                                     :hl :DiffDelete
                                     :numhl :DiffDeleteNr
                                     :linehl :DiffDeleteLn}
                         :changedelete {:text "~"
                                        :hl :DiffChange
                                        :numhl :DiffChangeNr
                                        :linehl :DiffChangeLn}}})
