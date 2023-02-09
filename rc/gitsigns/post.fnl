;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(local {: register-column-highlight} (require :my.utils))

(register-column-highlight {:GitSignsAddNr {:bg :DiffAdd :bold true}
                            :GitSignsChangeNr {:bg :DiffChange :bold true}
                            :GitSignsDeleteNr {:bg :DiffDelete :bold true}
                            :GitSignsTopDeleteNr {:bg :DiffDelete :bold true}
                            :GitSignsChangeDeleteNr {:bg :DiffChange
                                                     :bold true}
                            :GitSignsUntrackedNr {:fg :ErrorMsg}})
