(fn scrollbar []
  (let [indicators ["█" "▇" "▆" "▅" "▄" "▃" "▂" "▁"]
        [cur-row] (vim.api.nvim_win_get_cursor 0)
        end-row (vim.api.nvim_buf_line_count 0)
        ratio (/ (- cur-row 1) end-row)
        index (+ 1 (math.floor (* ratio (length indicators))))
        width 2]
    (string.rep (. indicators index) width)))

{: scrollbar}
