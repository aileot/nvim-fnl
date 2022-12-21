;; From: default_mapping.toml
;; Repo: tpope/vim-repeat

(import-macros {: imap! : nmap! : <Cmd>} :my.macros)

;; Note: <C-o><Plug>(RepeatUndo/Redo) works wrong only to insert "u".
;; TODO: Make <C-o>u always jump cursor to the end of the last undone position

(imap! :<C-o>u :<Esc>ua)
(imap! :<C-o><C-r> :<C-o><C-r>)

;; Prefer `:<C-u>` to `<Cmd>` to remind me of dot-repeat.
(nmap! "@@" "@@:<C-u>call repeat#set('@@')<CR>")

(nmap! [:expr :desc "Repeatable `dk`"] :dk
       #(.. :dk ;
            (if (= (vim.fn.line ".") (vim.fn.line "$")) "" :k)
            (<Cmd> "call repeat#set('dk')")))
