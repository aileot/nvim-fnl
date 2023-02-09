;; Help: $NVIM_DATA_HOME/lazy/lazy.nvim

(import-macros {: when-not : printf} :my.macros)

(local {: first : second : str? : function? : contains?} (require :my.utils))

(local under-local-development ;
       [:aileot/nvim-laurel
        :aileot/vim-among_HML
        :aileot/nvim-repeatable
        :aileot/nvim-sticky-cursor
        :aileot/nvim-spellhack
        :aileot/nvim-repeatable
        :aileot/ddc-source-typos])

(lambda normalize-name [url]
  "Extract plugin name from `url`.
  @param url string
  @return string"
  (-> url (: :gsub "^.*/" "") (: :gsub "%A*n?vim%A*" "")))

(fn mod->callback [mod]
  "Wrap `mod` in `require` or `vim.cmd` as callback function.
  @param mod string|string[]|function|nil
  @return 'function"
  ;; Note: To keep `&path` simpler for `gf`, do not construct `mod` having
  ;; trimmed module prefixes before.
  (let [loader (fn [m]
                 (assert-compile (str? m) (.. "expected string, got " (type m))
                                 m)
                 (if (m:find "^%$") `(vim.cmd ,(.. "source " m))
                     (m:find "%.vim$") `(vim.cmd ,(.. "runtime " m))
                     `(require ,m)))]
    (if (str? mod)
        `#,(loader mod)
        (sequence? mod)
        (if (second mod)
            `#(do
                ,(unpack (icollect [_ c (ipairs mod)]
                           (loader c))))
            `#,(loader (first mod)))
        mod)))

(lambda opts->spec [opts]
  "Adapt option names.
  @param opts kv-table
  @return kv-table"
  (let [spec (collect [k v (pairs opts)]
               (values k v))
        repo (. opts 1)]
    (when spec.deps
      (set spec.dependencies opts.deps)
      (set spec.deps nil))
    (if (repo:match "^[/~]")
        (do
          (set spec.dir repo)
          (tset spec 1 nil))
        (repo:match "^%$")
        (do
          (set spec.dir `(vim.fn.expand ,repo))
          (tset spec 1 nil))
        (repo:match "/.*/")
        (do
          (set spec.url repo)
          (tset spec 1 nil)))
    (set spec.init (mod->callback opts.init))
    (set spec.config (mod->callback opts.config))
    (when opts.cond
      ;; Note: lazy.nvim cannot tell _nil_ means whether nothing is set
      ;; at `cond` or the result of an expression but function, such as
      ;; `vim.g.foobar` and `(. foo :bar)`, is `nil`.
      (assert-compile (function? opts.cond)
                      "wrap `cond` value in builtin function constructor"
                      opts.cond))
    (when (contains? under-local-development repo)
      (set spec.dev true))
    spec))

(lambda disable [...]
  "Disable plugin.
  @param ...
  @return nil"
  nil)

(lambda preloaded [repo ?opts]
  "Construct spec table for `repo`, which is supposed to be loaded in advance
  without plugin manager, to make the plugin manager control the version of
  `repo`.
  @param repo string
  @param ?opts kv-table
  @return kv-table"
  (let [default-opts {1 repo}
        opts (if ?opts (collect [k v (pairs ?opts) &into default-opts]
                         (values k v)) ;
                 default-opts)]
    (opts->spec opts)))

(lambda on-startup [repo ?opts]
  "Construct spec table to load `repo` on startup.
  @param repo string
  @param ?opts kv-table
  @return kv-table"
  (let [default-opts {1 repo :lazy false}
        opts (if ?opts (collect [k v (pairs ?opts) &into default-opts]
                         (values k v)) ;
                 default-opts)]
    (opts->spec opts)))

(lambda on-demand [repo ?opts]
  "Construct spec table to load `repo` on demand.
  @param repo string
  @param ?opts kv-table
  @return kv-table"
  ;; Note: `lazy` is conflicted to the module lazy.nvim itself.
  (let [name (normalize-name repo)
        config-root (if (or (name:find "^ts%A") (name:find "^treesitter%A"))
                        (.. :rc.treesitter. name)
                        (name:find "^telescope%A")
                        (.. :rc.telescope. name)
                        (or (name:find "^dps%A") (name:find "^denops%A"))
                        (.. :rc.denops. name)
                        (.. :rc. name))
        default-config-module (printf "%s.setup" config-root)
        default-opts {1 repo
                      :event (if (and ?opts
                                      (or ?opts.event ?opts.keys ?opts.cmd
                                          ?opts.ft))
                                 nil
                                 :VeryLazy)
                      :config `#(pcall require ,default-config-module)}
        opts (if ?opts
                 (collect [k v (pairs ?opts) &into default-opts]
                   (values k v))
                 default-opts)]
    (opts->spec opts)))

(lambda dep [repo ?opts]
  "Construct spec table for `repo` in dependencies.
  @param repo string
  @param ?opts kv-table
  @return kv-table"
  (let [default-opts {1 repo}
        opts (if ?opts (collect [k v (pairs ?opts) &into default-opts]
                         (values k v)) ;
                 default-opts)]
    (opts->spec opts)))

(local colorscheme/opts {:priority 1000 :lazy false})
(lambda colorscheme [repo ?opts]
  "Construct spec table for colorscheme `repo`.
  @param repo string
  @param ?opts kv-table
  @return kv-table"
  (let [opts (if ?opts (collect [k v (pairs ?opts) &into colorscheme/opts]
                         (values k v)) ;
                 colorscheme/opts)]
    ;; (-- colorscheme/opts.priority)
    ;; Note: lazy=true is default in setup().
    ;; (set colorscheme/opts.lazy nil)
    (tset opts 1 repo)
    (opts->spec opts)))

(lambda trigger-map! [mode lhs ?rhs ?opts]
  (let [opts (or ?opts {})]
    (when-not (= mode :n)
      (tset opts :mode mode))
    (tset opts 1 lhs)
    (tset opts 2 ?rhs)
    opts))

{: disable
 : preloaded
 : on-startup
 : on-demand
 : dep
 : colorscheme
 : trigger-map!}
