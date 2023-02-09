(import-macros {: if-not : imap! : input-map! : swap-map!} :my.macros)

(swap-map! "!" :<C-v> :<C-S-v>)

(input-map! :<C-v><Space> :<lt>Space>)

(imap! [:remap] :<C-r><C-0> :<C-r>0)
(imap! [:remap] :<C-r><Space> :<C-r>+)
(imap! [:remap] :<C-r><C-Space> :<C-r>*)
(imap! [:remap] "<C-r>'" "<C-r>\"")
(imap! [:remap] "<C-r><C-'>" "<C-r>\"")
(imap! [:remap] "<C-r>;" "<C-r>:")
(imap! [:remap] "<C-r><C-;>" "<C-r>:")

(imap! :<C-Space> :<C-g>U<Right><Space>)
(imap! :<S-Space> [:desc "Insert space behind cursor"] :<Space><C-g>U<Left>)

(imap! [:expr] :<C-k> #(if (= (vim.fn.col "$") (vim.fn.col ".")) :<C-g>U<Del>
                           "<C-o>\"_D"))

;; Note: <C-\><C-o> to restore cursor position expectedly.
(imap! :<C-o>y :<C-BSlash><C-o>y)
(imap! :<C-o>Y :<C-BSlash><C-o>y$)
(imap! :<C-o><Space>y "<C-BSlash><C-o>\"+y")
(imap! :<C-o><Space>Y "<C-BSlash><C-o>\"+Y")

;; Note: Adjust cursor position for operator mapleaders.
;; Note: `<Esc>l` instead fails to continue keys at the end of line.
(imap! [:remap] "<M-~>" "<Right><Esc>~")
(imap! [:remap] :<M-g> :<Right><Esc>g)
(imap! [:remap] :<M-BSlash> :<Right><Esc><BSlash>)
(imap! [:remap] :<M-Space> :<Right><Esc><Space>)

(imap! :<C-b> :<C-g>U<Left>)
(imap! :<C-f> :<C-g>U<Right>)
(imap! :<M-i> :<C-g>U<Left>)
(imap! :<M-a> :<C-g>U<Right>)
(imap! :<M-S-A> [:expr :literal] "repeat('<C-G>U<Right>', col('$') - col('.'))")
(imap! :<M-S-I> [:expr]
       #(let [col (vim.fn.col ".")
              line (vim.fn.getline ".")
              left :<C-g>U<Left>
              right :<C-g>U<Right>
              first-non-space-col (line:find "%S")]
          (if (= col first-non-space-col)
              ""
              ;; (left:rep col)
              (< col first-non-space-col)
              (right:rep (- first-non-space-col col))
              (left:rep (- col first-non-space-col)))))

;; (fn wordy-motion [keys]
;;   (let [isk vim.bo.iskeyword
;;         lisp? vim.bo.lisp]
;;     (set vim.bo.iskeyword "@")
;;     (set vim.bo.lisp false)
;;     (.. keys (<Cmd> "setlocal isk=" isk :lisp= lisp?))))

;; (imap! :<M-b> [:expr] #(wordy-motion :<C-g>U<S-Left><C-g><Right>))
;; (imap! :<M-f> [:expr] #(wordy-motion :<C-g>U<S-Right><C-g><Left>))

(imap! :<C-d> :<C-g>U<Del>)
(imap! :<C-S-t> :<C-d>)

(imap! :<C-g>D [:desc "Delete all indent in current line"] :^<C-d>)
(imap! :<C-g>= [:desc "Reindent current line"] :<C-BSlash><C-o>=)

;; Note: The lhs could be different up to terminal.
(imap! [:remap] "<C-S-;>" "<C-:>")
(imap! [:remap] "<C-S-:>" "<C-:>")

(fn followed? []
  (vim.fn.search "\\%#." :cnzW))

(fn enclosed? []
  (vim.fn.search "\\%#.*[\\])}]" :cnzW))

(fn goto-next-closed-end []
  (let [pat-closed-end ".-[%])]"
        col (vim.fn.col ".")
        line (vim.fn.getline ".")
        following-chars (line:sub col)
        times (length (following-chars:match pat-closed-end))
        right :<C-g>U<Right>]
    (right:rep times)))

(imap! [:expr] "<C-,>"
       #(if-not (followed?)
          ", "
          (if (enclosed?) "<C-g>U<Right>, " "<C-g>U<Right>,")))

(imap! [:expr] "<C-;>"
       #(if-not (followed?)
          "; "
          (if (enclosed?) "<C-g>U<Right>; " "<C-g>U<Right>;")))

(imap! [:expr] :<C-=> #(if (followed?) "<C-g>U<Right> = " "= "))

(imap! [:expr] :<C-.> #(if-not (followed?)
                         ". "
                         (if (enclosed?)
                             (.. (goto-next-closed-end) ".")
                             "<C-g>U<Right>. ")))

(imap! [:expr] "<C-:>" #(if-not (followed?)
                          ": "
                          (if (enclosed?)
                              (.. (goto-next-closed-end) ":")
                              "<C-g>U<Right>: ")))

(imap! [:remap] :<C-1> :<C-!>)
(imap! [:expr] :<C-!> #(if-not (followed?)
                         "! "
                         (if (enclosed?)
                             (.. (goto-next-closed-end) "!")
                             "<C-g>U<Right>! ")))
