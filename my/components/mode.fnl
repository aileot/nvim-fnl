(import-macros {: str? : printf} :my.macros)

(local icons (require :my.presets.icons))
(local {: mode-names} (require :my.presets.vi-mode))

(fn skkeleton-mode []
  (when vim.g.loaded_skkeleton
    (let [modes {:hira "あ" :kata "ア"}
          m (vim.fn.skkeleton#mode)
          ?desc (when (not= m "")
                  (or (?. modes m) m))]
      ?desc)))

(fn mix [vi-mode]
  (let [vertical-bar icons.symmetry.vertical-bar-solid
        mode-name (. mode-names vi-mode)
        ?skk-mode (skkeleton-mode)]
    (assert (and (str? mode-name) (< 3 (length mode-name)))
            (.. "invalid mode-name: " (vim.inspect mode-name)))
    (if ?skk-mode (printf "%s:%s" ;
                          (mode-name:match "^...") ?skk-mode)
        (.. vertical-bar " %3(" mode-name "%) " vertical-bar))))

{: mix}
