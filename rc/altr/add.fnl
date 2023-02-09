;; TOML: browse.toml
;; Repo: kana/vim-altr

;; cspell:word altr

(import-macros {: nmap! : <Cmd> : <Plug>} :my.macros)

(nmap! [:desc "[altr] :edit <next-file>"] "]a" (<Plug> :altr-forward))
(nmap! [:desc "[altr] :edit <previous-file>"] "[a" (<Plug> :altr-back))

(macro next-altr-prefix [cmd-prefix]
  `(.. (<Cmd> ,cmd-prefix) (<Plug> :altr-forward)))

(macro previous-altr-prefix [cmd-prefix]
  `(.. (<Cmd> ,cmd-prefix) (<Plug> :altr-backward)))

(nmap! [:desc "[altr] :split <next-file>"] "<C-w>]a"
       &vim (.. :<C-w>s (<Plug> :altr-forward)))

(nmap! [:desc "[altr] :split <previous-file>"] "<C-w>[a"
       &vim (.. :<C-w>s (<Plug> :altr-back)))

(nmap! [:desc "[altr] :vsplit <next-file>"] "<C-w>]A"
       &vim (.. :<C-w>v (<Plug> :altr-forward)))

(nmap! [:desc "[altr] :vsplit <previous-file>"] "<C-w>[A"
       &vim (.. :<C-w>v (<Plug> :altr-back)))

(nmap! [:desc "[altr] :split <next-file>"] "]<C-w>a"
       &vim (.. :<C-w>s (<Plug> :altr-forward)))

(nmap! [:desc "[altr] :split <previous-file>"] "[<C-w>a"
       &vim (.. :<C-w>s (<Plug> :altr-back)))

(nmap! [:desc "[altr] :vsplit <next-file>"] "]<C-w>A"
       &vim (.. :<C-w>v (<Plug> :altr-forward)))

(nmap! [:desc "[altr] :vsplit <previous-file>"] "[<C-w>A"
       &vim (.. :<C-w>v (<Plug> :altr-back)))

;; Open related buffer in new Tab

(nmap! [:desc "[altr] <next-file> in new tab"] "<C-w>]ga"
       &vim (.. :<C-w>s<C-w>T (<Plug> :altr-forward)))

(nmap! [:desc "[altr] <previous-file> in new tab"] "<C-w>[ga"
       &vim (.. :<C-w>s<C-w>T (<Plug> :altr-back)))

(nmap! [:desc "[altr] <next-file> in new tab"] "]<C-w>ga"
       &vim (.. :<C-w>s<C-w>T (<Plug> :altr-forward)))

(nmap! [:desc "[altr] <previous-file> in new tab"] "[<C-w>ga"
       &vim (.. :<C-w>s<C-w>T (<Plug> :altr-back)))
