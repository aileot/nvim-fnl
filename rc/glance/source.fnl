;; TOML: lsp.toml
;; Repo: DNLHC/glance.nvim

(local {: setup : actions} (require :glance))

(local lsp (require :my.lsp))

(set lsp.definitions #(vim.cmd.Glance :definitions))
(set lsp.references #(vim.cmd.Glance :references))
(set lsp.type-definitions #(vim.cmd.Glance :type_definitions))
(set lsp.implementations #(vim.cmd.Glance :implementations))

(setup {:height 30
        :hook {:before_open (lambda [results open jump _method]
                              (let [uri (vim.uri_from_bufnr 0)
                                    first-result (. results 1)]
                                (if (and (= 1 (length results))
                                         (= uri
                                            (or first-result.uri
                                                first-result.targetUri)))
                                    (jump first-result)
                                    (open results))))}
        :mappings {:list {:j actions.next
                          :k actions.previous
                          :<C-n> actions.next_location
                          :<C-p> actions.previous_location
                          :<C-u> (actions.preview_scroll_win 5)
                          :<C-d> (actions.preview_scroll_win -5)
                          :o actions.jump_split
                          :O actions.jump_vsplit
                          :gO actions.jump_tab
                          :<CR> actions.jump
                          :p (actions.enter_win :preview)
                          :ZZ actions.close}
                   :preview {:<C-n> actions.next_location
                             :<C-p> actions.previous_location
                             :i (actions.enter_win :list)}}})
