;; TOML: shell.toml
;; Repo: lambdalisue/suda.vim

(import-macros {: printf : command! : echo!} :my.macros)

(lambda path->suda [path]
  (.. "suda://" path))

(lambda sudo-write [path]
  (if vim.bo.modified
      (vim.cmd.update (path->suda path))
      (echo! (printf "%s is not modified" path))))

(command! :Sudo [:bar :nargs "+" :complete :shellcmd] ;
          #(vim.fn.suda#system $.fargs))

(command! :W [:bar :nargs "*" :complete :file]
          #(let [paths $.fargs]
             (if (= 0 (length paths))
                 (sudo-write "%:p")
                 (each [_ path (ipairs paths)]
                   (let [full-path (vim.fs.normalize path)]
                     (sudo-write full-path))))))
