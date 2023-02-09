(import-macros {: executable? : printf : first : nmap!} :my.macros)

(nmap! :<CR>dt [:desc "Start lazydocker in new tab"]
       (fn []
         (vim.cmd.tabe)
         (assert (executable? :lazydocker) "lazydocker is unavailable")
         (vim.cmd.term {:args [:lazydocker]})
         (vim.cmd.startinsert)))

(let [git-tui :lazygit]
  (nmap! :<CR>gt [:desc (printf "Start %s in new tab" git-tui)]
         #(let [path (vim.api.nvim_buf_get_name 0)
                dir (vim.fs.dirname path)
                matches (vim.fs.find [:.git]
                                     {:upward true
                                      :path dir
                                      :type :directory
                                      :stop vim.env.HOME})
                ?git-dir (when (< 0 (length matches))
                           (first matches))
                term/args [git-tui
                           (match git-tui
                             :gitui :--directory
                             :lazygit :--work-tree)
                           (vim.fs.dirname ?git-dir)
                           (match git-tui
                             :gitui :--workdir
                             :lazygit :--git-dir)
                           ?git-dir]]
            (when ?git-dir
              (vim.cmd.tabe)
              (assert (executable? git-tui) (.. git-tui " is unavailable"))
              (vim.cmd.term {:args term/args})
              (vim.cmd.startinsert)))))
