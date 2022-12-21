;; TOML: appearance.toml
;; Repo: rebelot/heirline.nvim

(import-macros {: str? : nil? : seq?} :my.macros)

(local {: compact} (require :my.utils))

(local utils (require :heirline.utils))

(lambda window-width [?winbar?]
  (if (or (< vim.go.laststatus 3) ?winbar?)
      (vim.api.nvim_win_get_width 0)
      vim.go.columns))

(lambda ratio-to-window-width [width ?winbar?]
  (let [win-width (window-width ?winbar?)]
    (/ width win-width)))

(lambda copy-component-color [?raw-component reference]
  (when ?raw-component
    (let [new-component (if (str? ?raw-component)
                            {:hl {} :provider ?raw-component} ;
                            ?raw-component)]
      (when (nil? (?. new-component :hl :fg))
        (tset new-component :hl :fg (?. reference :hl :fg)))
      (when (nil? (?. new-component :hl :bg))
        (tset new-component :hl :bg (?. reference :hl :bg)))
      new-component)))

(lambda copy-component-inverse-color [?raw-component reference]
  (when ?raw-component
    (let [new-component (if (str? ?raw-component)
                            {:hl {} :provider ?raw-component} ;
                            ?raw-component)]
      (when (nil? (?. new-component :hl :fg))
        (tset new-component :hl :fg (?. reference :hl :bg)))
      (when (nil? (?. new-component :hl :bg))
        (tset new-component :hl :bg (?. reference :hl :fg)))
      new-component)))

(lambda enclose-components [brackets components]
  (let [[b1 b2] brackets
        reference components
        [component-b1 component-b2] (if (seq? reference)
                                        [{:provider b1} {:provider b2}]
                                        [(copy-component-color b1 reference)
                                         (copy-component-color b2 reference)])]
    (compact [component-b1
              (if (seq? components)
                  (unpack components)
                  components)
              component-b2])))

;; (lambda gather-children [parent ...]
;;   (let [new-components (icollect [_ comp (ipairs parent)]
;;                          comp)
;;         children [...]]
;;     (each [_ child (ipairs children)]
;;       (table.insert new-components child))
;;     new-components))

{: window-width
 : ratio-to-window-width
 : enclose-components
 :gather utils.insert
 : copy-component-color
 : copy-component-inverse-color}
