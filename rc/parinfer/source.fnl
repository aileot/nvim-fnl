;; TOML: ftplugin.toml
;; Repo: eraserhd/parinfer-rust

(import-macros {: g!} :my.macros)

(g! :parinfer_no_maps true)
(g! :parinfer_force_balance true)
;; Note: Logging sometimes freezes nvim.
;; (g! :parinfer_logfile (expand :$NVIM_STATE_HOME/parinfer.log))
