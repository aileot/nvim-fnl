(import-macros {: if-not
                : when-not
                : str?
                : dec
                : inc
                : ++
                : --
                : command!
                : nmap!
                : xmap!
                : range-map!
                : <Cmd>
                : <C-u>
                : executable?
                : expand} :my.macros)

(local {: contains? : cycle : Operator} (require :my.utils))

(nmap! [:desc "Close all the other folds"] :zU :zMzv)

(nmap! "<C-[>" :<Esc><Cmd>nohl<CR>)

(nmap! :<Space>E [:desc "Discard any changes to current buffer"] (<C-u> :e!))

(nmap! "]q" (<Cmd> :cnext))
(nmap! "[q" (<Cmd> :cprev))
(nmap! "]l" (<Cmd> :lnext))
(nmap! "[l" (<Cmd> :lprev))
(nmap! "]Q" (<Cmd> :cnfile))
(nmap! "[Q" (<Cmd> :cpfile))
(nmap! "]L" (<Cmd> :lnfile))
(nmap! "[L" (<Cmd> :lpfile))

(fn cycle-file [addend]
  (let [buf-path (vim.fn.expand "%:p")
        buf-ext (vim.fn.fnamemodify buf-path ":e")
        buf-dir (vim.fn.fnamemodify buf-path ":h")
        buf-tail (vim.fn.fnamemodify buf-path ":t")
        ext-pattern (.. "%." buf-ext "$")
        files (->> (vim.fn.readdir buf-dir)
                   (vim.tbl_filter #($:match ext-pattern)))
        buf-idx (inc (vim.fn.index files buf-tail))
        new-idx (+ buf-idx addend)
        new-filename (cycle files new-idx)]
    (assert (str? new-filename) (.. "no other files detected at " buf-dir))
    (.. buf-dir "/" new-filename)))

(command! [:bar :desc "Open previous file in current buf directory"] :Fprevious
          #(vim.cmd.e (cycle-file -1)))

(command! [:bar :desc "Open next file in current buf directory"] :Fnext
          #(vim.cmd.e (cycle-file 1)))

(nmap! "[f" (<Cmd> :Fprevious))
(nmap! "]f" (<Cmd> :Fnext))

(do
  (fn get-current-buf|win []
    [(vim.api.nvim_get_current_buf) (vim.api.nvim_get_current_win)])
  (var buf|win nil)

  (fn new-quick-tempered [key]
    ;; https://github.com/folke/dot/blob/7d696ae93ca6f434d729c9c0ac9efa780ee5026b/config/nvim/lua/config/mappings.lua#L15-L35
    (var notif-id nil)
    (var count 0)
    (local threshold 8)
    (local interval 5000)
    #(if-not (vim.deep_equal buf|win (get-current-buf|win))
       (do
         (set buf|win (get-current-buf|win))
         (set count 0)
         key)
       (< count threshold)
       (do
         (++ count)
         (vim.defer_fn #(-- count) interval)
         key)
       (set notif-id
            (vim.notify "Stay⛄cool." vim.log.levels.WARN
                        {:icon "⛄"
                         :replace notif-id
                         :keep #(< threshold count)}))))

  ;; It doesn't matter in Operator-pending mode.
  (range-map! [:expr] :h (new-quick-tempered :h))
  (nmap! [:expr] :j (new-quick-tempered :gj))
  (nmap! [:expr] :k (new-quick-tempered :gk))
  (xmap! [:expr] :j (new-quick-tempered :j))
  (xmap! [:expr] :k (new-quick-tempered :k))
  (range-map! [:expr] :l (new-quick-tempered :l)))

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

(nmap! :<Space>ep [:desc "Enumerate &path"]
       #(-> vim.o.path
            (: :gsub "," "\n")
            (vim.notify)))

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
         copy-buffer-to-another-instance)
  (nmap! :<C-w><Space>t [:desc "Copy current buffer to another instance"]
         copy-buffer-to-another-instance))

;; Operator-J ///1

(lambda join-range [sep {: row1 : row2}]
  "Join lines without line-continuation markers."
  (let [join/bang (= sep "")
        join/range (when-not (= row1 row2)
                     [row1 row2])
        \ "\\"
        pat/?spaces (.. \ :s*)
        pat/line-continuation (match vim.bo.filetype
                                :vim
                                ;; `^\s*\\`
                                (.. "^" pat/?spaces \ \ pat/?spaces)
                                _
                                ;; `\\\s*$`
                                (.. pat/?spaces \ \ pat/?spaces "$"))
        pat/indent (.. "^" pat/?spaces)
        sub/sep "/"
        sub/flags :e
        sub/arg-template (.. sub/sep "%s" sub/sep "" sub/sep sub/flags)
        sub/arg-remove-line-continuation (sub/arg-template:format pat/line-continuation)
        sub/arg-remove-indent (sub/arg-template:format pat/indent)
        sub/range (if (pat/line-continuation:match "^%^") [(inc row1) row2]
                      (pat/line-continuation:match "%$$") [row1 (dec row2)])]
    ;; FIXME: Deal with sub/range when (= row1 row2).
    (pcall vim.cmd.sub
           {:range sub/range :args [sub/arg-remove-line-continuation]})
    ;; Note: Otherwise, `:join!` will not compress spaces which previously
    ;; work as indent because `:join!` only trims the first space character
    ;; before concatenating lines.
    (pcall vim.cmd.sub {:range [(inc row1) row2] :args [sub/arg-remove-indent]})
    (vim.cmd.join {:bang join/bang :range join/range})))

(range-map! :<Space>J [:desc "[operator] Join lines with spaces"]
            #(Operator.run (partial join-range " ")))

(range-map! :gJ [:desc "[operator] Join lines with no spaces"]
            #(Operator.run (partial join-range "")))
