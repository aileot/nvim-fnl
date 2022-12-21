;; TOML: appearance.toml
;; Repo: folke/noice.nvim

(import-macros {: nmap! : <Cmd>} :my.macros)

;; Note: &cmdheight to 0 hide statusline, too.
;; (setglobal! :cmdHeight 0)

;; cspell:word noice
(local noice (require :noice))

(noice.setup {:cmdline {:format {:cmdline {:icon ":"}
                                 :search_down {:icon ""}
                                 :search_up {:icon ""}
                                 :fennel {:icon ""
                                          :lang :fennel
                                          :pattern "^:%s*Fnl=?%s+"}}}})

(when (pcall require :telescope)
  (nmap! [:desc "Show notification history"] :<Space>eM
         (<Cmd> "Noice telescope")))
