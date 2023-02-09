;; TOML: colorschemes.toml
;; Repo: rhysd/vim-color-spring-night

(import-macros {: hi!} :my.macros)

;; Note: The terminal_colors are reset on the initialization.
(set vim.g.terminal_color_5 "#ab92b3")

(hi! :NvimInternalError {:link :Error})

(hi! :Pmenu {:fg "#e7d5ff" :ctermfg 189 :bg "#324358" :ctermbg 235})
(hi! :PmenuSel {:fg "#fedf81" :ctermfg 222 :bg "#445c78" :ctermbg 238})
(hi! :PmenuSbar {:fg "#fedf81" :ctermfg 222 :bg "#4b6077" :ctermbg 238})
(hi! :PmenuThumb {:fg "#fedf81" :ctermfg 222 :bg "#8d9eb2" :ctermbg 103})

(hi! :CursorLine {:ctermbg 235 :bg "#435363"})
(hi! :Quote {:ctermfg 250 :fg "#bcbcbc"})
(hi! :Folded {:ctermfg 189 :ctermbg 235 :fg "#e7d5ff" :bg "#3c2b54"})

(hi! :Search {:bg "#923d92" :ctermbg 60 :underline false :bold true})

;; ;; TSCurrentScope: used with nvim-treesitter-refactor's highlight_current_scope)
;; (hi! :TSCurrentScope {:bg "#022631"})
