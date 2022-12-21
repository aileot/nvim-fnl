;; TOML: browse.toml
;; Repo: tamago324/lir.nvim

(import-macros {: nmap! : <Cmd>} :my.macros)

(local netrw (require :my.lazy.netrw))

(netrw.disable-netrw)
(netrw.idle-network-autocmds)

(nmap! :<Space>f<Space> (<Cmd> "top 40 vs %:p:h"))

(nmap! :<Space>fe (<Cmd> "e %:p:h"))
(nmap! :<Space>fs (<Cmd> "sp %:p:h"))
(nmap! :<Space>fv (<Cmd> "vs %:p:h"))
(nmap! :<Space>ft (<Cmd> "tabe %:p:h"))
