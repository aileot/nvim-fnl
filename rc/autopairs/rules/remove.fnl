;; TOML: insert.toml
;; Repo: windwp/nvim-autopairs

(local Rule (require :nvim-autopairs.rule))

(local rep string.rep)

(fn remove-same-pairs-around [opts]
  ;; For <C-w>
  (let [{: line : col} opts
        preceding-chars (line:sub 1 (- col 1))
        following-chars (line:sub col)
        ;; Note: `doto` for `(: :match ...)` doesn't work expectedly.
        left-char (-> preceding-chars
                      (: :match "(%S)%s*$")
                      ;; Insert `%` before each open bracket for pattern match
                      (: :gsub "[%(%[%%]" "%%%0"))
        right-char (-> following-chars
                       (: :match "^%s*(%S)")
                       ;; Insert `%` before each close bracket for pattern match
                       (: :gsub "[%)%]%%]" "%%%0"))
        left-pattern (.. left-char "[" left-char "%s]*$")
        right-pattern (.. "^" right-char "[" right-char "%s]*")
        left-count (length (preceding-chars:match left-pattern))
        right-count (length (following-chars:match right-pattern))
        backspaces (rep :<BS> left-count)
        deletes (rep :<Del> (math.min left-count right-count))
        break-undo  "<C-g>u"
        keys (.. break-undo backspaces deletes)]
    keys))

(fn remove-any-pairs-around [opts]
  ;; For <C-u>
  (let [{: line : col} opts
        ;; Note: For example, when the count is `2`, `<C-u>` at `foo(|)`
        ;; removes all, but at `foo((|))` leaves `foo|` where `|` indicates
        ;; cursor position.
        count-to-remove-only-pairs 2
        break-undo :<C-g>u
        left-chars "{<%(%[%%\\'\""
        right-chars "}>%]%)%%\\'\""
        left-pattern (.. "[" left-chars "]")
        right-pattern (.. "[" right-chars "]")
        preceding-chars (line:sub 1 (- col 1))
        following-chars (line:sub col)
        left-count (length (preceding-chars:match (.. left-pattern "+$")))
        right-count (length (following-chars:match (.. "^" right-pattern "+")))
        deletes (rep :<Del> (math.min left-count right-count))
        keys (if (< left-count count-to-remove-only-pairs)
                 (.. break-undo :<C-u> deletes)
                 (let [backspaces (rep :<BS> left-count)
                       remove-only-pairs (.. backspaces deletes)]
                   (.. break-undo remove-only-pairs)))]
    keys))

(fn ctrl-w [...]
  (-> (Rule ...)
      (: :use_key :<C-w>)
      (: :replace_endpair
         (fn [opts]
           (remove-same-pairs-around opts)) true)))

(fn ctrl-u [...]
  (-> (Rule ...)
      (: :use_key :<C-u>)
      (: :replace_endpair
         (fn [opts]
           (remove-any-pairs-around opts)) true)))

(macro generate-rules []
  (let [rule-args [["(" ")"]
                   ["{" "}"]
                   ["[" "]"]
                   ["<" ">"]
                   ["`" "`"]
                   ["'" "'"]
                   ["\"" "\""]]
        escaped-rules [`(ctrl-u "\\(" "\\)")
                       `(ctrl-u "\\{" "\\}")
                       `(ctrl-u "\\[" "\\]")
                       `(ctrl-u "\\<" "\\>")]]
    `(do
       ,(icollect [_ args (ipairs rule-args) &into escaped-rules]
          `(do
             (ctrl-u ,(unpack args))
             (ctrl-w ,(unpack args)))))))

(generate-rules)
