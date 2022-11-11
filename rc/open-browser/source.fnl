;; TOML: web.toml
;; Repo: tyru/open-browser.vim

(import-macros {: g!} :my.macros)

;; (g! :openbrowser_message_verbosity 1)

(g! :openbrowser_use_vimproc false)
(g! :openbrowser_force_foreground_after_open true)
(g! :openbrowser_default_search :duckduckgo)

(g! :openbrowser_browser_commands
    [{:name :qutebrowser :args ["{browser}" "{uri}"]}
     {:name :xdg-open :args ["{browser}" "{uri}"]}
     {:name :w3m :args ["{browser}" "{uri}"]}])

;; fnlfmt: skip
(g! :openbrowser_search_engines
    {:alc "https://eow.alc.co.jp/{query}/UTF-8/"
     "archwiki@en" "https://wiki.archlinux.org/index.php?search={query}"
     "archwiki@ja" "https://wiki.archlinux.jp/index.php?search={query}"
     :askubuntu "https://askubuntu.com/search?q={query}"
     :blekko "https://blekko.com/ws/+{query}"
     :cpan "https://search.cpan.org/search?query={query}"
     :devdocs "https://devdocs.io/#q={query}"
     :duckduckgo "https://duckduckgo.com/?q={query}"
     :duckduckgo&year "https://duckduckgo.com/?q={query}&df=y"
     :duckduckgo&week "https://duckduckgo.com/?q={query}&df=w"
     :duckduckgo&month "https://duckduckgo.com/?q={query}&df=m"
     :duckduckgo&day "https://duckduckgo.com/?q={query}&df=d"
     :github "https://github.com/search?q={query}"
     :google "https://google.com/search?q={query}"
     :go "https://golang.org/search?q={query}"
     :google-code "http://code.google.com/intl/en/query/#q={query}"
     :php "http://php.net/{query}"
     :python "http://docs.python.org/dev/search.html?q={query}&check_keywords=yes&area=default"
     "microsoft academic" "https://academic.microsoft.com/search?q={query}"
     "dictionary@en" "https://www.thefreedictionary.com/{query}"
     :thesaurus "https://www.freethesaurus.com/{query}"
     :twitter-search "https://twitter.com/search/{query}"
     :twitter-user "https://twitter.com/{query}"
     :verycd "https://www.verycd.com/search/entries/{query}"
     :weblio "https://ejje.weblio.jp/content/{query}?erl=true"
     :wikipedia "https://en.wikipedia.org/wiki/{query}"
     :wikipedia-ja "https://ja.wikipedia.org/wiki/{query}"
     :yahoo "https://search.yahoo.com/search?p={query}"})
