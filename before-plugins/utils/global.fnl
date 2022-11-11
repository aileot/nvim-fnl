(fn get-func-definition [func]
  (let [info (debug.getinfo func)]
    (if (= :C info.what) "written in C"
        (let [source (info.source:match "^@?(.*)$")]
          (if (source:match :^vim/)
              (let [func-name (?. info :name)]
                (values (string.format "%s/lua/%s" vim.env.VIMRUNTIME source)
                        (if func-name
                            (.. "+/" func-name)
                            :+1))))))))

;; Ref: https://github.com/nanotee/nvim-lua-guide#tips-3
(fn _G.dump [...]
  (if (= 0 (length [...]))
      (do
        (print nil)
        ...)
      (let [args [...]]
        (if (= :function (type (. args 1)))
            (let [func (. args 1)
                  (file cmd-identifier) (get-func-definition func)]
              (_G.dump file)
              (when (and cmd-identifier
                         (= 1
                            (vim.fn.confirm "Go to definition?" "&Yes\n&no" 1)))
                (let [definition (if cmd-identifier
                                     (string.format "%s %s" cmd-identifier file)
                                     file)]
                  (vim.cmd (string.format "sp %s" definition))
                  (vim.cmd.normal! :zz)))
              file)
            (let [objects (vim.tbl_map vim.inspect args)]
              (print (unpack objects))
              ...)))))
