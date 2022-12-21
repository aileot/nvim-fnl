;; Import ///1
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

(lambda contains? [xs ?a]
  "Check if `?a` is in `xs`."
  (accumulate [eq? false ;
               _ x (ipairs xs) ;
               &until eq?]
    (= ?a x)))

;; Predicate ///1

(fn nil? [x]
  "Check if value of 'x' is nil."
  `(= nil ,x))

(fn bool? [x]
  "Check if 'x' is of boolean type."
  `(= :boolean (type ,x)))

(fn str? [x]
  "Check if `x` is of string type."
  `(= :string (type ,x)))

(fn fn? [x]
  "(Runtime time) Check if type of `x` is function."
  `(= :function (type ,x)))

(fn num? [x]
  "Check if 'x' is of number type."
  `(= :number (type ,x)))

(fn seq? [x]
  "Check if `x` is a sequence."
  `(not (nil? (. ,x 1))))

(fn tbl? [x]
  "Check if `x` is of table type.
  table?, sequence?, etc., is only available in compile time."
  `(= (type ,x) :table))

(fn even? [x]
  "Check if `x` is even number."
  `(and ,(num? x) (= 0 (% ,x 2))))

(fn odd? [x]
  "Check if `x` is odd number."
  `(and ,(num? x) (= 1 (% ,x 2))))

;; String ///1

(lambda printf [str ...]
  `(string.format ,str ,...))

(lambda println [str ...]
  (if (str? str)
      `(string.format ,(.. str "\n") ,...)
      `(string.format (.. ,str "\n") ,...)))

;; Number ///1

(lambda inc [x]
  "Return incremented result"
  `(+ ,x 1))

(lambda dec [x]
  "Return decremented result"
  `(- ,x 1))

(lambda ++ [x]
  "Increment `x` by 1"
  `(do
     (set ,x (+ 1 ,x))
     ,x))

(lambda -- [x]
  "Decrement `x` by 1"
  `(do
     (set ,x (- 1 ,x))
     ,x))

;; Table ///1

(lambda first [xs]
  `(. ,xs 1))

(lambda second [xs]
  `(. ,xs 2))

(lambda last [xs]
  `(. ,xs (length ,xs)))

(lambda join [sep xs]
  "Concatenate bare-string[] with `sep` in compile time."
  (table.concat xs sep))

;; Type Conversion ///1

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

;; Decision ///1

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

;; File System ///1

(lambda executable? [x]
  "Check if `x` is executable command."
  `(= 1 (vim.fn.executable ,x)))

(lambda directory? [x]
  "Check if `x` is a directory."
  `(= 1 (vim.fn.isdirectory ,x)))

(lambda mkdir [dir ?flag]
  "Create directory `dir` with `?flag` or \"p\"."
  (let [flag (or ?flag :p)]
    `(vim.fn.mkdir ,dir ,flag)))

(lambda expand [path]
  "Expand special keywords with either vim.fn.expand or vim.fs.normalize."
  (if (or (sym? path) (list? path)
          (and (str? path) ;
               (or (path:match "[%#*:]") (path:match "<%S+>"))))
      (if (contains? ["%" "%:p"] path)
          `(-> (vim.api.nvim_get_current_buf)
               (vim.api.nvim_buf_get_name))
          `(vim.fn.expand ,path))
      `(vim.fs.normalize ,path)))

;; Vim ///1

;; Note: We are unlikely to have these ambiguous, general term functions in our
;; codes to get conflicted with, like `has?`, `exists?`.

(lambda has? [x]
  `(= 1 (vim.fn.has ,x)))

(lambda exists? [x]
  `(= 1 (vim.fn.exists ,x)))

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

(fn vim-truthy? [expr]
  ;; Note: Lua expr is always truthy or falsy, so the prefix `vim-` is probably
  ;; unnecessary: it's a matter of taste.
  (if (list? expr)
      `(let [res# ,expr]
         (or (= res# 1) (= res# true)))
      `(or (= ,expr 1) (= ,expr true))))

(fn vim-falsy? [expr]
  (if (list? expr)
      `(let [res# ,expr]
         (or (= res# 0) (= res# false) (= res# nil)))
      `(or (= ,res 0) (= ,res false) (= ,res nil))))

(lambda str->keycodes [str]
  "Replace terminal codes and keycodes in a string.
  ```fennel
  (str->keycodes str)
  ```
  @param str string
  @return string"
  `(vim.api.nvim_replace_termcodes ,str true true true))

;; Keymap ///2
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

;; Export ///1

{:unless when-not
 : when-not
 : if-not
 : nil?
 : bool?
 : str?
 : num?
 : fn?
 : seq?
 : tbl?
 : odd?
 : even?
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
 : first
 : second
 : last
 : join
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
 : mkdir
 : if-let
 : when-let
 : if-some
 : when-some
 : expand
 : has?
 : exists?
 : defer
 : echo!
 : valid-buf?
 : valid-win?
 : invalid-buf?
 : invalid-win?
 : set-cursor!
 : buf-augroup!
 : vim-truthy?
 : vim-falsy?
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
