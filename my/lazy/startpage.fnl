(import-macros {: setlocal!} :my.macros)

;; If no files are assigned in the initial cmdline argument.
(when (and (= (vim.fn.argc) 0) (= (vim.fn.line2byte "$") -1))
  (let [term_args (if (= 1 (vim.fn.executable :fish)) :fish
                      (= 1 (vim.fn.executable :bash)) :bash
                      :sh)]
    (vim.fn.termopen term_args)
    (setlocal! :number false)
    (setlocal! :signcolumn :no)))
