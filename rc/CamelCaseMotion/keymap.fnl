;; From: motion.toml
;; Repo: bkad/CamelCaseMotion

(import-macros {: omap! : motion-map! : textobj-map!} :my.macros)

(motion-map! [:remap] :w :<Plug>CamelCaseMotion_w)
(motion-map! [:remap] :b :<Plug>CamelCaseMotion_b)
(motion-map! [:remap] :e :<Plug>CamelCaseMotion_e)
(motion-map! [:remap] :q :<Plug>CamelCaseMotion_ge)
(motion-map! :Q :gE)
(motion-map! :ge :e)

;; Note: With `v` in Operator-pending mode, the char on the cursor will be also
;; included on backward motion); `<C-v>` to exclude it instead.
(omap! :b :v<Plug>CamelCaseMotion_b)
(omap! :B :vB)

;; Mnemonic: Restricted range

(textobj-map! :ir [:remap] :<Plug>CamelCaseMotion_ie)
(textobj-map! :ar [:expr :remap]
              #(if (vim.fn.search "\\%#[a-z]+$" :cnW) :<Plug>CamelCaseMotion_ie
                   :<Plug>CamelCaseMotion_iw))
