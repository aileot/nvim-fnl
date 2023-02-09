;; TOML: operator.toml
;; Repo: echasnovski/mini.surround

;; WIP
(import-macros {: nmap! : xmap! : motion-map!} :my.macros)

(macro operator [name ?opts]
  `(let [surround# (require :mini.surround)]
     (surround#.operator ,name ,?opts)))

(macro operator-find [opts]
  `(let [surround# (require :mini.surround)]
     (.. (surround#.operator :find ,opts) " ")))

;; Mnemonic: Yield

(nmap! :<BSlash>y [:expr] #(operator :add))
(nmap! :<BSlash>d [:expr] #(operator :delete))
(nmap! :<BSlash>c [:expr] #(operator :replace))
(xmap! :<BSlash>y [:expr] #((operator :add) :visual))
(xmap! :<BSlash>d [:expr] #((operator :delete) :visual))
(xmap! :<BSlash>c [:expr] #((operator :replace) :visual))

(let [to-end "$"]
  (nmap! :<BSlash>Y [:expr] #(.. (operator :add) to-end))
  (nmap! :<BSlash>D [:expr] #(.. (operator :delete) to-end))
  (nmap! :<BSlash>C [:expr] #(.. (operator :replace) to-end)))

(let [current-line :Vl]
  (nmap! :<BSlash>yy [:expr] #(.. (operator :add) current-line)))

(motion-map! "[<BSlash>" [:expr] #(operator-find {:direction :left}))
(motion-map! "]<BSlash>" [:expr] #(operator-find {:direction :right}))
(motion-map! "[<C-p>" [:expr :literal]
             #(operator-find {:direction :left :search_method :prev}))

(motion-map! "[<C-n>" [:expr :literal]
             #(operator-find {:direction :left :search_method :prev}))

(motion-map! "]<C-p>" [:expr :literal]
             #(operator-find {:direction :right :search_method :prev}))

(motion-map! "]<C-n>" [:expr :literal]
             #(operator-find {:direction :right :search_method :prev}))
