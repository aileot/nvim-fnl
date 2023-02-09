;; Ref: $VIMRUNTIME/ftplugin/fennel.vim

(local {: set-undoable!} (require :my.utils))

(lambda set-options []
  (set-undoable! :lisp)
  (set-undoable! :suffixesAdd [:.fnl :.lua :.vim])
  (set-undoable! :comments [":;;" ":;"])
  (set-undoable! :commentString ";; %s")
  (set-undoable! :isKeyword ["$"
                             "%"
                             "#"
                             "*"
                             "+"
                             "-"
                             "/"
                             "<"
                             "="
                             ">"
                             "?"
                             "_"
                             :a-z
                             :A-Z
                             :48-57
                             :128-247
                             :124
                             :126
                             :38
                             :94])
  (set-undoable! :lispWords [:accumulate
                             :collect
                             :do
                             :doto
                             :each
                             :eval-compiler
                             :faccumulate
                             :fcollect
                             :fn
                             :for
                             :icollect
                             :if
                             :lambda
                             :let
                             :local
                             :macro
                             :macros
                             :match
                             :match-try
                             :partial
                             :var
                             :when
                             :while
                             :with-open
                             "λ"]))

(fn setup []
  (set-options))

setup
