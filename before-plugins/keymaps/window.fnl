(import-macros {: nmap! : map! : <Cmd>} :my.macros)

(local {: execute!} (require :my.utils))

(nmap! [:desc ":edit <cfile>"] :gf :gF)
(nmap! [:desc ":split <cfile>"] :<C-w>f :<C-w>F)
(nmap! [:desc ":vsplit <cfile>"] :<C-w>F (<Cmd> "vertical wincmd F"))
(nmap! [:desc ":tabe <cfile>"] :<C-w>gf :<C-w>gF)

;; Disable some default keys ///1
(map! [:n :o :v] :<F1> :<Nop>)
(nmap! [:desc :Interrupt] :<C-w><C-c> :<C-c>)
(nmap! :<C-w>q :<Nop>)
(nmap! :<C-w><C-q> :<Nop>)

;; Mnemonic: Enumerate Messages
(nmap! [:desc "Show Messages"] :<Space>em (<Cmd> :messages))

;; Open CmdWin
(nmap! [:desc "CmdWin Search"] :g/ :q/kzb)
(nmap! [:desc "CmdWin Reverse Search"] :g? :q/kzb)
(nmap! [:desc "CmdWin Command"] "g:" :q/kzb)

(let [highlight-off! #(execute! :noh :redraw!
                                (when vim.wo.diff
                                  :diffupdate))]
  (nmap! :<C-Space><Space> highlight-off!)
  (nmap! :<C-Space><C-Space> highlight-off!))

;; Close Window ///1
(nmap! :<C-w>O (<Cmd> :tabonly))
(nmap! :Zz :ZZ)
(nmap! :Zq :ZQ)
;; (nmap! :<C-w>z :ZZ) ;; :pclose
(nmap! :<C-w>q :ZQ)
(nmap! :<C-w>Z :ZZ)
(nmap! :<C-w>Q :ZQ)

;; Note: `:tabclose` instead fails to close the last tab page.
(nmap! :ZC (<Cmd> "up | windo normal! ZQ"))
(nmap! [:remap] :Zc :ZC)
(nmap! [:remap] :<C-w>C :ZC)

(nmap! :ZE (<Cmd> "windo normal! ZQ"))
(nmap! [:remap] :Ze :ZE)
(nmap! [:remap] :<C-w>e :ZE)
(nmap! [:remap] :<C-w>E :ZE)

;; Mnemonic: $ yes
(nmap! :ZY (<Cmd> :qa))
(nmap! :ZN (<Cmd> :xa))
(nmap! [:remap] :Zy :ZY)
(nmap! [:remap] :Zn :ZN)

;; Move in Windows ///1
;; Move to an adjacent window
(nmap! :<M-h> :<C-w>h)
(nmap! :<M-j> :<C-w>j)
(nmap! :<M-k> :<C-w>k)
(nmap! :<M-l> :<C-w>l)

;; Regard cmdline as a window to leave
(map! :c :<M-k> :<Esc>)

;; Move in Tabpages ///1
(nmap! :<C-h> :gT)
(nmap! :<C-l> :gt)

;; Swap Windows ///1
(nmap! :<M-S-h> :<C-w>H)
(nmap! :<M-S-j> :<C-w>J)
(nmap! :<M-S-k> :<C-w>K)
(nmap! :<M-S-l> :<C-w>L)

;; Resize Window ///1
;; Resize Width
(nmap! :<C-S-h> :<C-w><)
(nmap! :<C-S-l> :<C-w>>)
;; Resize Height
(nmap! :<C-S-j> :<C-w>-)
(nmap! :<C-S-k> :<C-w>+)
