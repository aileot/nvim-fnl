;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope.nvim

(import-macros {: augroup! : au! : expand} :my.macros)

(local telescope (require :telescope))
(local lsp (require :my.lsp))
(local mappings (require :rc.telescope.mappings))

(fn ts-builtin [method ?opts]
  (let [builtin (require :telescope.builtin)
        func (. builtin method)]
    (func ?opts)))

(fn ts-builtin-lsp [method ?opts]
  (let [builtin (require :telescope.builtin)
        func (. builtin (.. :lsp_ method))]
    (func ?opts)))

(set lsp.document-diagnostics #(ts-builtin :diagnostics {:bufnr 0}))
(set lsp.workspace-diagnostics #(ts-builtin :diagnostics))

(set lsp.definitions #(ts-builtin-lsp :definitions))
(set lsp.references #(ts-builtin-lsp :references))
(set lsp.declarations #(ts-builtin-lsp :declarations))
(set lsp.type-definitions #(ts-builtin-lsp :type_definitions))
(set lsp.implementations #(ts-builtin-lsp :implementations))

(set lsp.document-symbols #(ts-builtin-lsp :document_symbols))
(set lsp.workspace-symbols #(ts-builtin-lsp :workspace_symbols))

(let [defaults ;
      {: mappings
       :vimgrep_arguments [:rg
                           :--color=never
                           :--no-heading
                           :--with-filename
                           :--line-number
                           :--column
                           ;; Remove indentations
                           ;; :--trim
                           :--hidden
                           :--smart-case]
       ;; reset, row, follow
       :selection_strategy :reset
       :sorting_strategy :ascending
       ;; horizontal, vertical, flex
       :layout_strategy :flex
       :layout_config {:horizontal {:width 0.92
                                    :height 0.96
                                    :prompt_position :top}
                       :vertical {;; Reverse preview position
                                  ;; :mirror true
                                  :preview_height 0.3
                                  :width 0.92
                                  :height 0.96
                                  :prompt_position :top}}
       :preview {:timeout 200 :check_mime_type false}
       :file_ignore_patterns ["%.chr$"
                              "%.dat$"
                              "%.ex5$"
                              "%.exe$"
                              "%.wnd$"
                              "/%.git/"
                              "^%.$"
                              :/node_modules/
                              :LICENSE$
                              (expand :^$HOME$)]
       :path_display {;; Note: Truncate head of paths to fit in window.
                      ;; The number indicates the right padding width from the
                      ;; edge of window.
                      :truncate 1}
       :winblend 20
       :border []
       :borderchars ["─" "│" "─" "│" "╭" "╮" "╯" "╰"]
       :use_less true
       :use_env {:COLORTERM :truecolor}
       :color_devicons true}]
  (telescope.setup {: defaults}))

(augroup! :rcTelescopePostWorkaroundNoFoldFoundInBufferFromTelescope
  (au! :Syntax "normal! zx"))
