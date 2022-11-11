;; From: motion.toml
;; Repo: bkad/CamelCaseMotion

(import-macros {: map-motion! : noremap-motion! : map-textobj!} :my.macros)

(map-motion! :w :<Plug>CamelCaseMotion_w)
(map-motion! :b :<Plug>CamelCaseMotion_b)
(map-motion! :e :<Plug>CamelCaseMotion_e)
(map-motion! :q :<Plug>CamelCaseMotion_ge)
(noremap-motion! :Q :gE)
(noremap-motion! :ge :e)

;; Mnemonic: Restricted range
(map-textobj! :ir :<Plug>CamelCaseMotion_ie)
(map-textobj! :ar [:expr]
              #(if (vim.fn.search "\\%#[a-z]+$" :cnW) ;
                   :<Plug>CamelCaseMotion_ie ;
                   :<Plug>CamelCaseMotion_iw))
