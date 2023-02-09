;;; Import ///1
;; This macro by-pass might not work with `compilerEnv = _G`.
;; Related Commits:
;; - Fix a bug where disabling the compiler sandbox broke module require
;;   https://github.com/bakpakin/Fennel/commit/ba37b3b4ef46c987793543854cbc3c7120d27c8c
;; Related Issues:
;; - `require` fails when requiring a macro-utils file from other macro files
;;   with no compiler sandbox
;;   https://github.com/bakpakin/Fennel/issues/406
;; - `require` fails when requiring a macro-utils file from other macro files
;;   with `compilerEnv` as `_G`
;;   https://github.com/rktjmp/hotpot.nvim/issues/48
;; - How to automatically import macros file?
;;   https://github.com/rktjmp/hotpot.nvim/issues/75
;; - Use cljlib-fennel with Hotpot?
;;   https://github.com/rktjmp/hotpot.nvim/issues/76
;; - Unknown behaviour for when calling require(:macros) inside import-macros call
;;   https://github.com/rktjmp/hotpot.nvim/issues/77
;; - Issues with loading macros
;;   https://github.com/Olical/aniseed/issues/128

(local {: contains? : str? : fn? : even?} (require :my.utils.predicate))

(local {: set!
        : setlocal!
        : setglobal!
        : go!
        : bo!
        : wo!
        : g!
        : b!
        : w!
        : t!
        : v!
        : env!
        : map!
        : unmap!
        : <C-u>
        : <Cmd>
        : command!
        : augroup!
        : augroup+
        : au!
        : autocmd!
        : feedkeys!
        : highlight!} (require :nvim-laurel.macros))

;;; Predicate ;;; 1

(fn nil?* [x]
  "Check if `x` is nil."
  `(= ,x nil))

(fn bool?* [x]
  "Check if `x` is boolean."
  `(= (type ,x) :boolean))

(fn true?* [x]
  `(= (type ,x) true))

(fn false?* [x]
  `(= (type ,x) false))

(fn str?* [x]
  "Check if `x` is string."
  `(= (type ,x) :string))

(fn fn?* [x]
  "(Runtime time) Check if `x` is function."
  `(= (type ,x) :function))

(fn num?* [x]
  "Check if `x` is number."
  `(= (type ,x) :number))

(fn seq?* [x]
  "Check if `x` is sequence."
  `(not= (. ,x 1) nil))

(fn tbl?* [x]
  "Check if `x` is table.
  table?, sequence?, etc., is only available in compile time."
  `(= (type ,x) :table))

(fn even?* [x]
  "Check if `x` is even number."
  `(and ,(num?* x) (= (% ,x 2) 0)))

(fn odd?* [x]
  "Check if `x` is odd number."
  `(and ,(num?* x) (= (% ,x 2) 1)))

;;; String ///1

(lambda printf [str ...]
  `(string.format ,str ,...))

(lambda println [str ...]
  (if (str? str)
      `(string.format ,(.. str "\n") ,...)
      `(string.format (.. ,str "\n") ,...)))

;;; Number ///1

(lambda inc [x]
  "Return incremented result"
  `(+ ,x 1))

(lambda dec [x]
  "Return decremented result"
  `(- ,x 1))

(lambda ++ [x]
  "Increment `x` by 1"
  (assert-compile (sym? x) (.. "expected symbol, got " (type x)) x)
  `(do
     (set ,x (+ ,x 1))
     ,x))

(lambda -- [x]
  "Decrement `x` by 1"
  (assert-compile (sym? x) (.. "expected symbol, got " (type x)) x)
  `(do
     (set ,x (- ,x 1))
     ,x))

;;; Table ///1

(lambda first* [xs]
  `(. ,xs 1))

(lambda second* [xs]
  `(. ,xs 2))

(lambda last* [xs]
  (if (list? xs)
      (let [xs# xs]
        `(. xs# (length xs#)))
      `(. ,xs (length ,xs))))

(lambda join [sep xs]
  "Concatenate bare-string[] with `sep` in compile time."
  (table.concat xs sep))

;;; Type Conversion ///1

(lambda ->str [x]
  `(tostring ,x))

(lambda ->num [x]
  `(tonumber ,x))

(lambda ->nil [...]
  "Make sure to return `nil`."
  `(do
     ,...
     nil))

(lambda ->table [...]
  "Construct a Lua table, that is, an aassociative array.
  ```fennel
  (->table ...)
  ```
  @param ... The last argument must be kv-table.
  @return kv-table"
  (var i 1)
  (let [last-idx (select "#" ...)
        vargs (if (< 1 last-idx) [...]
                  (error (.. "expected two args at least, got " last-idx)))
        new-table (table.remove vargs)]
    (assert-compile (table? new-table) "Expected table for the last argument"
                    new-table)
    ;; Note: `collect` instead cannot bind to integers.
    (each [_ v (ipairs vargs)]
      (table.insert new-table i v)
      (++ i))
    new-table))

;;; Decision ///1

(lambda when-not [cond ...]
  `(when (not ,cond)
     ,...))

(lambda if-not [cond ...]
  `(if (not ,cond)
       ,...))

(lambda conditional-let [operator bindings ...]
  ;; Note: Fennel doesn't have the `if-let` macro from Clojure in favor of the
  ;; `match` macro according to https://fennel-lang.org/reference.
  (assert-compile (sequence? bindings) ;
                  (printf "bindings must be sequence, got %s\ndump:\n%s"
                          (type bindings) (view bindings))
                  bindings)
  (let [arg-num (length bindings)
        _ (assert-compile (even? arg-num) ;
                          (printf (.. "number of items in bindings must be even,"
                                      " got %d\ndump:\n%s")
                                  arg-num (view bindings))
                          bindings)
        assignees (fcollect [i 1 arg-num 2]
                    (operator (. bindings i)))
        predicate `(and ,(unpack assignees))]
    ;; Note: Technically, bindings should probably be done after testing, but
    ;; few reasons to complicate it for personal use at present.
    `(let ,bindings
       (if ,predicate
           ,...))))

(lambda if-let [bindings ...]
  (conditional-let #$ bindings ...))

(lambda when-let [bindings ...]
  (if-let bindings
    (do
      ...)))

(lambda if-some [bindings ...]
  (conditional-let #`(not= ,$ nil) bindings ...))

(lambda when-some [bindings ...]
  (if-some bindings
    (do
      ...)))

;;; File System ///1

(lambda executable? [x]
  "Check if `x` is executable command.
  @param x string
  @return boolean"
  `(= (vim.fn.executable ,x) 1))

(lambda mkdir [dir ?flag]
  "Create directory `dir` with `?flag` or \"p\"."
  (let [flag (or ?flag :p)]
    `(vim.fn.mkdir ,dir ,flag)))

(lambda expand [path]
  `(vim.fn.expand ,path))

(fn directory? [x]
  "Check if `x` is a directory.
  @param x string|nil If `nil`, induced from current buffer.
  @return boolean"
  (let [dir (or x (expand "%:h"))]
    `(= (vim.fn.isdirectory ,dir) 1)))

(fn file-readable? [x]
  "Check if `x` is a readable file.
  @param x string|nil If `nil`, check current buffer.
  @return boolean"
  (let [file (or x (expand "%"))]
    `(= (vim.fn.filereadable ,file) 1)))

(fn file-writable? [x]
  "Check if `x` is a writable file.
  @param x string|nil If `nil`, check current buffer.
  @return boolean"
  (let [file (or x (expand "%"))]
    `(= (vim.fn.filewritable ,file) 1)))

;;; Lua ///1

(lambda evaluate [x ...]
  "Evaluate function `x` with args `...`.
  @param x function
  @param ... any args for `x`
  @return any"
  ;; Note: `eval` instead is conflicted with fennel.eval.
  `(,x ,...))

(lambda for-each [func t]
  "Apply `func` to each value of `t`.
  @param func function
  @param t table
  @return table"
  (if (and (fn? func) (or (table? t) (sequence? t)))
      (collect [k v (pairs t)]
        (func k v))
      `(vim.tbl_map ,func ,t)))

(lambda export [func seq]
  "(Compile time) Export kv-table whose keys are  `t`
  @param func function
  @param seq sequence
  @return kv-table"
  (assert-compile (sequence? seq) (.. "expected sequence, got " (type seq)) seq)
  (for-each (fn [_ v]
              (assert-compile (sym? v) (.. "expected symbol, got " (type v)) v)
              (values (tostring v) `(,func ,v))) seq))

;;; Vim ///1

(lambda defer [timeout callback]
  `(vim.defer_fn ,callback ,timeout))

(lambda echo! [text ?hl-group]
  "Imitation of `:echo`. It doesn't write to `:messages`."
  (let [chunk (if ?hl-group [text ?hl-group] [text :Normal])]
    `(vim.api.nvim_echo [,chunk] false {})))

;; Note: buffer/window is a general term and could be conflicted.

(lambda valid-buf? [bufnr]
  "Check if buffer is valid."
  `(vim.api.nvim_buf_is_valid ,bufnr))

(lambda valid-win? [bufnr]
  "Check if window is valid."
  `(vim.api.nvim_win_is_valid ,bufnr))

(lambda invalid-buf? [win-id]
  "Check if buffer is invalid."
  `(not ,(valid-buf? win-id)))

(lambda invalid-win? [win-id]
  "Check if window is invalid."
  `(not ,(valid-win? win-id)))

(lambda set-cursor! [win-id pos]
  `(vim.api.nvim_win_set_cursor ,win-id ,pos))

(lambda doautocmd! [event|opts ?opts]
  "Wrapper of `nvim_exec_autocmds`.
  ```fennel
  (doautocmd! opts) ; opts can include `event` key to set event.
  (doautocmd! event opts) ; i.e., alias of nvim_exec_autocmds.
  (doautocmd! event pattern)
  ```
  @param event string
  @param opts kv-table
  @param pattern bare-string|bare-sequence
  "
  (if event|opts.event
      (let [{: event & rest} event|opts]
        `(vim.api.nvim_exec_autocmds ,event ,rest))
      (or (str? ?opts) (sequence? ?opts))
      `(vim.api.nvim_exec_autocmds ,event|opts {:pattern ,?opts})
      `(vim.api.nvim_exec_autocmds ,event|opts ,?opts)))

(lambda buf-augroup! [name ...]
  "`augroup!` whose name is suffixed by current buffer number."
  (let [new-name `(.. ,name "#" (vim.api.nvim_get_current_buf))]
    (augroup! new-name
      ...)))

(lambda buf->name [?buf]
  "Return the full file name of `?buf`.
  @param ?buf number Buffer handle. Leave it empty for current buffer.
  @return string"
  ;; Note: vim.api.nvim_buf_get_name() instead provides no way to get the name
  ;; of altername buffer.
  `(vim.fn.fnamemodify (vim.fn.bufname ,(or ?buf "")) ":p"))

(lambda str->keycodes [str]
  "Replace terminal codes and keycodes in a string.
  ```fennel
  (str->keycodes str)
  ```
  @param str string
  @return string"
  `(vim.api.nvim_replace_termcodes ,str true true true))

(lambda vim/has? [x]
  `(= (vim.fn.has ,x) 1))

(lambda vim/exists? [x]
  `(= (vim.fn.exists ,x) 1))

(fn vim/truthy? [expr]
  ;; Note: Lua expr is always truthy or falsy, so the prefix `vim-` is probably
  ;; unnecessary: it's a matter of taste.
  (if (list? expr)
      `(let [res# ,expr]
         (or (= res# 1) (= res# true)))
      `(or (= ,expr 1) (= ,expr true))))

(fn vim/falsy? [expr]
  (if (list? expr)
      `(let [res# ,expr]
         (or (= res# 0) (= res# false) (= res# nil)))
      `(or (= ,expr 0) (= ,expr false) (= ,expr nil))))

(lambda vim/emtpy? [expr]
  "A wrapper of `empty()` built in Vim script.
  `vim.fn.empty()` returns `1` with the results:
    - nil at runtime
    - vim.NIL
    - false
    - \"\", i.e., zero-length string
    - 0
    - {}
    - []
  @param expr any
  @return boolean"
  `(= (vim.fn.empty ,expr) 1))

(lambda vim/visualized []
  "Return the last visualized text. It only assumes the area in one line.
  @return string"
  `(-> (vim.fn.getline "'<") (: :sub (vim.fn.col "'<") (vim.fn.col "'>"))))

;;; Keymap ///2

(lambda lua->oneliner [lua-expr ...]
  (lua-expr:gsub "%s*\\n%s*" " "))

(lambda <Lua> [lua-expr ...]
  "Return `<Cmd>lua lua-expr<CR>` in string by `(<Lua> :lua-expr)`.
  Note: `lua` escape hatch is meaningless as return value in `expr` mapping.
  ```fennel
  (<Lua> lua-expr ...)
  ```
  @param lua-expr string
  @param ...
  @return string"
  (if (str? lua-expr)
      (let [lua-oneliner (-> (lua->oneliner lua-expr)
                             (: :format ...))]
        (.. "<Cmd>lua " lua-oneliner :<CR>))
      `(.. "<Cmd>lua " ,lua-expr :<CR>)))

(lambda <Lua>* [lua-expr ...]
  "Return `<Esc><Cmd>*lua lua-expr<CR>` in string by `(<Lua>* :lua-expr)`.
  ```fennel
  (<Lua>* lua-expr ...)
  ```
  @param lua-expr string
  @return string"
  (if (str? lua-expr)
      (let [lua-oneliner (-> (lua->oneliner lua-expr)
                             (: :format ...))]
        (.. "<Esc><Cmd>*lua " lua-oneliner :<CR>))
      `(.. "<Esc><Cmd>*lua " ,lua-expr :<CR>)))

(lambda <Cmd>* [vim-cmd]
  "Return `<Esc><Cmd>*vim-cmd<CR>` in string by `(<Cmd>* :vim-cmd)`.
  Note: `:vim-cmd<CR>` instead requires `silent` in `opts` not to show the line
  `vim-cmd` in cmdline.
  ```fennel
  (<Cmd>* vim-cmd)
  ```
  @param vim-cmd string
  @return string"
  (if (str? vim-cmd)
      (.. :<Esc><Cmd>* vim-cmd :<CR>)
      `(.. :<Esc><Cmd>* ,vim-cmd :<CR>)))

(lambda <C-u>* [vim-cmd]
  "Return `:vim-cmd<CR>` in string by `(<C-u>* :vim-cmd)`.
  It's a matter of taste.
  ```fennel
  (<C-u>* vim-cmd)
  ```
  @param vim-cmd string
  @return string"
  (if (str? vim-cmd)
      (.. ":" vim-cmd :<CR>)
      `(.. ":" ,vim-cmd :<CR>)))

(lambda <Plug> [text]
  "Return `<Plug>(text)` by `(<Plug> :text)`.
  ```fennel
  (<Plug> text)
  ```
  @param text string
  @return string"
  (if (str? text)
      (.. "<Plug>(" text ")")
      `(.. "<Plug>(" ,text ")")))

;; Wrappers ///3

(lambda nmap! [...]
  (map! :n ...))

(lambda vmap! [...]
  (map! :v ...))

(lambda xmap! [...]
  (map! :x ...))

(lambda smap! [...]
  (map! :s ...))

(lambda omap! [...]
  (map! :o ...))

(lambda imap! [...]
  (map! :i ...))

(lambda lmap! [...]
  (map! :l ...))

(lambda cmap! [...]
  (map! :c ...))

(lambda tmap! [...]
  (map! :t ...))

(lambda omni-map! [...]
  (map! ["" "!" :l :t] ...))

(lambda input-map! [...]
  (map! "!" ...))

(lambda range-map! [...]
  (map! [:n :x] ...))

(lambda keymap/invisible-key? [lhs]
  "Check if `lhs` is invisible key like `<Plug>`, `<CR>`, `<C-f>`, `<F5>`, etc.
  @param lhs string
  @return boolean"
  (or ;; cspell:ignore acdms
      ;; <C-f>, <M-b>, ...
      (and (lhs:match "<[acdmsACDMS]%-[a-zA-Z0-9]+>")
           (not (lhs:match "<[sS]%-[a-zA-Z]>"))) ;
      ;; <CR>, <Left>, ...
      (lhs:match "<[a-zA-Z][a-zA-Z]+>") ;
      ;; <k0>, <F5>, ...
      (lhs:match "<[fkFK][0-9]>")))

(lambda motion-map! [...]
  (let [[_ lhs] (if (= :string (type ...)) [nil ...] [...])]
    (if (keymap/invisible-key? lhs)
        (map! "" ...)
        (map! [:n :o :x] ...))))

(lambda textobj-map! [...]
  (map! [:o :x] ...))

(lambda swap-map! [modes lhs rhs]
  "Map keys to swap each non-recursively."
  `(do
     ,(map! modes lhs rhs)
     ,(map! modes rhs lhs)))

;;; Export ///1

{:unless when-not
 : when-not
 : if-not
 :nil? nil?*
 :bool? bool?*
 :true? true?*
 :false? false?*
 :str? str?*
 :num? num?*
 :fn? fn?*
 :seq? seq?*
 :tbl? tbl?*
 :odd? odd?*
 :even? even?*
 : ->str
 : ->num
 : ->nil
 : ->table
 : printf
 : println
 : inc
 : dec
 : ++
 : --
 :first first*
 :second second*
 :last last*
 : join
 : evaluate
 : for-each
 : export
 : set!
 : setlocal!
 : setglobal!
 : go!
 : bo!
 : wo!
 : g!
 : b!
 : w!
 : t!
 : v!
 : env!
 : map!
 : unmap!
 : command!
 : augroup!
 : augroup+
 : au!
 : autocmd!
 : doautocmd!
 : str->keycodes
 : feedkeys!
 : highlight!
 :hi! highlight!
 : executable?
 : directory?
 : file-readable?
 : file-writable?
 : mkdir
 : if-let
 : when-let
 : if-some
 : when-some
 : expand
 : defer
 : echo!
 : valid-buf?
 : valid-win?
 : invalid-buf?
 : invalid-win?
 : set-cursor!
 : buf-augroup!
 : buf->name
 : vim/has?
 : vim/exists?
 : vim/truthy?
 : vim/falsy?
 : vim/emtpy?
 : vim/visualized
 : <C-u>
 : <Cmd>
 : <Lua>
 : <Cmd>*
 : <C-u>*
 : <Lua>*
 : <Plug>
 : nmap!
 : vmap!
 : xmap!
 : smap!
 : omap!
 : imap!
 : lmap!
 : cmap!
 : tmap!
 : omni-map!
 : input-map!
 : range-map!
 : motion-map!
 : textobj-map!
 : swap-map!}
