(import-macros {: nnoremap! : noremap-operator! : first : last : dec}
               :my.macros)

(local {: contains? : slice : compact : Operator} (require :my.utils))

(fn low-priority-buffer? [bufnr]
  (let [low-priority-patterns ["%.git/"]
        main-buftypes ["" :terminal :help]
        bufname (vim.fn.bufname bufnr)
        low-priority-name? (accumulate [match? false ;
                                        _ pattern (ipairs low-priority-patterns) ;
                                        &until match?]
                             (bufname:match pattern))]
    (or low-priority-name? ;
        (not (contains? main-buftypes (. vim.bo bufnr :buftype))))))

(fn reduce-windows []
  (each [_ bufnr (ipairs (vim.fn.tabpagebuflist))]
    (when (low-priority-buffer? bufnr)
      (vim.api.nvim_win_close (vim.fn.bufwinid bufnr) false)))
  (vim.cmd.wincmd "="))

(nnoremap! :<M-Space><Space> reduce-windows)
(nnoremap! :<M-Space><M-Space> reduce-windows)

(lambda remove-preceding-chars [text ?comment-constructors]
  "Remove spaces and comment constructors like `;;`, `#`, etc."
  (let [preceding-spaces "^%s*"]
    (if ?comment-constructors
        (-> text
            (: :gsub preceding-spaces "")
            (: :gsub ?comment-constructors "")
            (: :gsub preceding-spaces ""))
        (text:gsub preceding-spaces ""))))

(lambda join-range [sep start-pos end-pos]
  "Join lines without line-continuation markers."
  (let [start-row (dec (first start-pos)) ; 0-index for nvim_buf_get_lines
        [end-row] end-pos]
    (print start-row)
    (print end-row)
    (when (< start-row end-row)
      (let [old-lines (vim.api.nvim_buf_get_lines 0 start-row end-row true)
            pat-line-continuation (match vim.bo.filetype
                                    :vim "^%s*\\%s*"
                                    _ "%s*\\%s*$")
            ?comment-constructor (vim.bo.commentstring:match "^(.*)%%s")
            ?comment-constructors (when ?comment-constructor
                                    (.. ?comment-constructor "*"))
            trailing-spaces "%s*$"
            mid-lines (slice old-lines 2 -1)
            ?mid-line (when (< 2 (length old-lines))
                        (-> (icollect [_ line (ipairs mid-lines)]
                              (-> line
                                  (remove-preceding-chars ?comment-constructors)
                                  (: :gsub trailing-spaces "")
                                  (: :gsub pat-line-continuation "")))
                            (table.concat sep)))
            first-line (first old-lines)
            last-line (last old-lines)
            new-first-line (-> (if (pat-line-continuation:match "%$$")
                                   (first-line:gsub pat-line-continuation "")
                                   first-line)
                               (: :gsub trailing-spaces ""))
            new-last-line (-> (if (pat-line-continuation:match "^%^")
                                  (last-line:gsub pat-line-continuation "")
                                  last-line)
                              (remove-preceding-chars ?comment-constructors))
            new-lines (compact [new-first-line ?mid-line new-last-line])
            new-line (table.concat new-lines sep)]
        (vim.api.nvim_buf_set_lines 0 start-row end-row true [new-line])))))

(local operator-J (Operator.new (partial join-range " ")))

(local operator-gJ (Operator.new (partial join-range "")))

(noremap-operator! :<Space>J operator-J)
(noremap-operator! :gJ operator-gJ)
