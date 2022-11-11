;; TOML: colorschemes.toml
;; Repo: catppuccin/nvim

(import-macros {: expand} :my.macros)

;; cspell:words catppuccin

(local {: setup} (require :catppuccin))

(set vim.g.catppuccin_flavour :frappe)

(setup {:compile_path (expand :$NVIM_CACHE_HOME/catppuccin)
        ;; Enable `g:terminal_color_1` kind variables
        :term_colors true
        :dim_inactive {:enable true :shade :dark :percentage 0.15}
        :styles {:comments [:italic]}
        :color_overrides []
        :custom_highlights []
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
