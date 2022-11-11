;; TOML: fennel.toml
;; Repo: rktjmp/hotpot.nvim

(import-macros {: ->nil
                : printf
                : first
                : second
                : setglobal!
                : command!
                : augroup!
                : au!} :my.macros)

(local {: del-augroup!} (require :my.utils))

(command! :HotpotCacheClear
          "call delete(expand('$XDG_CACHE_HOME/nvim/hotpot'), 'rf')")

(command! :HotpotCacheForceUpdate
          #(let [cache-dir (vim.fn.expand :$XDG_CACHE_HOME/nvim/hotpot :rf)]
             (vim.fn.delete cache-dir)
             (vim.fn.system [:nvim :--headless :+q])))

(fn sync-scroll [ctx]
  (let [lua-file ctx.file
        prev-winnr (vim.fn.winnr "#")]
    (when (not= prev-winnr (vim.fn.winnr))
      (let [prev-bufnr (vim.fn.winbufnr prev-winnr)
            prev-buf-name (vim.api.nvim_buf_get_name prev-bufnr)
            prev-win-id (vim.fn.win_getid prev-winnr)
            cur-win-id (vim.fn.win_getid)
            lua-pattern-atom "[.-]"
            prev-buf-name-escaped (prev-buf-name:gsub lua-pattern-atom "%%%0")
            correlated? (when (prev-buf-name:match "%.fnl$")
                          (or (lua-file:match (prev-buf-name-escaped:gsub :fnl$
                                                                          :lua))
                              (lua-file:match (prev-buf-name-escaped:gsub :fnl
                                                                          :lua))))]
        (when correlated?
          ;; Sync line number and go back to the Fennel source buffer.
          (let [cur-buf-id (vim.api.nvim_win_get_buf cur-win-id)
                last-row (vim.api.nvim_buf_line_count cur-buf-id)
                prev-cursor (vim.api.nvim_win_get_cursor prev-win-id)
                new-cursor (if (< last-row (first prev-cursor))
                               [last-row (second prev-cursor)] ;
                               prev-cursor)
                save-lazyredraw vim.go.lazyredraw
                save-eventignore vim.go.eventignore]
            (tset vim.wo :wrap false)
            (tset vim.wo prev-win-id :wrap false)
            (tset vim.wo :scrollbind true)
            (tset vim.wo prev-win-id :scrollbind true)
            (setglobal! :lazyredraw true)
            (vim.cmd.syncbind)
            (setglobal! :eventignore :all)
            (vim.api.nvim_win_set_cursor cur-win-id new-cursor)
            (setglobal! :lazyredraw save-lazyredraw)
            (setglobal! :eventignore save-eventignore))
          (let [id (augroup! (.. :rcHotpotAdd/SyncCursorLine ctx.buf))]
            (fn dismiss-scrollbind-group []
              (when (vim.api.nvim_win_is_valid cur-win-id)
                (tset vim.wo cur-win-id :scrollbind false))
              (when (vim.api.nvim_win_is_valid prev-win-id)
                (tset vim.wo prev-win-id :scrollbind false))
              (pcall del-augroup! id))

            (au! id :BufWinLeave [:buffer ctx.buf] dismiss-scrollbind-group)
            (au! id :BufWinLeave [:buffer prev-bufnr] dismiss-scrollbind-group)
            (au! id :WinLeave [:buffer ctx.buf] #(set vim.wo.cursorline true))
            (au! id :WinLeave [:buffer prev-bufnr]
                 #(set vim.wo.cursorline true))
            (au! id [:CursorMoved :WinScrolled] [:buffer ctx.buf]
                 #(let [valid? ;
                        (pcall #(let [pos (vim.api.nvim_win_get_cursor cur-win-id)]
                                  (vim.api.nvim_win_set_cursor prev-win-id pos)))]
                    ;; Note: autocmd is deleted when callback for
                    ;; nvim_create_autocmd returns true.
                    (not valid?)))
            (au! id [:CursorMoved :WinScrolled] [:buffer prev-bufnr]
                 #(let [valid? ;
                        (pcall #(let [pos (vim.api.nvim_win_get_cursor prev-win-id)]
                                  (vim.api.nvim_win_set_cursor cur-win-id pos)))]
                    (not valid?))))
          (tset vim.wo prev-win-id :cursorline true))))))

(augroup! :rcHotpotAdd
          (au! :BufWinEnter [:*.lua]
               [:desc "Sync scroll to correlated Fennel buffer"]
               ;; TODO: Turn it into a plugin
               #(vim.schedule (fn []
                                (sync-scroll $))))
          (au! :FileType [:desc "Load ftplugins written in Fennel"]
               ;; Note: `:runtime` doesn't invoke `SourceCmd` so that hotpot
               ;; cannot compile files.
               ;; "runtime! ftplugin/<amatch>.fnl ftplugins/<amatch>/*.fnl"))
               #(->nil (pcall require (printf "ftplugin.%s" $.match)))))
