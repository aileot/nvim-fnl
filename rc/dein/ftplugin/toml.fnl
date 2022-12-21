;; TOML: init.toml
;; Repo: Shougo/dein.vim

(import-macros {: augroup! : au! : setlocal! : expand} :my.macros)

(augroup! :rcDeinFtToml
  (au! :BufWinEnter [:*/nvim/*.toml] ;
       [:desc "dein: Set cursor to repo related to alternate config"]
       #(let [alt-path (expand "#:p")
              dir-list [:rc :ftplugin :add :post :source]
              is-config-file? ;
              (accumulate [matched? false ;
                           _ dir (ipairs dir-list) ;
                           &until matched?]
                (or matched? (alt-path:match (string.format "/%s/" dir))))]
          (when is-config-file?
            (let [repo-comment-pattern " Repo: (%S+/%S+)"
                  repo-name (accumulate [repo-name nil ;
                                         ;; TODO: earlier return
                                         line (io.lines alt-path) ;
                                         &until repo-name]
                              (or repo-name (line:match repo-comment-pattern)))]
              (when repo-name
                (local repo-pattern (.. "^[# ]*repo = .*\\zs" repo-name))
                ;; Start searching at the top of toml file.
                (vim.cmd.execute :1)
                (vim.fn.search repo-pattern :W)
                (when (= 0 vim.wo.foldenable)
                  (setlocal! :foldenable true)
                  (setlocal! :foldlevel 0))
                (vim.cmd.normal! :zzzv)))))))

nil
