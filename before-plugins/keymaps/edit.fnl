(import-macros {: printf
                : nmap!
                : omni-map!
                : motion-map!
                : <Cmd>
                : setglobal!
                : au!
                : echo!} :my.macros)

(pcall #(omni-map! [:unique :remap] :<C-h> :<BS>))

(let [select-oldfile "browse filter ;^\\(term://\\)\\@!; oldfiles"]
  (nmap! :<Space>eo (<Cmd> select-oldfile))
  (nmap! :<Space>zo (<Cmd> select-oldfile)))

(let [select-recent-vimrcs "browse filter /config.*nvim.*\\.\\(vim\\|lua\\|fnl\\)$/ oldfiles"]
  (nmap! :<Space>ev (<Cmd> select-recent-vimrcs))
  (nmap! :<Space>zv (<Cmd> select-recent-vimrcs)))

;; Disable ///1
(nmap! :q :<Nop>)
(nmap! :Q :<Nop>)

;; Macro ///1
(nmap! [:expr :desc "Toggle macro recording"] :<S-CR>
       ;; Note: autocmd to notify on RecordingEnter/Leave instead is useless.
       #(let [register (vim.fn.reg_recording)
              start-recording? (= "" register)
              msg (if start-recording? "[macro] recording register:"
                      (printf "[macro] recorded to \"%s\"" register))]
          (if start-recording?
              (echo! msg)
              (vim.schedule #(echo! msg)))
          :q))

(nmap! [:expr :desc "Execute macro with &lazyredraw"] "@" ;
       (fn []
         ;; Note: Enable &lazyredraw only during macro execution; permanent
         ;; &lazyredraw could cause display errors.
         (setglobal! :lazyRedraw)
         (au! nil :CursorHold [:once] #(setglobal! :lazyRedraw false))
         "@"))

; omap/xmap should not move in display line.
(nmap! :j :gj)
(nmap! :k :gk)
(nmap! :gj :j)
(nmap! :gk :k)

(motion-map! [:expr :literal] :0 "&wrap ? 'g0' : '0'")
(motion-map! [:expr :literal] "^" "&wrap ? 'g^' : '^'")
(motion-map! [:expr :literal] "$" "&wrap ? 'g$' : '$'")
(motion-map! [:expr :literal] :g0 "&wrap ? '0' : 'g0'")
(motion-map! [:expr :literal] :g^ "&wrap ? '^' : 'g^'")
(motion-map! [:expr :literal] :g$ "&wrap ? '$' : 'g$'")

(nmap! [:desc "Sync file if modified, or write"] :<Space>w
       #(if vim.bo.modified
            (vim.cmd.update)
            (vim.cmd.checktime)))
