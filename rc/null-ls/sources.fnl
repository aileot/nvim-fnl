;; TOML: lsp.toml
;; Repo: jose-elias-alvarez/null-ls.nvim

(import-macros {: expand} :my.macros)

(local {: builtins : methods} (require :null-ls))
(local {: hover :code_actions code-actions : formatting : diagnostics} builtins)
(local ?embedded-format (match (pcall require :null-ls-embedded)
                          (true mod) mod.nls_source))

(local SEVERITY vim.diagnostic.severity)
(local {: compact} (require :my.utils))

(macro set-severity [sev]
  `(fn [diag#]
     (tset diag# :severity ,sev)))

(fn editable-buffer? []
  (and vim.bo.modifiable (not vim.bo.readonly)))

;; [README](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md)
(local sources ;
       [(comment hover.dictionary)
        ;; code-actions.eslint_d
        ;; code-actions.proselint
        ;; code-actions.gitsigns
        code-actions.gitrebase
        diagnostics.actionlint
        ;; Note: With cspell code-actions enabled, diagnostic also slows
        ;; down.
        ;; code-actions.cspell
        ;; diagnostics.selene
        ;; diagnostics.shellcheck
        diagnostics.fish
        (diagnostics.flake8.with [:--extend-ignore=E203 :--max-line-length=88])
        ;; (diagnostics.xo.with [:--prettier])
        ;; diagnostics.statix
        ;; diagnostics.eslint_d
        ;; diagnostics.hadolint
        ;; diagnostics.vint
        ;; diagnostics.semgrep
        ;; diagnostics.proselint
        ;; diagnostics.misspell
        (comment ;
          ;; Note: To run commitlint with `@commitlint/config-conventional`,
          ;; the extension must be installed in the same root of `commitlintrc`
          ;; file is located. For global use, you can set commitlintrc at $HOME,
          ;; but you must also install `@commitlint/config-conventional` at
          ;; $HOME; however, it comes to launch unexpected language servers
          ;; regarding $HOME as a root because of either `node_modules/` or
          ;; `package.json`.
          ;; Ref: https://github.com/conventional-changelog/commitlint/issues/613
          diagnostics.commitlint)
        ;; (diagnostics.codespell.with {:runtime_condition editable-buffer?})
        (diagnostics.cspell.with {:method methods.DIAGNOSTICS_ON_SAVE
                                  :runtime_condition editable-buffer?
                                  :disabled_filetypes [:log :markdown :c :cpp]
                                  :extra_args [:--config
                                               (expand :$XDG_CONFIG_HOME/cspell/cspell.yaml)]
                                  :diagnostic_config {:sign false}
                                  :diagnostics_postprocess ;
                                  (set-severity SEVERITY.WARN)})
        ;; (diagnostics.write_good.with {:filetypes [:markdown
        ;;                                           :org
        ;;                                           :text
        ;;                                           :txt
        ;;                                           :help]
        ;;                               :runtime_condition editable-buffer?
        ;;                               :diagnostic_config {:signs false}
        ;;                               :diagnostics_postprocess ;
        ;;                               (set-severity SEVERITY.HINT)})
        diagnostics.markdownlint_cli2
        ;; ;; Written in Python.
        ;; ;; Use yamlfmt instead. The recommendations are conflicted.
        ;; diagnostics.yamllint
        formatting.shellharden
        formatting.fish_indent
        formatting.rustfmt
        (formatting.deno_fmt.with {:extra_args (fn [a]
                                                 ;; Respect textwidth & shiftwidth for now.
                                                 ;; Ref: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1322
                                                 ;; Ref: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1325
                                                 (let [bo (. vim.bo a.bufnr)
                                                       opts {:--options-line-width (when (< 0
                                                                                            bo.textwidth)
                                                                                     bo.textwidth)
                                                             :--options-indent-width (when (< 0
                                                                                              bo.shiftwidth)
                                                                                       bo.shiftwidth)}
                                                       args []]
                                                   (each [k ?v (pairs opts)]
                                                     (when ?v
                                                       (table.insert args k)
                                                       (table.insert args ?v)))
                                                   args))})
        ;; formatting.eslint
        formatting.eslint_d
        ;; Python
        formatting.black
        (formatting.isort.with {:extra_args [:--profile=black]})
        ;; formatting.yapf
        ;; formatting.autopep8
        formatting.stylua
        ;; formatting.fnlfmt
        ;; cspell:word prettierd
        (formatting.prettierd.with {;; Disable in favor of deno_fmt
                                    :disabled_filetypes [:javascript
                                                         :javascriptreact
                                                         :json
                                                         :jsonc
                                                         :markdown
                                                         :typescript
                                                         :typescriptreact]})
        (formatting.fnlfmt.with {:extra_args [:--body-forms
                                              (table.concat [:unless
                                                             :if-not
                                                             :when-not
                                                             :if-let
                                                             :when-let
                                                             :if-some
                                                             :when-some
                                                             :augroup!
                                                             :buf-augroup!
                                                             :insulate
                                                             :describe
                                                             :it
                                                             :pending]
                                                            ",")]})
        ;; formatting.yamlfmt
        formatting.sqlformat
        ?embedded-format])

;; Export ///1
;; Note: Export sources without `nil`s because of the tricks with
;; `(comment ...)` for diagnostics.

(compact sources)
