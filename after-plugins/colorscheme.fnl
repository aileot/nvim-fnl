(import-macros {: highlight! : augroup! : au!} :my.macros)

(local default-theme :spring-night)

(do
  (macro source-config-files! [theme fname]
    `(pcall require (.. :rc. ,theme "." ,fname)))
  ;; `(let [underscored# (: ,theme :gsub "_" "-")]
  ;;    trimmed#
  ;;    (: ,theme :match "^[a-zA-Z0-9]+")
  ;;    (do
  ;;      (each [_# dir# (ipairs [,theme underscored# trimmed#])]
  ;;        ;; (pcall vim.cmd.source (.. :$DEIN_RC_DIR/ dir# "/" ,fname :.lua))
  ;;        ;; (pcall vim.cmd.source (.. :$DEIN_RC_DIR/ dir# "/" ,fname :.vim))
  ;;        (require (.. :rc. dir# "." ,fname))))))

  (fn highlight-diagnostics! []
    (if (= vim.go.background :dark)
        (do
          (highlight! :DiagnosticError {:fg :Red})
          (highlight! :DiagnosticWarn {:fg :Yellow})
          (highlight! :DiagnosticInfo {:fg :Green})
          (highlight! :DiagnosticHint {:fg :Cyan})
          (highlight! :DiagnosticUnderlineError {:underline true :fg :LightRed})
          (highlight! :DiagnosticUnderlineWarn
                      {:underline true :fg :DarkYellow})
          (highlight! :DiagnosticUnderlineInfo
                      {:underline true :fg :LightGreen})
          (highlight! :DiagnosticUnderlineHint {:underline true :fg :LightCyan}))
        (do
          (highlight! :DiagnosticError {:bold true :fg :Red})
          (highlight! :DiagnosticWarn {:bold true :fg :Magenta})
          (highlight! :DiagnosticInfo {:bold true :fg :Green})
          (highlight! :DiagnosticHint {:bold true :fg :Blue})
          (highlight! :DiagnosticUnderlineError {:underline true :fg :Red})
          (highlight! :DiagnosticUnderlineWarn {:underline true :fg :Magenta})
          (highlight! :DiagnosticUnderlineInfo {:underline true :fg :Green})
          (highlight! :DiagnosticUnderlineHint {:underline true :fg :Blue}))))

  ;; (fn highlight-transparent-background! []
  ;;   (do
  ;;     (highlight! :Normal {:bg :NONE})
  ;;     (highlight! :NonText {:bg :NONE})
  ;;     (highlight! :LineNr {:bg :NONE})
  ;;     (highlight! :Folded {:bg :NONE})
  ;;     (highlight! :EndOfBuffer {:bg :NONE})
  ;;     (highlight! :CursorLine {:bg :NONE})
  ;;     (highlight! :SignColumn {:bg :NONE})))

  (fn highlight-common-dark! []
    (do
      (highlight! :TODO {:bold true :ctermfg 15 :fg "#e6e5e5"})
      ;;  NormalFloat: color for winblend, or floating windows)
      ;; (highlight! :NormalFloat {:ctermfg 236 :ctermbg 180 :bg :#3a192c :fg :#c5bf6a})
      ;; NormalNC: Colors for unfocused windows.
      (highlight! :NormalNC {:ctermfg 249 :fg "#f0f0f0"})))

  (fn highlight-common! []
    (do
      (when (= vim.go.background :dark)
        (highlight-common-dark!))
      (highlight-diagnostics!)
      ;; (highlight-transparent-background!)
      (highlight! :EndOfBuffer {:link :Ignore})
      (highlight! :TermCursor {:reverse true :underline true})
      (highlight! :TermCursorNC {:fg :Red :bold true})
      ;; (highlight! :Comment {:fg :#71716e})
      (highlight! :Conceal {:link :Normal})
      (highlight! :CursorIM {:bg "#fabd1f" :ctermbg :Yellow})
      (highlight! :MatchParen {:fg "#e6c50f"
                               :bg "#8924ff"
                               :ctermfg :Magenta
                               :ctermbg :Yellow
                               :bold true})))

  (augroup! :myColorscheme/OverrideDefault
    (au! :ColorSchemePre #(source-config-files! $.match :source))
    (au! :ColorScheme #(source-config-files! $.match :post))
    (au! :ColorScheme highlight-common!)))

;; Note: `pcall` to debug without package manager.

(pcall vim.cmd.colorscheme default-theme)
