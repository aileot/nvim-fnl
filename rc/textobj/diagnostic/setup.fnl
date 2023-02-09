;; TOML: lsp.toml
;; Repo: andrewferrier/textobj-diagnostic.nvim

(import-macros {: textobj-map!} :my.macros)

(textobj-map! :ix #(let [m (require :textobj-diagnostic)]
                     (m.next_diag_inclusive)))

(textobj-map! :ax #(let [m (require :textobj-diagnostic)]
                     (m.next_diag_inclusive)))

(textobj-map! "[x" #(let [m (require :textobj-diagnostic)]
                      (m.prev_diag)))

(textobj-map! "]x" #(let [m (require :textobj-diagnostic)]
                      (m.next_diag)))
