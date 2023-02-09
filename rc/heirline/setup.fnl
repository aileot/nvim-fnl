;; TOML: appearance.toml
;; Repo: rebelot/heirline.nvim

(import-macros {: set! : setlocal!} :my.macros)

(local heirline (require :heirline))
(local {: gather} (require :rc.heirline.utils))

(local components (require :rc.heirline.components))

(fn ->low-priority [component ?max-width]
  "Hide the provider in smaller window"
  (let [max-width (or ?max-width 100)
        in-narrow-window? ;
        (fn [self]
          (let [?win-width self.win-width]
            (assert ?win-width
                    (.. "The component must have \"update-win-width\" in its parent"
                        " to set priority."))
            (< max-width ?win-width)))]
    (set component.condition (or in-narrow-window? component.condition))
    component))

(local tabline ;
       (gather components.update-win-width
               (gather components.default ;
                       [components.mode
                        components.space
                        components.last-command
                        components.space
                        components.nesting
                        components.align
                        components.tabpages
                        components.align
                        components.file-path
                        components.space])))

(local winbar {:fallthrough false
               :init ;; `&winbar` is to set on BufWinEnter on each window.
               #(setlocal! :winbar nil)})

(local statusline ;
       (gather components.update-path
               (gather components.update-win-width
                       (gather components.default
                               [;; Left
                                components.git-status
                                components.space
                                components.path-from-root
                                components.modified?
                                (->low-priority [components.space
                                                 components.file-size])
                                ;; Mid
                                components.align
                                (->low-priority components.ls-names 80)
                                components.align
                                ;; Right
                                components.diagnostics
                                (->low-priority [components.space
                                                 components.foldmethod])
                                components.space
                                components.file-icon
                                (->low-priority [components.file-type
                                                 components.space])
                                (->low-priority [components.ruler
                                                 components.space])
                                components.percentage
                                components.space
                                components.scrollbar]))))

(set! :showMode false)
(set! :showTabline 2)

(heirline.setup {: statusline : winbar : tabline})
