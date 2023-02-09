(import-macros {: expand} :my.macros)

(local mappings (require :rc.telescope.mappings))

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
 :layout_config {:horizontal {;; Reverse preview position
                              :mirror true
                              :preview_width 60
                              :width 0.92
                              :height 0.96
                              :prompt_position :top}
                 :vertical {;; Reverse preview position
                            ;; :mirror true
                            :preview_height 0.3
                            :width 0.92
                            :height 0.96
                            :prompt_position :top}}
 :preview {:timeout 200}
 :file_ignore_patterns ["%.chr$"
                        "%.Z$"
                        "%.dat$"
                        "%.ex5$"
                        "%.exe$"
                        "%.rar$"
                        "%.wnd$"
                        "%.zip$"
                        "/%.git/"
                        "^%.$"
                        :/node_modules/
                        :LICENSE$
                        (expand :^$HOME$)]
 :path_display {;; Note: Truncate head of paths to fit in window.
                ;; The number indicates the right padding width from the
                ;; edge of window.
                :truncate 1}
 :winblend 10
 :border []
 :borderchars ["─" "│" "─" "│" "╭" "╮" "╯" "╰"]
 :use_less true
 :use_env {:COLORTERM :truecolor}
 :color_devicons true}
