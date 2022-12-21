(import-macros {: when-not : tbl? : nil? : ->num : dec} :my.macros)

(lambda open-at-once [method prompt-bufnr]
  ;; Ref: https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-1227591722
  (let [actions (require :telescope.actions)
        action-state (require :telescope.actions.state)
        picker (action-state.get_current_picker prompt-bufnr)
        entries (picker:get_multi_selection)]
    (if (= 0 (length entries))
        (let [edit (. actions (.. :select_ method))]
          (edit prompt-bufnr))
        (let [pickers (require :telescope.pickers)
              edit-file-cmd-map {:vertical :vsplit
                                 :horizontal :split
                                 :tab :tabedit
                                 :default :edit}
              edit-buf-cmd-map {:vertical "vert sbuffer"
                                :horizontal :sbuffer
                                :tab "tab sbuffer"
                                :default :buffer}]
          (pickers.on_close_prompt prompt-bufnr)
          (pcall vim.api.nvim_set_current_win picker.original_win_id)
          (each [i entry (ipairs entries)]
            (let [[filename row col] ;
                  (if (or entry.path entry.filename)
                      [(or entry.path entry.filename)
                       (or entry.row entry.lnum)
                       (or entry.col 1)]
                      (when (and (nil? entry.bufnr) (nil? entry.value))
                        (let [text (if (tbl? entry.value) ;
                                       entry.display entry.value)]
                          (icollect [s (text:gmatch "[^:]+")]
                            (if (s:match "^%d+$")
                                (->num s)
                                s)))))]
              (if entry.bufnr
                  (let [command (if (= i 1) :buffer (. edit-buf-cmd-map method))]
                    (when-not (. vim.b entry.bufnr :buflisted)
                              (tset vim.b entry.bufnr :buflisted true)
                              (pcall (. vim.cmd command)
                                     (vim.api.nvim_buf_get_name entry.bufnr))))
                  (let [command (if (= i 1) :edit (. edit-file-cmd-map method))]
                    (when (not= filename (vim.api.nvim_buf_get_name 0))
                      (let [path (-> filename
                                     (vim.fn.fnameescape)
                                     (vim.fs.normalize))]
                        (pcall (. vim.cmd command) path)))))
              (when (and row col)
                (pcall vim.api.nvim_win_set_cursor 0 [row (dec col)]))))))))

{: open-at-once}
