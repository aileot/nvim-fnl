;; TOML: motion.toml
;; Repo: ggandor/leap.nvim

(import-macros {: hi!} :my.macros)

(local leap (require :leap))

(hi! :LeapMatch {:fg :White :bold true})

(hi! :LeapBackdrop {:fg "#777777" :ctermfg :Grey})

;; (hi! :LeapLabelPrimary {:fg :Magenta :bold true})

(let [;; Replace apparent labels
      substitute_chars {"\n" "¬" "\r" ""}
      ;; Sets of characters to match each other.
      ;; Type one of the keys to match in a string/list.
      equivalence_classes [;; Spaces and newlines
                           " \t\r\n"
                           ;; Brackets
                           "([{<"
                           ">}])"
                           ;; Punctuations
                           ":;,.!/?"
                           ;; Arithmetic signs and underscore.
                           "-+=*^/_"
                           ;; Quotes
                           "\"'`"]
      ;; Runtime special keys
      special_keys {;; `:h leap-repeat`
                    :repeat_search :<CR>
                    ;; `:h leap-traversal`
                    :next_target ","
                    :prev_target ";"
                    ;; `:h leap-usage`
                    :next_group :<C-n>
                    :prev_group :<C-p>
                    ;; Revert the last pick for multi-select
                    :multi_revert [:<BS> :<C-h> :<C-c> "<C-[>"]}
      ;; Leaving the appropriate list empty effectively disables "smart" mode,
      ;; and forces auto-jump to be on or off.
      labels []
      ;; Move cursor to the first match before another input to confirm
      ;; position. In Operator-pending mode, the feature is ignored and the
      ;; `labels` are used unless it's empty.
      ;; The labels should be motion keys. Avoid prefix keys.
      safe_labels [:k
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
                   ;; By fifth finger (`;`/`,` is reserved in `special_keys`)
                   "'"
                   "/"
                   "["
                   "]"
                   :q]]
  (leap.setup {:case_sensitive false
               ;; Max Ahead-Of-Time
               :max_phase_one_targets 5000
               ;; Highlight characters to auto-jump with the next input.
               :highlight_unlabeled_phase_one_targets true
               : substitute_chars
               : equivalence_classes
               : labels
               : safe_labels
               : special_keys}))
