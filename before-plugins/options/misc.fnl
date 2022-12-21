(import-macros {: str->keycodes : g! : set!} :my.macros)

;; Disable default mappings defined in $VIMRUNTIME/ftplugin/*.vim and
;; $VIMRUNTIME/pack/dist/opt/**.vim
(g! :no_plugin_maps true)

;; Disable both <Leader> and <LocalLeader>.
;; Note: The values must be assigned in a keycode:
;; `let g:mapleader = '<Ignore>'` will set `<` to `<leader>`.)
(g! :mapleader (str->keycodes :<Ignore>))
(g! :maplocalleader (str->keycodes :<Ignore>))

(set! :mouse :ar)
(set! :secure true)

;; Note: Larger &modelines could consider unexpected lines modelines, typically in
;; snippet files.
(set! :modelines 1)

;; Update swap file by &updatetime. Keep it shorter for CursorHold/CursorHoldI
(set! :updateTime 300)
;; Key sequence finishes after &timeoutlen in milli second.
(set! :timeoutLen 1000)

;; ;; Some plugins might not work with &autochdir on
;; (set! :autochdir true)

(set! :fixEndOfLine false)

;; It only affects quickfix commands like `:cc`, `:copen`, and buffer-splitting
;; commands like `:sb`; it doesn't affect `:buffer`, `:vsplit`, and so on.
(set! :switchBuf [:useopen])

;; Note: Enable either `hidden` or `autowriteall` for seamless editing with fzf
;; or similar plugins.
(set! :hidden true)
;; (set! :autoWriteAll true)

(set! :cpOptions+ :E)

;; Save & Restore ///1
(set! :shada [;; `'`: Save jumplist and changelist
              "'500"
              ;; `<`: Max number of lines for register
              :<50
              ;;   `h`: Disable 'hlsearch' after loading the shada
              :h
              :s10])

(set! :viewOptions [:folds :cursor])

(set! :sessionOptions [:blank
                       :help
                       :resize
                       :tabpages
                       :winpos
                       :winsize
                       :terminal])

;; Grep ///1
;; Ref: https://ktrysmt.github.io/blog/finish-work-early-with-cli-made-by-rust/
(when (= 1 (vim.fn.executable :rg))
  (set! :grepPrg "rg --vimgrep --no-heading"))

(set! :grepFormat "%f:%l:%c:%m,%f:%l:%m")

;; Error ///1
(set! :bellOff :all)
(set! :errorBells true)
(set! :visualBell true)

;; Fold ///1
(set! :foldEnable false)
;; Close fold when cursor moves out of foldable line if &foldclose is "all".
;; (set! :foldMethod :indent)
;; (set! :foldMarker "///,//<")
;; ;; Note: &foldlevel instead is local to window.
;; (set! :foldLevelStart 1)
(set! :foldNestMax 5)
;; (set! :foldClose "all")

(set! :foldOpen ;
      [:hor :insert :mark :percent :quickfix :search :tag :undo])

;; (set! :imDisable true)
(set! :imInsert 0)
(set! :imSearch 0)
(set! :imCmdline true)

(set! :fileFormats [:unix :dos :mac])

(let [in-wsl? vim.env.WSL_DISTRO_NAME]
  (when in-wsl?
    (g! :clipboard {:name "WSL Clipboard"
                    :copy {:+ [:clip.exe] :* [:clip.exe]}
                    :paste {:+ [:nvim_paste_on_wsl] :* [:nvim_paste_on_wsl]}
                    :cache_enabled true})))

;; Diagnostic ///1
(set! :spellLang "en_us,cjk")
(set! :spellOptions "camel")

(vim.diagnostic.config {:virtual_text {:source :if_many}
                        :float {:wrap false
                                ;; header false
                                :source :always}})

;; :format (fn [diag]
;;           (let [SEVERITY vim.diagnostic.severity
;;                 sev diag.severity
;;                 prefix (match sev
;;                          SEVERITY.ERROR :E
;;                          SEVERITY.WARN :W
;;                          SEVERITY.INFO :I
;;                          SEVERITY.HINT :H)]
;;             (if prefix
;;                 (string.format "%s #%s" diag.message
;;                                prefix)
;;                 diag.message)))})
