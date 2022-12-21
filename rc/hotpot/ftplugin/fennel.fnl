;; TOML: init.toml
;; Repo: rktjmp/hotpot.nvim

(import-macros {: nmap! : <Plug>} :my.macros)

;; Mnemonic: Evaluate expression.

(nmap! :<BSlash>e (<Plug> :hotpot-operator-eval))

nil
