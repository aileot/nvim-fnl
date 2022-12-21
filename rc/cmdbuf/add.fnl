;; TOML: default.toml
;; Repo: notomo/cmdbuf.nvim

(import-macros {: if-not : feedkeys! : nmap! : cmap! : setlocal!} :my.macros)

(fn open-cmdbuf-from-normal-mode [opts]
  (let [{: split_open} (require :cmdbuf)]
    (split_open vim.go.cmdwinheight opts)
    (feedkeys! :Gi :ni)))

(fn open-cmdbuf-from-cmdline []
  (let [{: split_open} (require :cmdbuf)
        cmd-line (vim.fn.getcmdline)
        cmd-pos (vim.fn.getcmdpos)
        cmd-type (vim.fn.getcmdtype)
        ?lua-cmdline (cmd-line:match "^%s*lua%s(.*)$")
        cmdbuf-type (match cmd-type
                      ":" (if ?lua-cmdline :lua/cmd :vim/cmd)
                      "/" :vim/search/forward
                      "?" :vim/search/backward)
        lua-expr? (cmdbuf-type:match :^lua/)
        cmdbuf-pos (if-not lua-expr?
                     cmd-pos
                     (+ cmd-pos (- (length ?lua-cmdline) (length cmd-line))))]
    (split_open vim.go.cmdwinheight
                {:line cmd-line :column cmdbuf-pos :type cmdbuf-type})
    (when lua-expr?
      (setlocal! :filetype :lua))
    (let [insert-key (if (< (length cmd-line) cmd-pos) :a :i)
          keys (.. :<C-c> insert-key)]
      (feedkeys! keys :ni))))

(cmap! "<C-]>" #(open-cmdbuf-from-cmdline))

(nmap! "z:" #(open-cmdbuf-from-normal-mode {:type :lua/cmd}))
(nmap! "g:" #(open-cmdbuf-from-normal-mode {:type :vim/cmd}))
(nmap! :g/ #(open-cmdbuf-from-normal-mode {:type :vim/search/forward}))
(nmap! :g? #(open-cmdbuf-from-normal-mode {:type :vim/search/backward}))
