;; TOML: browse.toml
;; Repo: tamago324/lir.nvim

(import-macros {: nnoremap! : <Cmd>} :my.macros)

(local netrw (require :my.lazy.netrw))

(netrw.disable-netrw)
(netrw.idle-network-autocmds)

(nnoremap! :<Space>f<Space> (<Cmd> "top 40 vs %:p:h"))

(nnoremap! :<Space>fe (<Cmd> "e %:p:h"))
(nnoremap! :<Space>fs (<Cmd> "sp %:p:h"))
(nnoremap! :<Space>fv (<Cmd> "vs %:p:h"))
(nnoremap! :<Space>ft (<Cmd> "tabe %:p:h"))
