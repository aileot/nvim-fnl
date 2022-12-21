;; TOML: browse.toml
;; Repo: stevearc/aerial.nvim

(import-macros {: nmap! : <Cmd>} :my.macros)

(local aerial (require :aerial))

(local update_delay 400)
(aerial.setup {:backends [:lsp :treesitter :markdown :man]
               :on_attach (comment (fn [bufnr]
                                     (nmap! [:buffer bufnr] "{"
                                            (<Cmd> :AerialPrev))
                                     (nmap! [:buffer bufnr] "}"
                                            (<Cmd> :AerialNext))))
               :layout {:max_width [60 0.2]
                        :default_direction :right
                        ;; edge|window
                        :placement :edge}
               ;; window|global
               :attach_mode :global
               :keymaps {:? :actions.show_help
                         :g? :actions.show_help
                         :<CR> :actions.jump
                         :<C-v> :actions.jump_vsplit
                         :<C-s> :actions.jump_split
                         :p :actions.scroll
                         :<C-j> :actions.down_and_scroll
                         :<C-k> :actions.up_and_scroll
                         "{" :actions.prev
                         "}" :actions.next
                         "[" :actions.prev_up
                         "]" :actions.next_up
                         :ZZ :actions.close
                         :Zz :actions.close
                         :ZQ :actions.close
                         :Zq :actions.close
                         :za :actions.tree_toggle
                         :zA :actions.tree_toggle_recursive
                         :zo :actions.tree_open
                         :zO :actions.tree_open_recursive
                         :zc :actions.tree_close
                         :zC :actions.tree_close_recursive
                         :zr :actions.tree_increase_fold_level
                         :zR :actions.tree_open_all
                         :zm :actions.tree_decrease_fold_level
                         :zM :actions.tree_close_all
                         :zx :actions.tree_sync_folds
                         :zX :actions.tree_sync_folds}
               :highlight_on_hover true
               :update_events "InsertLeave,BufWritePost"
               :show_guides true
               :lsp {:diagnostics_trigger_update false : update_delay}
               :treesitter {: update_delay}
               :markdown {: update_delay}
               :man {: update_delay}})
