;; TOML: treesitter.toml
;; Repo: nvim-treesitter/playground

(local {: setup} (require :nvim-treesitter.configs))

(setup {:playground {:enable true
                     :updatetime 500
                     :persist_queries true
                     :keybindings {:toggle_query_editor :o
                                   ;; Mnemonic: Syntax Highlight
                                   :toggle_hl_groups :s
                                   :toggle_injected_languages :i
                                   :toggle_anonymous_nodes :a
                                   :toggle_language_display :I
                                   :focus_language :x
                                   :unfocus_language :X
                                   :update :R
                                   :goto_node :<CR>
                                   :show_help "?"}}
        :query_linter {:enable true
                       :use_virtual_text true
                       :lint_events [:BufWritePost]}})
