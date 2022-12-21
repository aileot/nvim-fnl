;; TOML: web.toml
;; Repo: glacambre/firenvim

(import-macros {: set! : setlocal! : augroup! : au! : nmap! : g!} :my.macros)

(set! :guiFont "SFMono Nerd Font Mono:h12")

(set! :title false)
(set! :showTabline 0)
(set! :lastStatus 0)
(setlocal! :wrap true)
(setlocal! :number false)
(setlocal! :signColumn :no)

(nmap! :<CR> :ZZ)

(g! :firenvim_config
    {:globalSettings {:alt :all}
     :localSettings {:.* {;; cmdline: neovim,firenvim,none
                          :cmdline :neovim
                          :priority 0
                          :takeover :never}}})

(augroup! :rcFirenvimAdd
  (au! :BufWinEnter [:desc "Adjust Win Size"]
       #(let [min-width 80
              min-height 15]
          (when (< vim.go.columns min-width)
            (set! :columns min-width))
          (when (< vim.go.lines min-height)
            (set! :lines min-height))))
  (au! :BufEnter [:github.com_*.txt] "setlocal filetype=markdown"))
