(import-macros {: cnoremap!} :my.macros)

(cnoremap! :<C-v><Space> :<lt>space>)

(pcall #(cnoremap! [:unique :expr] :<C-p> "wildmenumode() ? '<Left>' : '<Up>'"))
(pcall #(cnoremap! [:unique :expr] :<C-n>
                   "wildmenumode() ? '<Right>' : '<Down>'"))

(cnoremap! :<C-r><C-v> [:desc "Paste Visualized" :expr]
           #(-> (vim.fn.getline :v)
                (: :sub (- 1 (vim.fn.col "'<")) (- 1 (vim.fn.col "'>")))))

;; Open CmdWin
(cnoremap! :<M-i> :<C-f>i)
(cnoremap! :<M-a> :<C-f>a)
(cnoremap! :<M-I> :<C-f>I)
(cnoremap! :<M-A> :<C-f>A)

;; Stop Cmdline mode
(cnoremap! :<M-h> :<C-c>)
(cnoremap! :<M-k> :<C-c>)
(cnoremap! :<M-l> :<C-c>)

(cnoremap! :<C-a> :<Home>)
(cnoremap! :<M-f> :<S-Right>)
(cnoremap! :<M-b> :<S-Left>)

;; `<Space><BS>` matters if wildmenumode() returns true.
(cnoremap! :<C-f> :<Space><BS><Right>)
(cnoremap! :<C-b> :<Space><BS><Left>)

(cnoremap! :<C-d> :<Del>)
(cnoremap! :<C-k> [:expr :desc "Remove chars to end"]
           #(let [line (vim.fn.getcmdline)
                  col (vim.fn.getcmdpos)
                  times (+ 1 (- (length line) col))]
              (-> :<Del> (: :rep times))))

(cnoremap! :<M-d> [:expr :desc "Remove to word end"]
           #(let [line (vim.fn.getcmdline)
                  col (vim.fn.getcmdpos)
                  text-after-cursor (line:sub col)
                  wordend-pos (text-after-cursor:match "[a-z]*()")]
              (-> :<Del> (: :rep wordend-pos))))
