;; TOML: appearance.toml
;; Repo: lukas-reineke/indent-blankline.nvim

(import-macros {: highlight! : augroup! : au! : g! : b!} :my.macros)

(macro opt! [opt-macro suffix val]
  `(,opt-macro ,(.. :indent_blankline_ suffix) ,val))

;; Note: The palettes derive primarily from https://coolors.co/334152

(macro theme->color-table [theme]
  (let [palettes {:square ["#334152" "#523350" "#524433" "#335234"]
                  :monochromatic [;; "#334152"
                                  "#4d637c"
                                  "#6884a7"
                                  "#82a6d1"
                                  "#9dc8fc"
                                  (comment "#191f27")]
                  :tints [;; "#334152"
                          "#3d4e62"
                          "#485b73"
                          "#526883"
                          "#5d7594"
                          "#6a83a2"]
                  :analogus ["#334152"
                             "#334d52"
                             "#334752"
                             "#334152"
                             "#333b52"
                             "#333552"]
                  ;; https://mycolor.space/?hex%23334152&sub=1.
                  :threedom ["#7f4f4d" "#557859"]
                  :squash ["#824735" "#166257"]
                  :twisted_spot ["#e09f20" "#ffedcb" "#8a7456"]
                  :neighbor ["#00c6b7" "#1f857c" "#334b48"]
                  :skip_shade ["#307b92" "#26babc" "#77fac6"]
                  :dotting ["#a0acbd" "#513941" "#bda5ad"]
                  :generic_gradient ["#24677e"
                                     "#009196"
                                     "#38ba96"
                                     "#93dd82"
                                     (comment "#f9f871")]
                  :matching_gradient ["#4d556d"
                                      "#6d6886"
                                      "#907b9d"
                                      "#b68eb0"
                                      "#dda2c0"]}]
    `(. ,palettes ,theme)))

;; (fn seq-back-and-forth [xs]
;;   " Append all the items but the first and the last ones in reverse order,
;;   i.e., convert `{'foo', 'bar', 'baz', 'qux'}` into
;;   `{'foo', 'bar', 'baz', 'qux', 'baz', 'bar'}`."
;;   (var i (inc (length xs)))
;;   (let [ys (vim.deepcopy xs)]
;;     (while (< 1 i)
;;       (table.insert ys (. xs i))
;;       (-- i))))

(fn generate-highlight-list! [theme]
  "Set vim highlights and return the list of highlight names in the define order."
  (icollect [idx hex (ipairs theme)]
    (let [prefix :IndentBlankline
          hl-name (.. prefix idx)
          hl-opts {:fg hex}]
      (highlight! hl-name hl-opts)
      hl-name)))

(local color-table (theme->color-table :generic_gradient))
(local highlight-list (generate-highlight-list! color-table))

(highlight! :IndentBlanklineContextStart ;
            {:fg "#C678DD" :ctermfg 164 :underline true})

(highlight! :IndentBlanklineContextChar ;
            {:fg "#C678DD" :ctermfg 164 :bold true})

(opt! g! :show_current_context true)
(opt! g! :use_treesitter true)
(opt! g! :show_first_indent_level true)

;; --- Draw an underline to the first line of current context.
;; (opt! g! show_current_context_start  true

(opt! g! :char_highlight_list highlight-list)
(opt! g! :space_char_highlight_list highlight-list)
(opt! g! :buftype_exclude [:acwrite
                           :help
                           ;; "nofile"
                           :nowrite
                           :prompt
                           :quickfix
                           :terminal])

(opt! g! :filetype_exclude [:agit
                            :agit_diff
                            :agit_stat
                            :fugitive
                            :git
                            :gitcommit
                            :gitrebase
                            :help
                            :markdown
                            :netrw
                            :noice
                            :twiggy])

(augroup! :rcIndentBlankline
  (au! :FileType [:defx] #(do
                            (set vim.bo.shiftwidth 4)
                            (opt! b! :indent_blankline_show_first_indent_level
                                  false))))
