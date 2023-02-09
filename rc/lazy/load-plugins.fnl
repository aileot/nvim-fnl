;; Pre: prerequisite/plugin/init.lua
;; $NVIM_DATA_HOME/lazy

(import-macros {: expand : directory?} :my.macros)

(local lazy (require :lazy))

;; Note: At present version of lazy.nvim cannot detect Fennel files,
;; hotpot.nvim would compile, i.e, rc/lazy/plugins/*.fnl.
(lazy.setup (require :rc.lazy.plugins)
            {:dev {:path (expand :$NVIM_DEV_HOME) :patterns [:aileot]}
             :git {:log "--since=2 week ago"
                   :url_format (when (directory? "~/.ssh")
                                 "ssh://github.com/%s.git")}
             :install {:missing true :colorscheme []}
             :readme {:files [:README.md :CHANGELOG.md]}
             :defaults {:lazy true :version "*"}
             :diff {:cmd :terminal_git}
             :checker {:enabled false}
             :performance {:rtp {:disabled_plugins [:gzip
                                                    :matchit
                                                    :matchparen
                                                    :netrwPlugin
                                                    :tarPlugin
                                                    :tohtml
                                                    :tutor
                                                    :zipPlugin]}}})
