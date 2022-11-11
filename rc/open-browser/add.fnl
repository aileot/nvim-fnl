;; TOML: web.toml
;; Repo: tyru/open-browser.vim

(import-macros {: inc : dec : printf : expand : nnoremap! : noremap-operator!}
               :my.macros)

(local {: Operator} (require :my.utils))

(lambda open-browser [text ?engine]
  "`:OpenBrowser text` or `:OpenBrowserSearch -engine text`"
  (if ?engine
      (vim.cmd.OpenBrowserSearch (.. "-" ?engine " " text))
      (vim.cmd.OpenBrowser text)))

(lambda new-range-open-browser [engine]
  (Operator.new (fn [start end]
                  (let [[row1 col1] start
                        [row2 col2] end
                        [line] ;
                        (vim.api.nvim_buf_get_lines 0 (dec row1) row2 true)
                        text (line:sub (inc col1) (inc col2))]
                    (if (engine:match "/$")
                        (open-browser (.. engine text))
                        (open-browser text engine))))))

(noremap-operator! :<BSlash>B
                   [:cb :unique :desc (printf "OpenBrowser \"<cfile>\"")]
                   #(open-browser (expand :<cfile>)))

(let [lhs-prefix :<BSlash>b
      ;; Note: Define each keymaps for which-key, though it is possible to
      ;; convert them into a keymap with `vim.fn.getcharstr` and `match`.
      key2engine {:y :duckduckgo&year
                  :m :duckduckgo&month
                  :d :duckduckgo
                  :a "archwiki@en"
                  :k :wikipedia
                  :l :gitlab
                  :t :thesaurus
                  :w :weblio}
      key2prefix {; Mnemonic: Secure
                  :S "https://"
                  ; Mnemonic: Url
                  :U "http://"
                  :G :github.com/
                  :H :git.sr.ht/}]
  (each [key engine (pairs key2engine)]
    (noremap-operator! (.. lhs-prefix key)
                       [:<callback>
                        :unique
                        :desc
                        (printf "OpenBrowser on \"%s\"" engine)]
                       (new-range-open-browser engine))
    (nnoremap! (.. lhs-prefix key key)
               [:<callback>
                :unique
                :desc
                (printf "OpenBrowser <cword> on \"%s\"" engine)]
               #(open-browser (expand :<cword>) engine)))
  (each [key url-prefix (pairs key2prefix)]
    (noremap-operator! (.. lhs-prefix key)
                       [:<callback>
                        :unique
                        :desc
                        (printf "OpenBrowser preceded by \"%s\"" url-prefix)]
                       (new-range-open-browser url-prefix))
    (nnoremap! (.. lhs-prefix key key)
               [:<callback>
                :unique
                :desc
                (printf "OpenBrowser \"%s<cfile>\"" url-prefix)]
               #(open-browser (.. url-prefix (expand :<cfile>))))))
