(import-macros {: nmap! : range-map! : first : last : executable? : expand}
               :my.macros)

(local {: contains? : slice : compact : Operator} (require :my.utils))

(nmap! [:desc "Close all the other folds"] :zU :zMzv)

(nmap! "<C-[>" :<Esc><Cmd>nohl<CR>)

;; Arbitrary ratio scrolling:
;; Ref: https://neovim.discourse.group/t/how-to-make-ctrl-d-and-ctrl-u-scroll-1-3-of-window-height/859/2
(lambda scroll [ratio key]
  "Return keys to scroll.
  @param key string
  @param ratio number
  @return string"
  (.. (vim.fn.round (* ratio (vim.fn.winheight 0))) key))

(range-map! [:expr] :<C-d> #(scroll (/ 1 3) :<C-d>))
(range-map! [:expr] :<C-u> #(scroll (/ 1 3) :<C-u>))
(range-map! [:expr] :<C-f> #(scroll (/ 2 3) :<C-d>))
(range-map! [:expr] :<C-b> #(scroll (/ 2 3) :<C-u>))

(nmap! :<Space>ep [:desc "Enumerate &path"] #(vim.cmd "
redir => s:msg
silent verbose set path?
redir END
echo s:msg->substitute('.*path=', 'path:\\n', '')->substitute(',\\@<!,,\\@!', '\\n', 'g')
"))

(nmap! [:desc "Reduce low-priority windows"] :<C-w><Space><Space>
       #(let [low-priority-path-patterns ["%.git/"]
              main-buftypes ["" :terminal :help]]
          (each [_ buf (ipairs (vim.fn.tabpagebuflist))]
            (let [bufname (vim.fn.bufname buf)
                  low-priority-name? (accumulate [match? false ;
                                                  _ pattern (ipairs low-priority-path-patterns) ;
                                                  &until match?]
                                       (bufname:match pattern))
                  low-priority-buffer? (or low-priority-name? ;
                                           (not (contains? main-buftypes
                                                           (. vim.bo buf
                                                              :buftype))))]
              (when low-priority-buffer?
                (vim.api.nvim_win_close (vim.fn.bufwinid buf) false))))
          (vim.cmd.wincmd "=")))

;; Copy Window ///1

(nmap! [:desc "Copy current buffer to new tab"] :<C-w>gt :<C-w>s<C-w>T)
(nmap! [:desc "Copy current buffer to new tab"] :<C-w>gT :<C-w>s<C-w>T)

(let [copy-buffer-to-another-instance ;
      #(let [cmd (if (executable? :wezterm)
                     [:wezterm
                      :--config
                      :scrollback_lines=0
                      :start
                      "--"
                      :nvim
                      (expand "%:p")
                      "&"] (executable? :alacritty)
                     [:alacritty
                      :--option
                      :scrolling.history=0
                      :-e
                      :sh
                      :-c
                      (expand "sleep 0.1 && nvim %:p &")]
                     (executable? :nvim-qt) [:nvim-qt "%:p" "&"])]
         (vim.fn.system cmd))]
  (nmap! :<C-w><Space>T [:desc "Copy current buffer to another instance"]
         `copy-buffer-to-another-instance)
  (nmap! :<C-w><Space>t [:desc "Copy current buffer to another instance"]
         `copy-buffer-to-another-instance))

;; Operator-J ///1

(lambda remove-preceding-chars [text ?comment-leader]
  "Remove spaces and comment constructors like `;;`, `#`, etc."
  ;; FIXME: `\<` would unexpectedly miss `<` after beign joined.
  (let [preceding-spaces "^%s*"]
    (if ?comment-leader
        (-> text
            (: :gsub preceding-spaces "")
            (: :gsub ?comment-leader "")
            (: :gsub preceding-spaces ""))
        (text:gsub preceding-spaces ""))))

(lambda join-range [sep {: row01 : row2}]
  "Join lines without line-continuation markers."
  (when (< row01 row2)
    (let [old-lines (vim.api.nvim_buf_get_lines 0 row01 row2 true)
          pat-line-continuation (match vim.bo.filetype
                                  :vim "^%s*\\%s*"
                                  _ "%s*\\%s*$")
          ?comment-leader-char (vim.bo.commentstring:match "^(.*)%%s")
          ?comment-leader (when ?comment-leader-char
                            (.. ?comment-leader-char "*"))
          trailing-spaces "%s*$"
          mid-lines (slice old-lines 2 -1)
          ?mid-line (when (< 2 (length old-lines))
                      (-> (icollect [_ line (ipairs mid-lines)]
                            (-> line
                                (remove-preceding-chars ?comment-leader)
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
                            (remove-preceding-chars ?comment-leader))
          new-lines (compact [new-first-line ?mid-line new-last-line])
          new-line (table.concat new-lines sep)]
      (vim.api.nvim_buf_set_lines 0 row01 row2 true [new-line]))))

(range-map! :<Space>J [:desc "[operator] Join lines with spaces"]
            #(Operator.run (partial join-range " ")))

(range-map! :gJ [:desc "[operator] Join lines with no spaces"]
            #(Operator.run (partial join-range "")))
