(import-macros {: nil?} :my.macros)

(lambda fallback [path _bufnr _matched]
  "Fallback to check filetype through `path` backwards.
  - /path/to/foo.vim.bk -> vim
  - /path/to/lua/foobar -> lua"
  (var ?rest-path path)
  (var ?filetype nil)
  (let [pat-preceding "^(.+)[./\\]"
        pat-filename "[/\\](.+)-$"]
    (while (and ?rest-path (nil? ?filetype))
      (let [?filename (?rest-path:match pat-filename)]
        (when ?filename
          (set ?filetype (vim.filetype.match {:filename ?filename}))))
      (set ?rest-path (?rest-path:match pat-preceding)))
    ?filetype))

(local pattern {".*/%.?xkb/.*" :xkb
                ".*/%.?Xresources%.d/.*" :xdefaults
                :.* {1 fallback :priority (- math.huge)}})

(local filename {:gitconfig :gitconfig})

(vim.filetype.add {: pattern : filename})
