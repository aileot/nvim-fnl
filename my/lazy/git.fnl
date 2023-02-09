(import-macros {: nmap! : echo!} :my.macros)

(local {: git} (require :my.utils))

(nmap! :<Space>gcc [:desc "[git] commit prompt"]
       (fn []
         (match (pcall vim.fn.input "[git] commit message: ")
           (false "Keyboard interrupt") (echo! "[git] abort")
           (true msg) (do
                        (git [:commit :-m msg])))))
