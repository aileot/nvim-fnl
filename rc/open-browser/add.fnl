;; TOML: web.toml
;; Repo: tyru/open-browser.vim

(import-macros {: printf : expand : nmap! : xmap! : range-map!} :my.macros)

(local {: Operator} (require :my.utils))

(lambda open-browser [text ?engine]
  "`:OpenBrowser text` or `:OpenBrowserSearch -engine text`"
  (if ?engine
      (vim.cmd.OpenBrowserSearch (.. "-" ?engine " " text))
      (vim.cmd.OpenBrowser text)))

(lambda new-range-open-browser [?engine]
  (Operator.new #(let [[line] (vim.api.nvim_buf_get_lines 0 $.row01 $.row2 true)
                       text (line:sub $.col1 $.col2)]
                   (if (and ?engine (?engine:match "/$"))
                       (open-browser (.. ?engine text))
                       (open-browser text ?engine)))))

(nmap! :<BSlash>bb [:unique :desc "OpenBrowser \"<cfile>\""]
       #(open-browser (expand :<cfile>)))

(xmap! :<BSlash>bb
       [:expr :unique :desc "OpenBrowser with visualized area as URL"]
       #(new-range-open-browser))

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
    (range-map! (.. lhs-prefix key)
                [:expr :unique :desc (printf "OpenBrowser on \"%s\"" engine)]
                #(new-range-open-browser engine))
    (nmap! (.. lhs-prefix key key)
           [:unique :desc (printf "OpenBrowser <cword> on \"%s\"" engine)]
           #(open-browser (expand :<cword>) engine)))
  (each [key url-prefix (pairs key2prefix)]
    (range-map! (.. lhs-prefix key)
                [:expr
                 :unique
                 :desc
                 (printf "OpenBrowser preceded by \"%s\"" url-prefix)]
                #(new-range-open-browser url-prefix))
    (nmap! (.. lhs-prefix key key)
           [:unique :desc (printf "OpenBrowser \"%s<cfile>\"" url-prefix)]
           #(open-browser (.. url-prefix (expand :<cfile>))))))
