;; TOML: shell.toml
;; Repo: lambdalisue/suda.vim

(import-macros {: file-writable? : printf : expand : nmap!} :my.macros)

(local {: confirm?} (require :my.utils))

(nmap! :<Space>W [:desc "Forcefully write %:p"]
       #(if (file-writable?)
            (when (confirm? (printf "Forcefully write to %q?" (expand "%:p")))
              (vim.cmd.w!))
            (vim.cmd.SudaWrite)))
