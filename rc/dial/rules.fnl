;; TOML: default_mapping.toml
;; Repo: monaqa/dial.nvim

;; WIP

(local {: capitalize} (require :my.utils))

(local {: case
        : constant
        : date
        : hexcolor
        : integer
        : misc
        : paren
        : semver
        : user} (require :dial.augend))

(local {;; With Lua-pattern
        :find_pattern find-pattern
        ;; With vim.regex
        :find_pattern_regex find-regex} (require :dial.augend.common))

(local DATE date.alias)

(local {: bool : alpha : Alpha} constant.alias)
(local semantic-versioning semver.alias.semver)
(local {: markdown_header} misc.alias)

(local {;; natural numbers and 0
        :decimal natural-decimal
        ;; including negative numbers
        :decimal_int decimal
        : hex
        : octal
        : binary} integer.alias)

(local hexcolor-lower (hexcolor.new {:case :lower}))

(fn anywhere [elements]
  (let [regex (.. "\\(" (table.concat elements "\\|") "\\)")
        reversible-elements (vim.tbl_add_reverse_lookup (vim.deepcopy elements))]
    (user.new {:find (find-regex regex)
               :add (fn [old-text addend _cursor]
                      (let [max-idx (length elements)
                            old-idx (. reversible-elements old-text)
                            tmp-idx (% (+ old-idx addend) max-idx)
                            new-idx (if (= 0 tmp-idx) max-idx tmp-idx)
                            text (. elements new-idx)]
                        {: text :cursor 1}))})))

(macro words [elements]
  "Match elements only on a word boundary."
  `(constant.new {:elements ,elements :word true :cyclic true}))

(fn new-cycle [elements]
  (let [;; Note: case-sensitive pattern instead for the isolated pattern
        ;; ignores word boundary. Why?
        pat-template-isolated "\\C\\v%%(^|[^a-zA-Z])\\zs(%s)\\ze%%([^a-zA-Z]|$)"
        pat-template-capitalized "\\C\\v(%s)\\ze%%([^a-z]|$)"
        elements-upper (vim.tbl_map #($:upper) elements)
        elements-capitalized (vim.tbl_map capitalize elements)
        pat-elements-isolated ;
        (pat-template-isolated:format (.. (table.concat elements "|") "|"
                                          (table.concat elements-upper "|")))
        pat-elements-capitalized ;
        (pat-template-capitalized:format (table.concat elements-capitalized "|"))
        regex (.. pat-elements-isolated "|" pat-elements-capitalized)
        reversible-elements (vim.tbl_add_reverse_lookup (vim.deepcopy elements))]
    (user.new {:find (find-regex regex)
               :add (fn [old-text addend _cursor]
                      (let [max-idx (length elements)
                            old-idx (. reversible-elements (old-text:lower))
                            tmp-idx (% (+ old-idx addend) max-idx)
                            new-idx (if (= 0 tmp-idx) max-idx tmp-idx)
                            new-element (. elements new-idx)
                            text (if (old-text:match "^[A-Z][A-Z]")
                                     (new-element:upper)
                                     (old-text:match "^[A-Z]")
                                     (capitalize new-element)
                                     new-element)]
                        {: text :cursor 1}))})))

(local default [decimal
                (new-cycle [:true :false])
                (new-cycle [:old :new])
                (new-cycle [:min :max])
                (new-cycle [:with :without])
                (new-cycle [:no :any])
                (new-cycle [:row :col])
                (new-cycle [:increment :decrement])
                (new-cycle [:inc :dec])
                (new-cycle [:upper :lower])
                (new-cycle [:up :down])
                (new-cycle [:left :right])
                (new-cycle [:and :or])
                (anywhere ["--" "++"])
                (anywhere ["&&" "||"])
                (new-cycle [:prepend :append])
                (new-cycle [:precede :follow])
                (new-cycle [:preceding :following])
                (new-cycle [:next :previous])
                (new-cycle [:forward :backward])
                (new-cycle [:foreground :background])
                (words [:fg :bg])
                (new-cycle [:first :second :last])
                (new-cycle [:expected :actual])
                (new-cycle [:horizontal :vertical])
                (new-cycle [:before :after])
                (constant.new {:elements [:1st :2nd :3rd] :cyclic false})
                (words [:Sun :Mon :Tue :Wed :Thu :Fri :Sat])
                (anywhere [:Sunday
                           :Monday
                           :Tuesday
                           :Wednesday
                           :Thursday
                           :Friday
                           :Saturday])
                (words [:greedy :non-greedy])
                (words ["any of" "none of"])
                (anywhere [:<Home> :<End>])
                semantic-versioning
                hexcolor-lower
                (. DATE "%Y/%m/%d")
                (. DATE "%Y-%m-%d")
                (. DATE "%d.%m.%Y")
                (. DATE "%H:%M")
                hex
                binary])

(local vim [(anywhere ["\\\\zs" "\\\\ze"])
            (anywhere ["Enter " "Leave "])
            (anywhere ["Pre " "Post "])
            (words [:let :const])
            ;; extend()/tbl_extend()
            (words [:force :keep])
            (anywhere [" s:" " <SID>"])
            (anywhere [:<C-f> :<C-b>])
            (anywhere [:<C-d> :<C-u>])
            (anywhere [:<C-y> :<C-e>])
            (anywhere [:<C-a> :<C-x>])
            (anywhere [:<C-o> :<C-i>])
            (anywhere [:<C-h> :<C-w> (comment :<C-u>)])
            (anywhere ["winsaveview()" "winrestview(view)"])])

{: default
 :visual [(unpack default) alpha Alpha]
 :markdown [markdown_header]
 : vim
 :lua [(unpack vim)
       (anywhere ["==" "~="])
       (words [:start :end])
       (words [:setup :teardown])]
 :fennel [(unpack vim)
          (anywhere ["(=" "(not="])
          (words [:ctermfg :ctermbg])
          (anywhere [:buf- :win-])
          (words [:start :end])
          (words [:setup :teardown])]
 :java [(words [:private :protected :public])]
 :snippets [(anywhere ["`!v " "!p snip.rv = "])]}
