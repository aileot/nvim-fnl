;; TOML: operator.toml
;; Repo: echasnovski/mini.surround

(local surround (require :mini.surround))
(local custom_surroundings (require :rc.mini.surround.custom_surroundings))

(local mappings {;; Mnemonic: Yield
                 :add :<BSlash>y
                 :delete :<BSlash>d
                 :replace :<BSlash>c
                 ; Find surrounding to the right
                 :find "]<BSlash>"
                 :find_left "[<BSlash>"
                 :highlight ""
                 :update_n_lines ""
                 :suffix_last :G
                 :suffix_next :n})

(surround.setup {: mappings
                 : custom_surroundings
                 ;; Max number of lines within which surrounding is searched.
                 :n_lines 20
                 :highlight_duration 1000})
