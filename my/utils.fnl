(import-macros {: when-not
                : nil?
                : num?
                : str?
                : seq?
                : tbl?
                : --
                : ++
                : setglobal!
                : <Cmd>
                : feedkeys!
                : echo!
                : printf
                : valid-buf?
                : expand} :my.macros)

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
  (-> (. ((debug.getinfo obj) :source))
      (string.match "^@(.*)")))

(lambda get-definition-row [obj]
  (-> (. ((debug.getinfo obj) :linedefined))))

;; Predicate ///1

(lambda any? [pred xs]
  (accumulate [any? false ;
               _ x (ipairs xs) ;
               &until any?]
    (pred x)))

(lambda all? [pred xs]
  ;; WIP: Test Required
  (accumulate [all? true ;
               _ x (ipairs xs) ;
               &until (= all? false)]
    (pred x)))

(lambda contains? [xs ?a]
  "Check if `?a` is in `xs`."
  (accumulate [eq? false ;
               _ x (ipairs xs) ;
               &until eq?]
    (= ?a x)))

(lambda empty? [tbl]
  "Check if `tbl` is empty."
  (assert (tbl? tbl)
          (-> "expected table, got %s: %s" (: :format (type tbl) (view tbl))))
  (not (next tbl)))

(lambda confirm? [msg ?choices]
  "Wrapper of vim.fn.confirm. The default choices are No (default) or Yes."
  (let [choices (or ?choices "[y/N]")]
    (echo! (printf "%s %s" msg choices) :ErrorMsg)
    (if (= :y (vim.fn.getcharstr)) true
        (do
          (vim.notify "Abort confirmation" vim.log.levels.WARN)
          false))))

(lambda large-file? [max-bytes bufnr]
  "Tell if `?bufnr`, or current buffer, is larger than `max-bytes`?"
  (when (valid-buf? bufnr)
    (let [(ok stats) (pcall vim.loop.fs_stat (vim.api.nvim_buf_get_name bufnr))]
      (and ok stats (< max-bytes (. stats :size))))))

;; Git ///1

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
        dir (expand path ":h")]
    (assert (seq? git-args) ;
            (printf "`git-args` must be a sequential table, got %s\ndump:\n%s"
                    (type git-args) (vim.inspect git-args)))
    (when (contains? git-args :-C)
      (error "You don't have to set working directory with this function"))
    (let [result (vim.fn.system [:git :-C dir (unpack git-args)])
          result-text (-> result (: :gsub "\r" "\n"))
          success? (= 0 vim.v.shell_error)]
      (if success?
          result-text
          (error result-text)))))

(lambda git-tracking? [?path]
  "Check if `?path` is tracked by git."
  (let [path (or ?path (expand "%:p"))]
    (let [success? (pcall git [:ls-files :--error-unmatch path])]
      success?)))

;; Sequence ///1

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

(fn join [...]
  "Join strings by ?sep or tables:
  ```fnl
  (join \",\" [:foo :bar :baz]) ; -> \"foo,bar,baz\"
  (join \"-\" [:foo :bar :baz]) ; -> \"foo-bar-baz\"
  (join [:foo :bar :baz] [:qux :quux]) ; -> [:foo :bar :baz :qux :quux]
  (join {: foo : bar : baz} {: qux : quux}) ; -> {: foo : bar : baz : qux : quux}
  (join {: foo : bar : baz} {:foo :qux :bar :quux}) ; -> {:foo :qux :bar :quux : baz : qux : quux}
  ```
  Note: Joining tables which contains values at the same keys,
  the latter ones have priority; the earlier ones are overwritten."
  (let [args [...]
        size (length args)
        [x1 & rest] args]
    (assert (<= 2 size) "expected two args at least")
    (match (type x1)
      :string (let [sep x1
                    strings (unpack rest)
                    str (table.concat strings sep)]
                str)
      :table (if (seq? x1)
                 (do
                   (var idx 1)
                   (accumulate [ys [] _ tbl (ipairs args)]
                     (do
                       (each [_ v (ipairs tbl)]
                         (tset ys idx v))
                       (++ idx)
                       ys)))
                 (do
                   (var [key val] [nil nil])
                   (collect [_ tbls (ipairs args)]
                     (each [k v (pairs tbls)]
                       (set key k)
                       (set val v))
                     (values key val))))
      _ (error (.. "expected string or table for the first arg, got " (type x1))))))

;; Vim ///1

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
            cb (<Cmd> "set eventignore=" vim.g.eventignore))
        (let [save-ei vim.g.eventignore]
          (set vim.g.eventignore events)
          (execute-callback cb)
          (vim.schedule #(set vim.g.eventignore save-ei))))))

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

  - `callback`: (string|function) If string, return it as in keymap rhs.
  "
  (if (str? cb)
      (.. (<Cmd> "set lazyredraw") cb (<Cmd> "let lazyredraw = &lazyredraw"))
      (do
        (setglobal! :lazyredraw true)
        (execute-callback cb)
        (vim.schedule #(setglobal! :lazyredraw false)))))

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

;; Operator ///1

(local Operator {})

(lambda Operator.new [func]
  "Create new operator function.
  ```fennel
  (Operator.new (fn [start end]
                    (range-function start end)))
  ```"
  #(let [old-opfunc vim.go.operatorfunc
         new-opfunc #(let [start-pos (vim.api.nvim_buf_get_mark 0 "[")
                           end-pos (vim.api.nvim_buf_get_mark 0 "]")]
                       (func start-pos end-pos)
                       ;; Note: Restore &operatorfunc should be required if
                       ;; operators are to be nested; however, it should be
                       ;; kept for dot-repeating.
                       (comment (setglobal! :operatorfunc old-opfunc)))
         new-opfunc-name "v:lua.require'my.utils'.Operator.start"]
     (set Operator.start new-opfunc)
     (setglobal! :operatorfunc new-opfunc-name)
     (feedkeys! "g@" :ni)
     ;; For rhs with `expr`.
     "g@"))

;; Export ///1

(set _G.noautocmd noautocmd!)

{: valid-path?
 : get-script-path
 : get-definition-row
 : get-definition-file
 : any?
 : all?
 : contains?
 : empty?
 : confirm?
 : large-file?
 : git
 : git-tracking?
 : reverse
 : remove
 : compact
 : slice
 : join
 : execute!
 : with-eventignore!
 : noautocmd!
 : with-lazyredraw!
 : get-mapargs
 : buf-get-mapargs
 : del-augroup!
 : Operator}
