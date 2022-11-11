(import-macros {: nnoremap! : noremap! : <Cmd>} :my.macros)

(local {: execute! : with-lazyredraw!} (require :my.utils))

(local expand vim.fn.expand)
(local executable vim.fn.executable)

(nnoremap! [:desc ":edit <cfile>"] :gf :gF)
(nnoremap! [:desc ":split <cfile>"] :<C-w>f :<C-w>F)
(nnoremap! [:desc ":vsplit <cfile>"] :<C-w>F (<Cmd> "vertical wincmd F"))
(nnoremap! [:desc ":tabe <cfile>"] :<C-w>gf :<C-w>gF)

;; Disable some default keys ///1
(noremap! [:n :o :v] :<F1> :<Nop>)
(nnoremap! [:desc :Interrupt] :<C-w><C-c> :<C-c>)
(nnoremap! :<C-w>q :<Nop>)
(nnoremap! :<C-w><C-q> :<Nop>)

;; Mnemonic: Enumerate Messages
(nnoremap! [:desc "Show Messages"] :<Space>em (<Cmd> :messages))

;; Open CmdWin
(nnoremap! [:desc "CmdWin Search"] :g/ :q/kzb)
(nnoremap! [:desc "CmdWin Reverse Search"] :g? :q/kzb)
(nnoremap! [:desc "CmdWin Command"] "g:" :q/kzb)

(let [highlight-off! #(execute! :noh :redraw!
                                (when vim.wo.diff
                                  :diffupdate))]
  (nnoremap! :<C-Space><Space> highlight-off!)
  (nnoremap! :<C-Space><C-Space> highlight-off!))

(let [highlight-off! #(execute! :noh :mode)]
  ;; FIXME: In cmdline mode, it doesn't stop highlights.
  (noremap! [:c :i] :<C-l> highlight-off!))

;; Copy Window ///1
(let [copy-current-buffer-to-new-tab (with-lazyredraw! :<C-w>v<C-w>T)]
  (nnoremap! [:<command>] :<C-w>gt copy-current-buffer-to-new-tab)
  (nnoremap! [:<command>] :<C-w>gT copy-current-buffer-to-new-tab))

(let [copy-buffer-to-another-instance ;
      #(let [cmd (if (executable :wezterm)
                     [:wezterm
                      :--config
                      :scrollback_lines=0
                      :start
                      "--"
                      :nvim
                      (expand "%:p")
                      "&"] (executable :alacritty)
                     [:alacritty
                      :--option
                      :scrolling.history=0
                      :-e
                      :sh
                      :-c
                      (expand "sleep 0.1 && nvim %:p &")]
                     (executable :nvim-qt) [:nvim-qt "%:p" "&"])]
         (vim.fn.system cmd))]
  (nnoremap! :<C-w><Space>T #(copy-buffer-to-another-instance))
  (nnoremap! :<C-w><Space>t #(copy-buffer-to-another-instance)))

;; Close Window ///1
(nnoremap! :<C-w>O (<Cmd> :tabonly))
(nnoremap! :Zz :ZZ)
(nnoremap! :Zq :ZQ)
;; (nnoremap! :<C-w>z :ZZ) ;; :pclose
(nnoremap! :<C-w>q :ZQ)
(nnoremap! :<C-w>Z :ZZ)
(nnoremap! :<C-w>Q :ZQ)

(let [close-current-tabpage ;
      ;; Note: `:tabclose` instead fails to close the last tab page.
      (<Cmd> "up | windo normal! ZQ")]
  (nnoremap! [:<command>] :ZC close-current-tabpage)
  (nnoremap! [:<command>] :Zc close-current-tabpage)
  (nnoremap! [:<command>] :<C-w>C close-current-tabpage))

(let [eliminate-current-tabpage (<Cmd> "windo normal! ZQ")]
  (nnoremap! [:<command>] :ZE eliminate-current-tabpage)
  (nnoremap! [:<command>] :Ze eliminate-current-tabpage)
  (nnoremap! [:<command>] :<C-w>e eliminate-current-tabpage)
  (nnoremap! [:<command>] :<C-w>E eliminate-current-tabpage))

;; Mnemonic: $ yes
(nnoremap! :ZY (<Cmd> :qa))
(nnoremap! :Zy (<Cmd> :qa))
(nnoremap! :ZN (<Cmd> :xa))
(nnoremap! :Zn (<Cmd> :xa))

;; Move in Windows ///1
;; Move to an adjacent window
(nnoremap! :<M-h> :<C-w>h)
(nnoremap! :<M-j> :<C-w>j)
(nnoremap! :<M-k> :<C-w>k)
(nnoremap! :<M-l> :<C-w>l)

;; Regard cmdline as a window to leave
(noremap! :c :<M-k> :<Esc>)

;; Move in Tabpages ///1
(nnoremap! :<C-h> :gT)
(nnoremap! :<C-l> :gt)

;; Swap Windows ///1
(nnoremap! :<M-S-h> :<C-w>H)
(nnoremap! :<M-S-j> :<C-w>J)
(nnoremap! :<M-S-k> :<C-w>K)
(nnoremap! :<M-S-l> :<C-w>L)

;; Resize Window ///1
;; Resize Width
(nnoremap! :<C-S-h> :<C-w><)
(nnoremap! :<C-S-l> :<C-w>>)
;; Resize Height
(nnoremap! :<C-S-j> :<C-w>-)
(nnoremap! :<C-S-k> :<C-w>+)
