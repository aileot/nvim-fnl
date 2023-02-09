;; TOML: motion.toml
;; Repo: ggandor/leap.nvim

(import-macros {: hi!} :my.macros)

(local {: opts} (require :leap))

(hi! :LeapMatch {:bold true :underline true :reverse true})
(hi! :LeapBackdrop {:fg "#777777" :ctermfg :Grey})

;; (hi! :LeapLabelPrimary {:fg :Magenta :bold true})
(set opts.case_sensitive false)

;; Max Ahead-Of-Time
(set opts.max_phase_one_targets 5000)

;; Highlight characters to auto-jump with the next input.
(set opts.highlight_unlabeled_phase_one_targets true)

; Replace apparent labels
(set opts.substitute_chars {"\n" "¬" "\r" ""})

;; Sets of characters to match each other.
;; Type one of the keys to match in a string/list.
(set opts.equivalence_classes [;; Spaces and newlines
                               " \t\r\n"
                               ;; Brackets
                               "([{<"
                               ">}])"
                               ;; Punctuations
                               ":;,.!/?"
                               ;; Arithmetic signs and underscore.
                               "-+=*^/_"
                               ;; Quotes
                               "\"'`"])

;; Runtime special keys
(set opts.special_keys {;; `:h leap-repeat`
                        :repeat_search :<Tab>
                        ;; :next_phase_one_target :<CR>
                        ;; `:h leap-traversal`
                        :next_target ","
                        :prev_target ";"
                        ;; `:h leap-usage`
                        :next_group :<C-a>
                        :prev_group :<C-x>
                        ;; Revert the last pick for multi-select
                        :multi_revert :<C-h>})

;; Leaving the appropriate list empty effectively disables "smart" mode,
;; and forces auto-jump to be on or off.
(set opts.labels [])

;; Move cursor to the first match before another input to confirm
;; position. In Operator-pending mode, the feature is ignored and the
;; `labels` are used unless it's empty.
;; The labels should be motion keys. Avoid prefix keys.
(set opts.safe_labels [:k
                       :l
                       :j
                       :h
                       :n
                       ;; Left Hand
                       :f
                       :w
                       :e
                       :t
                       :b
                       ;; By fifth finger (`;`/`,` is used in `special_keys`)
                       "'"
                       "/"
                       "["
                       "]"
                       :q])
