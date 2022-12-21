;; TOML: colorschemes.toml
;; Repo: catppuccin/nvim

(import-macros {: expand} :my.macros)

;; cspell:words catppuccin

(local {: setup} (require :catppuccin))

(local flavour ;; (->darker :latte :frappe :macchiato :mocha)
       :frappe)

(local palette {:background "#334152"
                :comment "#8d9eb2"
                :signcolumn-foreground "#fffeeb"})

(setup {: flavour
        :compile_path (expand :$NVIM_CACHE_HOME/catppuccin)
        ;; Enable `g:terminal_color_1` kind variables
        :term_colors (not vim.g.termguicolors)
        :dim_inactive {:enable true :shade :dark :percentage 0.15}
        :styles {:comments [:italic]}
        ;; color palette of spring-night:
        ;;    rhysd/vim-color-spring-night/gen/src/main.rs
        ;; color palette of catppuccin-frappe:
        ;;    catppuccin/nvim/lua/catppuccin/palettes/frappe.lua
        ;; :color_overrides {flavour {:base palette.background
        ;;                            :mantle "#3a4b5c"
        ;;                            :crust "#435060"
        ;;                            :surface2 palette.comment}}
        :custom_highlights {}
        :integrations {:gitsigns true
                       :leap true
                       :markdown true
                       :nvimtree false
                       :telescope true
                       :treesitter true
                       :ts_rainbow true
                       :which_key true
                       :cmp false
                       :indent_blankline {:enabled true
                                          :colored_indent_levels true}
                       :native_lsp {:enabled true
                                    :virtual_text {:errors [:italic]
                                                   :hints [:italic]
                                                   :warnings [:italic]
                                                   :information [:italic]}
                                    :underlines {:errors [:underline]
                                                 :hints [:underline]
                                                 :warnings [:underline]
                                                 :information [:underline]}}}})
