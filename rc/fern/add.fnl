;; TOML: browse.toml
;; Repo: lambdalisue/fern.vim

(import-macros {: nnoremap! : feedkeys!} :my.macros)

(fn smart-path []
  (let [dir (vim.fn.expand "%:p:h")
        ?dir-under-protocol (dir:match "^.*://(.-)$")]
    (if (and ?dir-under-protocol (vim.fn.isdirectory ?dir-under-protocol))
        ?dir-under-protocol
        (vim.fn.isdirectory dir)
        dir
        (vim.fn.fnamemodify "." ":p"))))

(fn open-filer []
  (let [args [(smart-path) "-reveal=%"]]
    (vim.cmd.Fern {: args})))

(nnoremap! :<Space>fe open-filer)
(nnoremap! :<Space>fs (fn []
                        (vim.cmd.sp)
                        (open-filer)))

(nnoremap! :<Space>fv (fn []
                        (vim.cmd.vs)
                        (open-filer)))

(nnoremap! :<Space>ft (fn []
                        (vim.cmd.sp)
                        (feedkeys! :<C-w>T :ni)
                        (open-filer)))
