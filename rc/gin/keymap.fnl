;; TOML: git.toml
;; Repo: lambdalisue/gin.vim

(import-macros {: printf : nmap! : <Cmd>} :my.macros)

(local {: confirm? : git-get-config} (require :my.utils))

(nmap! :<Space>grP #(let [{: remote-url : merge-branch : current-branch} ;
                          (git-get-config)]
                      (when (confirm? (printf "[git] Push to %s?" remote-url))
                        (<Cmd> "Gin push"))))

(nmap! :<Space>grp (<Cmd> "Gin pull | e!"))
