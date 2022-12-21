(import-macros {: dec : cmap!} :my.macros)

(pcall #(cmap! [:unique :expr] :<C-p> "wildmenumode() ? '<Left>' : '<Up>'"))
(pcall #(cmap! [:unique :expr] :<C-n> "wildmenumode() ? '<Right>' : '<Down>'"))

(cmap! :<C-r><C-v> [:desc "Paste Visualized" :expr]
       #(-> (vim.fn.getline :v)
            (: :sub (dec (vim.fn.col "'<")) (dec (vim.fn.col "'>")))))

;; Open CmdWin
(cmap! :<M-i> :<C-f>i)
(cmap! :<M-a> :<C-f>a)
(cmap! :<M-I> :<C-f>I)
(cmap! :<M-A> :<C-f>A)

;; Stop Cmdline mode
(cmap! :<M-h> :<C-c>)
(cmap! :<M-k> :<C-c>)
(cmap! :<M-l> :<C-c>)

(cmap! :<C-a> :<Home>)
(cmap! :<M-f> :<S-Right>)
(cmap! :<M-b> :<S-Left>)

;; `<Space><BS>` matters if wildmenumode() returns true.
(cmap! :<C-f> :<Space><BS><Right>)
(cmap! :<C-b> :<Space><BS><Left>)

(cmap! :<C-d> :<Del>)
(cmap! :<C-k> [:expr :desc "Remove chars to end"]
       #(let [line (vim.fn.getcmdline)
              col (vim.fn.getcmdpos)
              times (+ 1 (- (length line) col))]
          (-> :<Del> (: :rep times))))

(cmap! :<M-d> [:expr :desc "Remove to word end"]
       #(let [line (vim.fn.getcmdline)
              col (vim.fn.getcmdpos)
              text-after-cursor (line:sub col)
              wordend-pos (text-after-cursor:match "[a-z]*()")]
          (-> :<Del> (: :rep wordend-pos))))
