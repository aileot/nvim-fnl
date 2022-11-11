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
        : g!
        : b!
        : w!
        : t!
        : v!
        : env!
        : noremap!
        : map!
        : unmap!
        : noremap-all!
        : noremap-motion!
        : noremap-textobj!
        : noremap-input!
        : noremap-operator!
        : nnoremap!
        : vnoremap!
        : xnoremap!
        : snoremap!
        : onoremap!
        : inoremap!
        : lnoremap!
        : cnoremap!
        : tnoremap!
        : map-all!
        : map-motion!
        : map-textobj!
        : map-input!
        : map-operator!
        : nmap!
        : vmap!
        : xmap!
        : smap!
        : omap!
        : imap!
        : lmap!
        : cmap!
        : tmap!
        : <C-u>
        : <Cmd>
        : command!
        : augroup!
        : augroup+
        : au!
        : autocmd!
        : str->keycodes
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

;; Decision ///1

(lambda unless [cond ...]
  `(if (not ,cond)
       ,...))

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

(lambda expand [path ?mods]
  "Expand special keywords with either vim.fn.expand, vim.fs.normalize, or
  vim.fn.fnamemodify."
  (if ?mods `(vim.fn.fnamemodify ,path ,?mods)
      (or (sym? path) (list? path)
          (and (str? path) ;
               (or (path:match "[%#*:]") (path:match "<%S+>")))) ;
      (if (contains? ["%" "%:p"] path)
          `(-> (vim.api.nvim_get_current_buf)
               (vim.api.nvim_buf_get_name))
          `(vim.fn.expand ,path)) ;
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
  `(vim.api.nvim_echo [[,text ,?hl-group]] false {}))

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

;; Export ///1

{: unless
 :when-not unless
 :if-not unless
 : nil?
 : bool?
 : str?
 : num?
 : fn?
 : seq?
 : tbl?
 : ->str
 : ->num
 : ->nil
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
 : g!
 : b!
 : w!
 : t!
 : v!
 : env!
 : noremap!
 : map!
 : unmap!
 : noremap-all!
 : noremap-motion!
 : noremap-textobj!
 : noremap-input!
 : noremap-operator!
 : nnoremap!
 : vnoremap!
 : xnoremap!
 : snoremap!
 : onoremap!
 : inoremap!
 : lnoremap!
 : cnoremap!
 : tnoremap!
 : map-all!
 : map-motion!
 : map-textobj!
 : map-input!
 : map-operator!
 : nmap!
 : vmap!
 : xmap!
 : smap!
 : omap!
 : imap!
 : lmap!
 : cmap!
 : tmap!
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
 : expand
 : has?
 : exists?
 : defer
 : echo!
 : valid-buf?
 : valid-win?
 : invalid-buf?
 : invalid-win?
 : <C-u>
 : <Cmd>}
