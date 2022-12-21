;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(local {: contains? : register-column-highlight} (require :my.utils))

(local no-signcolumn? (contains? [:no :number] vim.go.signcolumn))

(when no-signcolumn?
  (register-column-highlight {:GitSignsAddNr {:fg :GitGutterAdd :bold true}
                              :GitSignsChangeNr {:fg :GitGutterChange
                                                 :bold true}
                              :GitSignsDeleteNr {:fg :GitGutterDelete
                                                 :bold true}
                              :GitSignsTopDeleteNr {:fg :GitGutterDelete
                                                    :bold true}
                              :GitSignsChangeDeleteNr {:fg :GitGutterChange
                                                       :bold true}
                              :GitSignsUntrackedNr {:fg :#000000 :bg :#FFFFFF}}))
