;; TOML: operator.toml
;; Repo: arthurxavierx/vim-caser

;; cspell:words caser

(import-macros {: g! : nmap! : xmap!} :my.macros)

(g! :caser_no_mappings true)

(macro setup-keymaps []
  (let [printf string.format
        prefix :<BSlash>u
        suffix-map {"(" {:case :Sentence :desc "Change to sentence case"}
                    ")" {:case :Space :desc "change to normal case"}
                    :- {:case :Kebab :desc :change-to-kebab-case}
                    :. {:case :Dot :desc :change.to.dot.case}
                    :_ {:case :Snake :desc :change_to_snake_case}
                    :c {:case :Camel :desc :changeToCamelCase}
                    :d {:case :Dot :desc :change.to.dot.case}
                    :k {:case :Kebab :desc :change-to-kebab-case}
                    :p {:case :Mixed :desc :ChangeToPascalCase}
                    :s {:case :Snake :desc :change_to_snake_case}
                    :t {:case :Title :desc "Change To Title Case"}
                    :u {:case :Upper :desc :CHANGE_TO_UPPER_CASE}}]
    `(do
       ,(icollect [suffix {: case : desc} (pairs suffix-map)]
          (let [operator (printf "<Plug>Caser%sCase" case)
                v-operator (printf "<Plug>CaserV%sCase" case)
                l-operator (printf "^<Plug>Caser%sCase$" case)
                l-desc (.. "[Line] " desc)
                lhs (.. prefix suffix)
                l-lhs (.. prefix suffix suffix)]
            `(do
               (xmap! ,lhs ,v-operator {:desc ,desc})
               (nmap! ,lhs ,operator {:desc ,desc})
               (nmap! ,l-lhs ,l-operator {:desc ,l-desc})))))))

(setup-keymaps)
