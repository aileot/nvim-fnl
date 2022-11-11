;; TOML: essential.toml
;; Repo: nvim-treesitter/nvim-treesitter

(import-macros {: augroup! : au! : setlocal!} :my.macros)

(local {: setup} (require :nvim-treesitter.configs))
(local {: large-file?} (require :my.utils))

(setup {:disable (fn [_lang buf]
                   (let [max-size ; 500 KB
                         (* 1024 500)]
                     (large-file? max-size buf)))})

;; Get filetypes available in nvim-treesitter by
;; `fd folds.scm -x echo {//} | sed 's#./queries/\(.*\)#:\1#' | sort`
(local filetypes-treesitter-fold ;
       [:bash
        :c
        :clojure
        :cmake
        :cpp
        :css
        :ecma
        :fish
        :go
        :html
        :javascript
        :json
        :jsonc
        :jsx
        :julia
        :kotlin
        :latex
        :lua
        :make
        :markdown
        :ninja
        :nix
        :ocaml
        :ocaml_interface
        :python
        :query
        :rasi
        :rust
        :scala
        :scheme
        :svelte
        :teal
        :toml
        :tsx
        :typescript
        :vim
        :yaml])

(augroup! :rcTreesitter/SetFold
          (au! :FileType [:pattern filetypes-treesitter-fold]
               (fn []
                 (let [fdm vim.wo.foldexpr]
                   (when (= fdm :0)
                     (setlocal! :foldMethod :expr)
                     (setlocal! :foldExpr "nvim_treesitter#foldexpr()"))))))
