;; TOML: lsp.toml
;; Repo: jose-elias-alvarez/null-ls.nvim
;; Path: $PLUGINS_PACK_HOME/opt/null-ls.nvim

(import-macros {: nmap! : xmap! : range-map!} :my.macros)

(local null-ls (require :null-ls))
(local lsp (require :my.lsp))
(local rc-cspell (require :rc.null-ls.cspell))

(nmap! [:desc "Format entire buffer on LSP provider"] "==" `lsp.format)
(range-map! [:desc "Format in range on LSP provider"] "=" `lsp.range-format)

(nmap! [:desc "Format by default `==` in case"] :<Space>== "==")
(range-map! [:desc "Format by default `=` in case"] :<Space>= "=")

(nmap! [:desc "Enumerate code actions available"] :<Space>ea `lsp.code-actions)

(xmap! [:desc "Enumerate code actions available"] :<Space>ea
       `lsp.range-code-actions)

(null-ls.setup {;; :debug true
                ;; :log {:enable true
                ;;       ;; "error"|"warn"|"info"|"debug"|"trace"
                ;;       :level :warn
                ;;       ;; "sync"|async
                ;;       :use_console :async}
                :sources (require :rc.null-ls.sources)
                ;; #{m}: message
                ;; #{s}: source name (if not specified, "null-ls")
                ;; #{c}: code if available
                :diagnostics_format "#{m}"
                :fallback_severity vim.diagnostic.severity.WARN
                ;; default: 250
                :debounce 800
                ;; default: false
                ;; :update_on_insert true
                ;; default: 5000
                :default_timeout 3500})

(rc-cspell.define_commands)
(rc-cspell.register_custom_actions)
