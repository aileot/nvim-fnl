;; TOML: init.toml
;; Repo: rktjmp/hotpot.nvim

(import-macros {: valid-win? : set-cursor! : augroup! : au! : wo! : setglobal!}
               :my.macros)

(local {: del-augroup!} (require :my.utils))

(fn sync-scroll [{: file : buf}]
  (let [lua-file (vim.pesc file)
        prev-winnr (vim.fn.winnr "#")]
    (when (not= prev-winnr (vim.fn.winnr))
      (let [prev-buf-id (vim.fn.winbufnr prev-winnr)
            prev-win-id (vim.fn.win_getid prev-winnr)
            cur-win-id (vim.fn.win_getid)
            prev-buf-name (vim.pesc (vim.api.nvim_buf_get_name prev-buf-id))
            correlated? (when (prev-buf-name:match "%.fnl$")
                          (or (lua-file:match (prev-buf-name:gsub :fnl$ :lua))
                              (lua-file:match (prev-buf-name:gsub :fnl :lua))))]
        (when correlated?
          ;; Sync line number and go back to the Fennel source buffer.
          (let [cur-buf-id (vim.api.nvim_win_get_buf cur-win-id)
                last-row (vim.api.nvim_buf_line_count cur-buf-id)]
            (when (= last-row (vim.api.nvim_buf_line_count prev-buf-id))
              (let [prev-cursor (vim.api.nvim_win_get_cursor prev-win-id)
                    top-left [1 0]
                    save-lazyredraw vim.go.lazyredraw
                    save-eventignore vim.go.eventignore]
                (setglobal! :lazyredraw true)
                (setglobal! :eventignore :all)
                ;; Note: `:syncbind` instead sync all the windows in the tabpage.
                (set-cursor! cur-win-id top-left)
                (set-cursor! prev-win-id top-left)
                (wo! :wrap false)
                (wo! prev-win-id :wrap false)
                (wo! :scrollbind true)
                (wo! prev-win-id :scrollbind true)
                (set-cursor! cur-win-id prev-cursor)
                (set-cursor! prev-win-id prev-cursor)
                (setglobal! :lazyredraw save-lazyredraw)
                (setglobal! :eventignore save-eventignore))
              (let [id (augroup! (.. :rcHotpotAddSyncCursorLine buf))]
                (fn dismiss-scrollbind-group []
                  (when (valid-win? cur-win-id)
                    (wo! cur-win-id :scrollbind false))
                  (when (valid-win? prev-win-id)
                    (wo! prev-win-id :scrollbind false))
                  (pcall del-augroup! id))

                (au! id :BufWinLeave [:buffer buf] `dismiss-scrollbind-group)
                (au! id :BufWinLeave [:buffer prev-buf-id]
                     `dismiss-scrollbind-group)
                (au! id :WinLeave [:buffer buf] #(wo! :cursorline true))
                (au! id :WinLeave [:buffer prev-buf-id] #(wo! :cursorline true))
                (au! id [:CursorMoved :WinScrolled] [:buffer buf]
                     #(let [valid? ;
                            (pcall #(let [pos (vim.api.nvim_win_get_cursor cur-win-id)]
                                      (set-cursor! prev-win-id pos)))]
                        ;; Note: autocmd is deleted when callback for
                        ;; nvim_create_autocmd returns true.
                        (not valid?)))
                (au! id [:CursorMoved :WinScrolled] [:buffer prev-buf-id]
                     #(let [valid? ;
                            (pcall #(let [pos (vim.api.nvim_win_get_cursor prev-win-id)]
                                      (set-cursor! cur-win-id pos)))]
                        (not valid?))))
              (wo! prev-win-id :cursorline true))))))))

(augroup! :rcHotpotFtLua
  (au! :BufWinEnter [:*.lua] [:desc "Sync scroll to correlated Fennel buffer"]
       #(vim.schedule (fn []
                        (sync-scroll $)))))

;; nil
