;; TOML: treesitter.toml
;; Repo: p00f/nvim-ts-rainbow

(import-macros {: augroup! : au!} :my.macros)

(local {: setup} (require :nvim-treesitter.configs))

(setup {:rainbow {:enable true
                  :disable [:bash :toml]
                  :extended_mode true
                  :max_file_lines 10000}})

(augroup! :rcTsRainbowSource
  (au! [:BufReadPost :BufWritePost] [:desc "Refresh rainbow"]
       "TSBufToggle rainbow | TSBufToggle rainbow"))
