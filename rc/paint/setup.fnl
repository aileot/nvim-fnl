;; TOML: treesitter.toml
;; Repo: folke/paint.nvim

(import-macros {: hi! : expand} :my.macros)

(local {: contains?} (require :my.utils))

(local paint (require :paint))

(hi! :TrailingWhitespaces {:bg :Red})

;; Note: filter value is table<option-name,value> or fun(buf: number): boolean.

(fn practical-file? [buf]
  (let [bo (. vim.bo buf)]
    (when (and bo.modifiable (not bo.readonly) (contains? [""] bo.buftype))
      (let [path (expand "%:p")
            pat-no-extension "/[^.]+$"
            unpractical-patterns [pat-no-extension
                                  "%.md$"
                                  "%.log$"
                                  "%.te?xt$"
                                  "%.ya?ml$"
                                  :/tmp/
                                  :/tests?/
                                  "[-_.]spec%."]
            unpractical? (accumulate [matched? false ;
                                      _ pattern (ipairs unpractical-patterns) ;
                                      &until matched?]
                           (-> path (: :match pattern)))]
        (not unpractical?)))))

(local foo {:filter practical-file? :pattern :foo :hl :Todo})

(local foobar {:filter practical-file? :pattern :foobar :hl :Todo})

;; cspell:enable

(local todos {:filter (fn [buf]
                        (contains? [""] (. vim.bo buf :buftype)))
              :pattern "^%s*[^a-zA-Z0-9_%s]+ ([A-Z][A-Z]+):"
              :hl :Todo})

(local annotation-title {:filter (fn [buf]
                                   (contains? [""] (. vim.bo buf :buftype)))
                         :pattern "^%s*[^a-zA-Z0-9_%s]+ ([A-Z][a-z]+):"
                         :hl :PreProc})

(local WIP-marker {:filter #true :pattern "WIP:" :hl :InvalidChar})

(local breaking-change {:filter (fn [buf]
                                  (let [bo (. vim.bo buf)]
                                    (if (contains? [:terminal] bo.buftype) true
                                        (let [?filetype bo.filetype]
                                          (when ?filetype
                                            (?filetype:match :^git))))))
                        :pattern "(%S+!:) "
                        :hl :InvalidChar})

(local trailing-whitespaces
       {:filter (fn [buf]
                  (let [bo (. vim.bo buf)]
                    (when (and bo.modifiable (not bo.readonly))
                      (and (not (contains? [:prompt] bo.buftype))
                           (not (contains? [:markdown] bo.filetype))))))
        :pattern "%s+$"
        :hl :TrailingWhitespaces})

(local lua-annotation {:filter {:filetype :lua}
                       :pattern "^%s*%-%-%-%s*(@[a-z]+)"
                       :hl :Constant})

(local fennel-annotation {:filter {:filetype :fennel}
                          :pattern "^  %s*(@[a-z]+)"
                          :hl :Constant})

;; Note: The latter config is set, the higher it get priority.
(local highlights [foo
                   foobar
                   todos
                   annotation-title
                   WIP-marker
                   breaking-change
                   trailing-whitespaces
                   lua-annotation
                   fennel-annotation])

(paint.setup {: highlights})
