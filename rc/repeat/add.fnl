;; From: default_mapping.toml
;; Repo: tpope/vim-repeat

(import-macros {: inoremap! : nnoremap!} :my.macros)

;; Note: <C-o><Plug>(RepeatUndo/Redo) works wrong only to insert "u".
;; TODO: Make <C-o>u always jump cursor to the end of the last undone position
(inoremap! :<C-o>u :<Esc>ua)
(inoremap! :<C-o><C-r> :<C-o><C-r>)

;; Prefer `:<C-u>` to `<Cmd>` to remind me of dot-repeat.
(nnoremap! "@@" "@@:<C-u>call repeat#set('@@')<CR>")
