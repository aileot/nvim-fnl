;; TOML: appearance.toml
;; Repo: uga-rosa/ccc.nvim

(local ccc (require :ccc))
(local <ccc> ccc.mapping)

(ccc.setup {:highlighter {:auto_enable true
                          :max_byte (* 1024 5000)
                          :excludes [:gitcommit :pullrequest :gitsendemail]}
            ;;:disable_default_mappings true
            :mappings {;; Note: ccc.quit() is just an alias of `:quit`.
                       :q <ccc>.none
                       :ZZ <ccc>.complete
                       :Zz <ccc>.complete
                       :^ <ccc>.set0
                       :$ <ccc>.set100
                       :J #(<ccc>.set_percent 25)
                       :K #(<ccc>.set_percent 75)}})
