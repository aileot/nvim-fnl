;; TOML: browse.toml
;; Repo: lambdalisue/fern.vim

(import-macros {: directory? : printf : augroup! : au! : nmap!} :my.macros)

(local netrw (require :my.lazy.netrw))

(netrw.disable-netrw)
(netrw.idle-network-autocmds)

(augroup! :rcFernAdd
  (au! :BufEnter [:nested :desc "[fern] replace directory"]
       #(let [path $.match]
          (when (directory? path)
            (vim.cmd (printf "keepjumps keepalt Fern %s
                              silent! bwipeout %d"
                             (vim.fn.fnameescape path) ;
                             $.buf))))))

(fn smart-path []
  (let [dir (vim.fn.expand "%:p:h")
        ?dir-under-protocol (dir:match "^.*://(.-)$")]
    (if (and ?dir-under-protocol (directory? ?dir-under-protocol))
        ?dir-under-protocol
        (directory? dir)
        dir
        (vim.fn.fnamemodify "." ":p"))))

(fn open-filer []
  (let [args [(smart-path) "-reveal=%:p"]]
    (vim.cmd.Fern {: args})))

(nmap! :<Space>fe `open-filer)
(nmap! :<Space>fs (fn []
                    (vim.cmd.sp)
                    (open-filer)))

(nmap! :<Space>fv (fn []
                    (vim.cmd.vs)
                    (open-filer)))

(nmap! :<Space>ft (fn []
                    (vim.cmd "sp|wincmd T")
                    (open-filer)))
