;; TOML: lsp.toml
;; Repo: jose-elias-alvarez/null-ls.nvim

(import-macros {: nmap! : xmap! : range-map!} :my.macros)

(local null-ls (require :null-ls))
(local lsp (require :my.lsp))
(local rc-cspell (require :rc.null-ls.cspell))

(nmap! [:desc "Format entire buffer on LSP provider"] :<Space>== lsp.format)
(range-map! [:desc "Format in range on LSP provider"] :<Space>= lsp.rangeFormat)

(nmap! [:desc "Enumerate code actions available"] :<Space>ea lsp.codeAction)

(xmap! [:desc "Enumerate code actions available"] :<Space>ea
       lsp.rangeCodeAction)

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
