;; TOML: treesitter.toml
;; Repo: nvim-treesitter/nvim-treesitter-refactor

(import-macros {: hi!} :my.macros)

(local {: setup} (require :nvim-treesitter.configs))

(hi! :TSCurrentScope {:bold true})

(setup {:refactor {:highlight_definitions {:enable false}
                   :highlight_current_scope {:enable true
                                             :disable [:markdown :help]}
                   :smart_rename {:enable true
                                  ;; :disable [:lua :vim :fennel]
                                  :keymaps {:smart_rename :cs}}
                   ;; Note: gd for make is not implemented yet.
                   :navigation {:enable [:make]
                                :keymaps {:goto_definition :gd
                                          :list_definitions :gD
                                          :goto_next_usage "[u"
                                          :goto_prev_usage "]u"}}}})
