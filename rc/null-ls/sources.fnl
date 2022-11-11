;; TOML: lsp.toml
;; Repo: jose-elias-alvarez/null-ls.nvim
;; Path: $PLUGINS_PACK_HOME/opt/null-ls.nvim

(macro set-severity [sev]
  `(fn [diag#]
     (tset diag# :severity ,sev)))

(local sources ;
       (let [{: builtins : methods} (require :null-ls)
             {: hover :code_actions code-actions : formatting : diagnostics} builtins
             SEVERITY vim.diagnostic.severity
             normalize vim.fs.normalize
             editable-buffer? #(and vim.bo.modifiable (not vim.bo.readonly))]
         ;; [README](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md)
         ;; Note: You can modify each builtin source in `.with()`.
         [(comment hover.dictionary)
          code-actions.eslint_d
          ;; code-actions.proselint
          ;; code-actions.gitsigns
          code-actions.gitrebase
          ;; Note: With cspell code-actions enabled, diagnostic also slows
          ;; down.
          ;; code-actions.cspell
          ;; diagnostics.selene
          ;; diagnostics.shellcheck
          diagnostics.fish
          (diagnostics.flake8.with [:--extend-ignore=E203
                                    :--max-line-length=88])
          ;; (diagnostics.xo.with [:--prettier])
          ;; diagnostics.statix
          diagnostics.eslint_d
          ;; diagnostics.hadolint
          ;; diagnostics.vint
          ;; diagnostics.semgrep
          ;; diagnostics.proselint
          ;; diagnostics.misspell
          (comment ;
            ;; Note: To run commitlint with `@commitlint/config-conventional`, the
            ;; extension must be installed in the same root of `commitlintrc` file is
            ;; located. For global use, you can set commitlintrc at $HOME, but you must
            ;; also install `@commitlint/config-conventional` at $HOME; however, it comes
            ;; to launch unexpected language servers regarding $HOME as a root because of
            ;; either `node_modules/` or `package.json`.
            ;; Ref: https://github.com/conventional-changelog/commitlint/issues/613
            diagnostics.commitlint)
          ;; (diagnostics.codespell.with {:condition editable-buffer?})
          (diagnostics.cspell.with {;; :method methods.DIAGNOSTICS_ON_SAVE
                                    :condition editable-buffer?
                                    :extra_args [:--config
                                                 (normalize :$XDG_CONFIG_HOME/cspell/cspell.yaml)]
                                    :diagnostic_config {:sign false}
                                    :diagnostics_postprocess ;
                                    (set-severity SEVERITY.WARN)})
          ;; (diagnostics.write_good.with {:filetypes [:markdown
          ;;                                           :org
          ;;                                           :text
          ;;                                           :txt
          ;;                                           :help]
          ;;                               :condition editable-buffer?
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
          formatting.deno_fmt
          ;; formatting.eslint
          formatting.eslint_d
          formatting.json_tool
          ;; Python
          formatting.black
          (formatting.isort.with {:extra_args [:--profile=black]})
          ;; formatting.yapf
          ;; formatting.autopep8
          formatting.stylua
          ;; formatting.fnlfmt
          (formatting.fnlfmt.with {:extra_args [:--body-forms
                                                (table.concat [:unless
                                                               :when-not
                                                               :if-not
                                                               :augroup!
                                                               :insulate
                                                               :describe
                                                               :it]
                                                              ",")]})
          ;; formatting.yamlfmt
          formatting.fixjson
          formatting.sqlformat]))

;; Export ///1
;; Note: Export sources without `nil`s because of the tricks with
;; `(comment ...)` for diagnostics.

(local S [])
(each [_ v (pairs sources)]
  (when v
    (table.insert S v)))

S
