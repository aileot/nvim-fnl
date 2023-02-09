(import-macros {: when-not
                : if-not
                : --
                : ++
                : dec
                : inc
                : augroup!
                : au!
                : b!
                : setlocal!
                : setglobal!
                : <Cmd>
                : feedkeys!
                : hi!
                : echo!
                : printf
                : valid-buf?
                : expand} :my.macros)

(local {: any?
        : all?
        : contains?
        : empty?
        : nil?
        : boolean?
        : true?
        : false?
        : str?
        : tbl?
        : seq?
        : num?
        : fn?
        : function?
        : odd?
        : even?} (require :my.utils.predicate))

(lambda valid-path? [path]
  ;; https://stackoverflow.com/a/40195356
  (let [[ok err code] (os.rename path path)]
    (if (and ok ;
             ;; Permission denied, but it exists
             (= code 13)) true ;
        (values ok err))))

(lambda get-script-path []
  "Return where this function called"
  (-> (. (debug.getinfo 1 :S) :source)
      (: :match "@?(.*)")))

(lambda get-definition-file [obj]
  (-> (. (debug.getinfo obj) :source)
      (string.match "^@(.*)")))

(lambda get-definition-row [obj]
  (-> (. (debug.getinfo obj) :linedefined)))

(local Callbacks {:next-id 1})

(lambda Callbacks.register [cb]
  (let [id Callbacks.next-id]
    (tset Callbacks id cb)
    (set Callbacks.next-id (inc id))
    (printf "require'my.utils'.Callbacks[%d]()" id)))

;;; Git ///1

(lambda git [git-args ?path]
  "A wrapper of git in Neovim.
  Execute `git git-args` in the `?path`, or currently editing file's directory.
  ```fennel
  (git git-args ?path)
  ```
  @param git-args string[]: args for `git -C path`
  @param ?path string: If omitted, current buffer is set.
    A path where `git` is to be executed.
  @return boolean: Success or failed.
  @return string: result"
  (let [path (or ?path (expand "%:p"))
        dir (vim.fs.dirname path)]
    (assert (seq? git-args) ;
            (printf "`git-args` must be a sequential table, got %s\ndump:\n%s"
                    (type git-args) (vim.inspect git-args)))
    (when (contains? git-args :-C)
      (error "You don't have to set working directory with this function"))
    (let [cmd [:git :-C dir (unpack git-args)]
          result (vim.fn.system cmd)
          result-text (-> result (: :gsub "\r" "\n"))
          success? (= 0 vim.v.shell_error)]
      (if success?
          result-text
          (error (printf "executed command: %s\n\nerror message:\n%s"
                         (table.concat cmd " ") result-text))))))

(lambda git-tracking? [?path]
  "Check if `?path` is tracked by git."
  (let [path (or ?path (expand "%:p"))
        success? (pcall git [:ls-files :--error-unmatch path])]
    success?))

;;; String ///1

(fn capitalize [word]
  "capitalize `word`."
  (assert (str? word) (printf "expected string, got %s\ndump:\n%s" (type word)
                              word))
  (match (length word)
    0 ""
    1 (word:upper)
    _ (.. (-> (word:sub 1 1) (: :upper)) ;
          (word:sub 2))))

;;; Sequence ///1

(lambda first [xs]
  (. xs 1))

(lambda second [xs]
  (. xs 2))

(lambda last [xs]
  (. xs (length xs)))

(lambda reverse [xs]
  (var i (length xs))
  (let [ys []]
    (while (< 0 (length ys))
      (tset ys i (. xs i))
      (-- i))))

(lambda remove [a xs]
  "Remove all the same items as `a` in `xs`"
  (assert (seq? xs) "the second arg must be a sequence" xs)
  (let [ys []]
    (each [_ x (ipairs xs)]
      (when (= x a)
        (table.insert ys x)))
    ys))

(lambda slice [xs ?first ?last ?step]
  (let [size (length xs)
        first (or ?first 1)
        last (if (nil? ?last) size
                 (< ?last 0) (+ size ?last)
                 ?last)
        step (or ?step 1)]
    (fcollect [i first last step]
      (. xs i))))

(lambda compact [tbl]
  "Remove `nil` values from table"
  (let [ys []]
    (each [_ x (pairs tbl)]
      (when-not (nil? x)
        (table.insert ys x)))
    ys))

(lambda extend [...]
  "Merge multi arrays into one."
  (let [xs []]
    (each [_ arr (ipairs [...])]
      ;; Note: `ipairs` cannot iterate array including `nil`. It might be
      ;; better to drop `nil`s before iteration.
      (each [_ v (pairs arr)]
        (table.insert xs v)))
    xs))

(fn cycle [seq idx]
  "Return item of `seq` at cyclic index, adjusted for 1-based Lua table.
  @param seq table
  @param idx number
  @return any"
  (assert (vim.tbl_islist seq) "Expected sequence")
  (assert (num? idx) "Expected number")
  (let [max-idx (length seq)
        _ (assert (< 1 max-idx) "expected two or more sequential items")
        tmp-idx (% idx max-idx)
        new-idx (if (= 0 tmp-idx) max-idx tmp-idx)]
    (. seq new-idx)))

;;; File System ///1

(lambda large-file? [max-bytes bufnr]
  "Tell if `?bufnr`, or current buffer, is larger than `max-bytes`?"
  (when (valid-buf? bufnr)
    (let [(ok stats) (pcall vim.loop.fs_stat (vim.api.nvim_buf_get_name bufnr))]
      (and ok stats (< max-bytes (. stats :size))))))

;;; Vim ///1

(lambda confirm? [msg ?choices]
  "Wrapper of vim.fn.confirm. The default choices are No (default) or Yes."
  (let [choices (or ?choices "[y/N]")]
    (echo! (printf "%s -- %s" msg choices) :MoreMsg)
    (if (= :y (vim.fn.getcharstr))
        (do
          (echo! (printf "%s -- confirmed" msg) :ModeMsg)
          true)
        (do
          (vim.notify (printf "%s -- abort" msg) vim.log.levels.WARN)
          false))))

(lambda execute! [...]
  "Imitation of `:execute`. Execute Ex commands and functions one by one, not
  at once.
  ```fennel
  (execute! ...)
  ```
  @param ... string|string[]|function"
  (each [_ ex-sequence (ipairs [...])]
    (let [new-ex-cmd (match (type ex-sequence)
                       :string ex-sequence
                       :function (ex-sequence)
                       :table (let [safe-ex-sequence (compact ex-sequence)]
                                (if (< 1 (length safe-ex-sequence))
                                    (table.concat safe-ex-sequence " ")
                                    (?. safe-ex-sequence 1))))]
      (when new-ex-cmd
        (vim.api.nvim_exec new-ex-cmd false)))))

(lambda execute-callback [cb]
  "Execute callback function or Ex command."
  (match (type cb)
    :string (vim.cmd cb)
    :function (cb)
    _ (error (.. "expected string or function, got " (type cb) "\ndump:\n"
                 (vim.inspect cb)))))

(lambda with-eventignore! [events cb]
  "Disable autocmd events in the duration of the command/function.
  ```fennel
  (with-eventignore! events cb)
  ```
  @param cb string|function: If string, return it as in keymap rhs."
  (if (str? cb)
      (let [ev (if (str? events) events (table.concat events ","))]
        (.. (<Cmd> "set eventignore=" ev) ;
            cb (<Cmd> "set eventignore=" vim.g.eventignore)))
      (fn? cb)
      (let [save-ei vim.g.eventignore]
        (set vim.g.eventignore events)
        (execute-callback cb)
        (vim.schedule #(set vim.g.eventignore save-ei)))
      (error (.. "Expected string or function, got " (type cb)))))

(lambda noautocmd! [cb]
  "Imitation of `:noautocmd`.
  ```fennel
  (noautocmd! callback)
  ```
  - `callback`: (string|function) If string, return it as in keymap rhs."
  (with-eventignore! :all cb))

(lambda with-lazyredraw! [cb]
  "Enable lazyredraw for the duration of callback.
  ```fennel
  (with-lazyredraw! callback)
  ```
  - `callback`: (string|function) If string, return it as in keymap rhs."
  (if (str? cb)
      (.. (<Cmd> "set lazyredraw") cb (<Cmd> "let lazyredraw = &lazyredraw"))
      (fn? cb)
      (do
        (setglobal! :lazyredraw true)
        (execute-callback cb)
        (vim.schedule #(setglobal! :lazyredraw false)))
      (error (.. "Expected string or function got " (type cb)))))

(lambda get-mapargs [mode lhs]
  (let [mappings (vim.api.nvim_get_keymap mode)]
    (accumulate [rhs nil _ m (ipairs mappings) &until rhs]
      (when (= lhs m.lhs)
        m))))

(lambda buf-get-mapargs [bufnr mode lhs]
  (let [mappings (vim.api.nvim_buf_get_keymap bufnr mode)]
    (accumulate [rhs nil _ m (ipairs mappings) &until rhs]
      (when (= lhs m.lhs)
        m))))

(lambda del-augroup! [name-or-id]
  "Delete augroup by either name or id."
  (if (num? name-or-id)
      (vim.api.nvim_del_augroup_by_id name-or-id)
      (vim.api.nvim_del_augroup_by_name name-or-id)))

(local set-undoable/defaults {})
(lambda set-undoable! [name ?val]
  "`:setlocal` for ftplugin, updating `b:undo_ftplugin`.
  It can also manage global-only options such as `report`."
  (let [name* (name:lower)
        {: scope} (vim.api.nvim_get_option_info name*)]
    (if (= scope :global)
        (do
          (when (nil? (. set-undoable/defaults name*))
            (tset set-undoable/defaults name* (. vim.go name*)))
          (augroup! :myUtils/SetUndoable
            (au! :BufLeave
                 [:<buffer>
                  :desc
                  (printf "utils: Restore &g:%s to default" name*)]
                 #(setglobal! name* (. set-undoable/defaults name*)))
            (au! :BufEnter
                 [:<buffer> :desc (.. "utils: Adjust &g:" name* " for buffer")]
                 #(setglobal! name* ?val))))
        (let [old-undo-ftplugin (or vim.b.undo_ftplugin "")
              extracted-name (name*:match "[a-z]+")]
          (when-not (old-undo-ftplugin:match (.. extracted-name "<"))
            (let [undo-cmd (printf "setl %s<" extracted-name)
                  sep-required? (and (not (old-undo-ftplugin:match "^%s*$"))
                                     (not (old-undo-ftplugin:match "|%s*$")))
                  sep (if sep-required? "|" "")
                  new-undo-ftplugin (.. old-undo-ftplugin sep undo-cmd)]
              (b! :undo_ftplugin new-undo-ftplugin)))))
    (setlocal! name* ?val)))

(lambda erase-buf [?buf]
  "Remove entire contents of buffer and close the buffer."
  (let [buf (or ?buf (vim.api.nvim_get_current_buf))]
    (vim.api.nvim_buf_call buf #(vim.cmd "silent %delete_\nupdate"))
    (while (next (vim.fn.win_findbuf buf))
      (vim.api.nvim_buf_call buf #(vim.cmd.quit)))))

(lambda erase-win [?win]
  "Remove entire contents in buffer of win-id and close the window."
  (let [win (or ?win (vim.api.nvim_get_current_win))]
    (vim.api.nvim_win_call win #(vim.cmd "silent %delete_
                                          update
                                          quit"))))

(lambda find-root [?raw-path]
  "Find root of `?raw-path` or of current buffer, where alternate buffer could
  be another fallback if the others are empty. URI scheme is ignored.
  @param ?raw-path string Target path to find root.
  @return string?"
  (let [root-markers [:.git]
        extend-dir-pattern #(.. (vim.pesc $) "/.-/")
        vim-runtime (expand :$VIMRUNTIME)
        home (expand :$HOME)
        root-patterns [(extend-dir-pattern (vim.fn.stdpath :config))
                       (extend-dir-pattern (vim.fn.stdpath :cache))
                       (extend-dir-pattern (vim.fn.stdpath :data))
                       (extend-dir-pattern (vim.fn.stdpath :state))
                       (extend-dir-pattern (expand :$XDG_CONFIG_HOME))
                       (extend-dir-pattern (expand :$XDG_CACHE_HOME))
                       (extend-dir-pattern (expand :$XDG_DATA_HOME))
                       (extend-dir-pattern (expand :$XDG_STATE_HOME))
                       (vim.pesc (.. vim-runtime :/lua))
                       (extend-dir-pattern vim-runtime)
                       (extend-dir-pattern home)
                       (vim.pesc home)
                       (extend-dir-pattern :/etc)
                       (extend-dir-pattern :/usr/share)
                       ;; Any other dirs at root like /tmp/ and /var/.
                       "/.-/"]
        pattern-uri-scheme "^.*://"
        raw-path (or ?raw-path (expand "%:p"))
        path (-> (if (= "" raw-path) (expand "#:p") raw-path)
                 (: :gsub pattern-uri-scheme ""))
        ?first-root-marker-dir (-> (vim.fs.find root-markers
                                                {: path :upward true})
                                   (. 1)
                                   (vim.fs.dirname))
        ?first-root-pattern-dir (accumulate [dir nil ;
                                             _ pat (ipairs root-patterns) ;
                                             &until dir]
                                  (path:match (.. "^" pat)))]
    (if (and ?first-root-marker-dir ?first-root-pattern-dir)
        (if (< (length ?first-root-marker-dir) (length ?first-root-pattern-dir))
            ?first-root-pattern-dir
            ?first-root-marker-dir)
        (or ?first-root-marker-dir ?first-root-pattern-dir ;
            (error (printf "no root found for \"%s\"" path))))))

(lambda alias! [abbr result]
  "Define command alias.
  @param abbr bare-string
  @param result string
  @return string"
  (let [callback #(if-not (= ":" (vim.fn.getcmdtype))
                    abbr
                    (let [line (vim.fn.getcmdline)
                          col (vim.fn.getcmdpos)
                          preceding-chars (line:sub 1 col)
                          patterns [(.. "^%s*" abbr "$")
                                    (.. "^%A+" abbr "$")
                                    (.. "%|%s*" abbr "$")
                                    (.. "%|%A+" abbr "$")]
                          command? (accumulate [found? false ;
                                                _ pat (ipairs patterns) ;
                                                &until found?]
                                     (preceding-chars:find pat))]
                      (if command?
                          (match (type result)
                            :string
                            result
                            :function
                            ;; Note: run function in callback; it should not run
                            ;; in advance.
                            (result)
                            _
                            (error (.. "invalid type: " (type result))))
                          abbr)))
        args [:<expr>
              abbr
              (printf "luaeval(%q)" (Callbacks.register callback))]]
    (vim.cmd {:cmd :cnoreabbr : args})))

;;; Column ///1

(lambda override-column-color! [hl-name opts]
  "Override bg color of number-column (LineNr).
  - For fg, the fg/ctermfg value of `hl-LineNr` will be used.
  - For bg, the bg/ctermbg value of `opts.bg`, or either fg value of hl-group
  by `opts.fg` or bg one by `opts.bg`.
  ```fennel
  (override-column-color! hl-name opts)
  ```
  @param hl-name string
  @param opts kv-table"
  ;; TODO: Make it more general to inject some attributes to existing hl-group.
  ;; Note: The reference values could be different after startup.
  (let [rgb? vim.go.termguicolors
        [fg-key bg-key] (if rgb? [:fg :bg] [:ctermfg :ctermbg])
        hl-map-column (vim.api.nvim_get_hl_by_name :LineNr rgb?)
        fg-color hl-map-column.foreground
        ?fg opts.fg
        ?bg opts.bg
        [?hl-ref ?which] (if (and (str? ?fg) (?fg:match "^[^#]"))
                             [?fg :foreground]
                             (and (str? ?bg) (?bg:match "^[^#]"))
                             [?bg :background] ;
                             [])
        new-opts (if ?hl-ref
                     (let [hl-map-ref (vim.api.nvim_get_hl_by_name ?hl-ref rgb?)
                           bg-color (. hl-map-ref ?which)
                           opts-colors {fg-key fg-color bg-key bg-color}
                           invalid-key (.. (?which:sub 1 1) :g)]
                       (tset opts invalid-key nil)
                       (vim.tbl_extend :force opts-colors opts))
                     opts)]
    (hi! hl-name new-opts)))

(lambda register-column-highlight [config]
  "Override column color in table.
  ```fennel
  (register-column-highlight {hl-name opts ...})
  ```
  @param config table<string,kv-table>"
  (let [id (augroup! :myUtilsRegisterColumnHighlight)]
    (each [hl-name opts (pairs config)]
      (override-column-color! hl-name opts)
      (au! id :ColorScheme #(override-column-color! hl-name opts)))))

;;; Operator ///1

(local Operator {})

(lambda Operator.set [opfunc-body]
  "Set `opfunc` to `&operatorfunc`.
  ```fennel
  (Operator.set (fn {: start
                     : end
                     : row1
                     : row2
                     : col1
                     : col2
                     : row01
                     : row02
                     : col01
                     : col02}
                  (range-function start end)))
  ```
  @param opfunc-body function"
  (let [old-opfunc vim.go.operatorfunc
        new-opfunc #(let [start (vim.api.nvim_buf_get_mark 0 "[")
                          end (vim.api.nvim_buf_get_mark 0 "]")
                          [raw-row1 raw-col1] start
                          [raw-row2 raw-col2] end]
                      (opfunc-body {: start
                                    : end
                                    :row1 raw-row1
                                    :row2 raw-row2
                                    :col1 (inc raw-col1)
                                    :col2 (inc raw-col2)
                                    ;; zero-index
                                    :row01 (dec raw-row1)
                                    :row02 (dec raw-row2)
                                    :col01 raw-col1
                                    :col02 raw-col2})
                      (setglobal! :operatorfunc old-opfunc))
        new-opfunc-name "v:lua.require'my.utils'.Operator.opfunc"]
    (set Operator.opfunc new-opfunc)
    (setglobal! :operatorfunc new-opfunc-name)))

(lambda Operator.new [opfunc-body]
  "Set `opfunc` to `&operatorfunc` and return `g@`. This function is supposed
  to be used with `expr` option.
  ```fennel
  (Operator.new (fn {: start
                     : end
                     : row1
                     : row2
                     : col1
                     : col2
                     : row01
                     : row02
                     : col01
                     : col02}
                  (range-function start end)))
  ```
  @param opfunc-body function
  @return \"g@\""
  (Operator.set opfunc-body)
  "g@")

(lambda Operator.run [opfunc-body]
  "Set `opfunc` to `&operatorfunc` and insert `g@` to the typeahead.
  ```fennel
  (Operator.run (fn {: start
                     : end
                     : row1
                     : row2
                     : col1
                     : col2
                     : row01
                     : row02
                     : col01
                     : col02}
                  (range-function start end)))
  ```
  @param opfunc-body function"
  (Operator.set opfunc-body)
  (feedkeys! "g@" :ni))

;;; Lua ///1

(fn get-func-definition [func]
  (let [info (debug.getinfo func)]
    (if (= :C info.what) "written in C"
        (let [source (info.source:match "^@?(.*)$")]
          (if (source:match :^vim/)
              (let [func-name (?. info :name)]
                (values (string.format "%s/lua/%s" vim.env.VIMRUNTIME source)
                        (if func-name
                            (.. "+/" func-name)
                            :+1))))))))

;; Ref: https://github.com/nanotee/nvim-lua-guide#tips-3
(fn dump [...]
  (if (= 0 (length [...]))
      (do
        (print nil)
        ...)
      (let [args [...]]
        (if (= :function (type (. args 1)))
            (let [func (. args 1)
                  (file cmd-identifier) (get-func-definition func)]
              (dump file)
              (when (and cmd-identifier
                         (= 1
                            (vim.fn.confirm "Go to definition?" "&Yes\n&no" 1)))
                (let [definition (if cmd-identifier
                                     (string.format "%s %s" cmd-identifier file)
                                     file)]
                  (vim.cmd (string.format "sp %s" definition))
                  (vim.cmd.normal! :zz)))
              file)
            (let [objects (vim.tbl_map vim.inspect args)]
              (print (unpack objects))
              ...)))))

;;; Export ///1

(set _G.noautocmd noautocmd!)
(set _G.dump dump)

{: valid-path?
 : get-script-path
 : get-definition-row
 : get-definition-file
 : first
 : second
 : last
 : any?
 : all?
 : contains?
 : empty?
 : nil?
 : boolean?
 : true?
 : false?
 : str?
 : tbl?
 : seq?
 : num?
 : fn?
 : function?
 : odd?
 : even?
 : empty?
 : confirm?
 : large-file?
 : git
 : git-tracking?
 : capitalize
 : reverse
 : remove
 : compact
 : slice
 : extend
 : cycle
 : execute!
 : with-eventignore!
 : noautocmd!
 : with-lazyredraw!
 : get-mapargs
 : buf-get-mapargs
 : del-augroup!
 : set-undoable!
 : erase-buf
 : erase-win
 : find-root
 : alias!
 : override-column-color!
 : register-column-highlight
 : Operator
 : Callbacks}
