(import-macros {: set!} :my.macros)

(local {: contains?} (require :my.utils))

(fn auto-hlsearch [key]
  "Auto nohl when cursor moved by a key unrelated to search."
  ;; https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?utm_source=share&utm_medium=web2x&context=3
  (when (= "" (vim.fn.reg_executing))
    (let [mode (vim.fn.mode true)]
      (match vim.v.hlsearch
        1 (when (and (= :n mode)
                     (not (contains? [:n :N "*" "#" :g] (vim.fn.keytrans key))))
            (vim.cmd.noh))
        0 (when (or (mode:find :o)
                    (and (= :n mode)
                         (or (contains? [:y :d :c] (vim.fn.keytrans key))
                             (= vim.bo.filetype :WhichKey))))
            ;; TODO: Suggest gn/gN area in Operator-Pending mode.
            (set! :hlSearch true))))))

;; Export namespace IDs

{:auto-nohlsearch (vim.on_key auto-hlsearch)}
