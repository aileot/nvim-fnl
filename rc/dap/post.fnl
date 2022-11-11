;; TOML: debug.toml
;; Repo: mfussenegger/nvim-dap

(local dap (require :dap))

(let [filetypes [:lua :python :typescript]
      ft-config-root :rc.dap.ft]
  (each [_ ft (pairs filetypes)]
    (let [path (.. ft-config-root "." ft)]
      (require path))))

(tset dap.listeners ;
      :before :event_terminated :close_repl dap.repl.close)

(tset dap.listeners ;
      :before :event_exited :close_repl dap.repl.close)
