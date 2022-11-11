;; TOML: appearance.toml
;; Repo: folke/noice.nvim

(import-macros {: nnoremap!} :my.macros)

;; Note: &cmdheight to 0 hide statusline, too.
;; (setglobal! :cmdHeight 0)

;; cspell:word noice firstc
(local noice (require :noice))

(noice.setup {:cmdline {:icons {":" {:icon ":"}
                                :/ {:icon "/" :firstc false}
                                :? {:icon "?" :firstc false}}}})

(let [ok? (pcall require :telescope)]
  (when ok?
    (nnoremap! [:desc "Show notification history"] :<Space>eM
               "<Cmd>Noice telescope<CR>")))
