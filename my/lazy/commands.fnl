;; Note: Importing macros from `my.macros` the by-pass file instead crashes
;; nvim with the error message:
;;   :nvim: /home/runner/work/neovim/neovim/src/nvim/message.c:2028:
;;   msg_puts_after_len:
;;   Assertion `len < 0 || memchr(str, 0, (size_t)len) == NULL` failed.
(import-macros {: command!} :my.macros)

(local normalize vim.fs.normalize)

(let [log-file (normalize :$XDG_STATE_HOME/nvim/lsp.log)
      file-size (-> (vim.fn.system [:du :--human-readable log-file])
                    (string.match "^%S+"))]
  (command! :LspLogPeek
            #(let [max-lines 100]
               (print (.. "Path: " log-file "\n" ;
                          "File Size: " file-size "\n" ;
                          "The last " max-lines " lines:\n"
                          (vim.fn.system [:tail :-n max-lines log-file])))))
  (command! :LspLogClear
            #(let [max-lines 10
                   excerpt (vim.fn.system [:tail
                                           :-n
                                           max-lines
                                           :--quiet
                                           log-file])]
               (if (not= 2
                         (vim.fn.confirm (.. "Delete " log-file "?\n"
                                             "File Size: " file-size "\n"
                                             "The last " max-lines " lines:\n"
                                             excerpt)
                                         "&No\n&yes"))
                   (vim.notify :abort)
                   (if (= 0 (vim.fn.delete log-file))
                       (vim.notify (.. log-file " is successfully removed")
                                   vim.log.levels.INFO)
                       (vim.notify (.. log-file " does not exist")
                                   vim.log.levels.WARN))))))

(command! :CClear ":noautocmd cexpr []" {:bar true :desc "Clear Quickfix list"})
(command! :LClear ":noautocmd lexpr []" {:bar true :desc "Clear Location list"})

(command! :DiffOrig #(vim.cmd "
vertical above new
setlocal buftype=nofile
r#
silent 0d_
diffthis
wincmd p
diffthis
setlocal diffopt=vertical,indent-heuristic,algorithm:histogram
"))
