;; TOML: appearance.toml
;; Repo: Eandrju/cellular-automaton.nvim

(vim.defer_fn #(vim.cmd.CellularAutomaton :make_it_rain) ;
              ;; Pomodoro
              (* 25 60 1000))
