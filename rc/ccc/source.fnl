;; TOML: appearance.toml
;; Repo: uga-rosa/ccc.nvim

(local ccc (require :ccc))
(local ccc-mapping ccc.mapping)

(ccc.setup {:highlighter {:auto_enable true
                          :max_byte (* 1024 5000)
                          :excludes [:gitcommit :pullrequest :gitsendemail]}
            ;;:disable_default_mappings true
            :mappings {;; Note: ccc.quit() is just an alias of `:quit`.
                       :q ccc-mapping.none
                       :ZZ ccc-mapping.complete
                       :Zz ccc-mapping.complete
                       :^ ccc-mapping.set0
                       :$ ccc-mapping.set100
                       :J #(ccc-mapping.set_percent 25)
                       :K #(ccc-mapping.set_percent 75)}})
