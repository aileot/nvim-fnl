;; TOML: default_mapping.toml
;; Repo: monaqa/dial.nvim

(import-macros {: map! : <Plug>} :my.macros)

(map! [:n :x] [:remap] :<C-a> (<Plug> :dial-increment))
(map! [:n :x] [:remap] :<C-x> (<Plug> :dial-decrement))
(map! [:x] [:remap] :g<C-a> (.. :g (<Plug> :dial-increment)))
(map! [:x] [:remap] :g<C-x> (.. :g (<Plug> :dial-decrement)))

;; Note: dial.nvim will not interpret as Vim script expression for `"=`, but
;; will as a literal string.

(map! [:n :x] [:remap :expr :silent] :z<C-a>
      #(.. "\"=" vim.bo.filetype :<CR> (<Plug> :dial-increment)))

(map! [:n :x] [:remap :expr :silent] :z<C-x>
      #(.. "\"=" vim.bo.filetype :<CR> (<Plug> :dial-decrement)))

(map! [:x] [:remap :expr :silent] :gz<C-a>
      #(.. "\"=" vim.bo.filetype :<CR> :g (<Plug> :dial-increment)))

(map! [:x] [:remap :expr :silent] :gz<C-x>
      #(.. "\"=" vim.bo.filetype :<CR> :g (<Plug> :dial-decrement)))
