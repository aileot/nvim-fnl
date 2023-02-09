;; TOML: motion.toml
;; Repo: aileot/nvim-sticky-cursor

(import-macros {: map! : omap!} :my.macros)

(local {: contains?} (require :my.utils))

(fn sticky-omap! [lhs ?rhs]
  "Define sticky omap.
  @param lhs string
  @param ?rhs string Otherwise, `lhs` is used for rhs."
  (let [sticky (require :nvim-sticky)
        rhs (or ?rhs lhs)]
    (map! :o lhs [:expr :remap]
          (fn []
            (sticky.motion rhs
                           {:restore_if #(not (contains? [:c :d :gq :gw]
                                                         vim.v.operator))})))))

;; TODO: Make `.` repeat stick cursor for `<k`.
(sticky-omap! :k)
(sticky-omap! :H)
(sticky-omap! :gg)

(sticky-omap! "{" "V{")
(sticky-omap! "[z" "V[z")
(sticky-omap! "v{" "{")
(sticky-omap! "v[z" "v[z")

(omap! "}" "V}")
(omap! "v}" "}")
