(import-macros {: str->keycodes : g! : setglobal!} :my.macros)

;; Disable default mappings defined in $VIMRUNTIME/ftplugin/*.vim and
;; $VIMRUNTIME/pack/dist/opt/**.vim
(g! :no_plugin_maps true)

;; Disable both <Leader> and <LocalLeader>.
;; Note: The values must be assigned in a keycode:
;; `let g:mapleader = '<Ignore>'` will set `<` to `<leader>`.)
(g! :mapleader (str->keycodes :<Ignore>))
(g! :maplocalleader (str->keycodes :<Ignore>))

(setglobal! :packPath "")

(setglobal! :mouse :ar)
(setglobal! :secure true)

;; Note: Larger &modelines could consider unexpected lines modelines, typically in
;; snippet files.
(setglobal! :modelines 1)

;; Update swap file by &updatetime. Keep it shorter for CursorHold/CursorHoldI
(setglobal! :updateTime 300)
;; Key sequence finishes after &timeoutlen in milli second.
(setglobal! :timeoutLen 1000)

;; ;; Some plugins might not work with &autochdir on
;; (setglobal! :autochdir true)

(setglobal! :fixEndOfLine false)

;; It only affects quickfix commands like `:cc`, `:copen`, and buffer-splitting
;; commands like `:sb`; it doesn't affect `:buffer`, `:vsplit`, and so on.
(setglobal! :switchBuf [:useopen])

;; Note: Enable either `hidden` or `autowriteall` for seamless editing with fzf
;; or similar plugins.
(setglobal! :hidden true)
;; (setglobal! :autoWriteAll true)

;; Save & Restore ///1
(setglobal! :shada [;; `'`: Save jumplist and changelist
                    "'1000"
                    ;; `<`: Max number of lines for register
                    :<50
                    ;;   `h`: Disable 'hlsearch' after loading the shada
                    :h
                    :s10])

(setglobal! :viewOptions [:folds :cursor])

(setglobal! :sessionOptions [:blank
                             :help
                             :resize
                             :tabpages
                             :winpos
                             :winsize
                             :terminal])

;; Grep ///1
;; Ref: https://ktrysmt.github.io/blog/finish-work-early-with-cli-made-by-rust/
(when (= 1 (vim.fn.executable :rg))
  (setglobal! :grepPrg "rg --vimgrep --no-heading"))

(setglobal! :grepFormat "%f:%l:%c:%m,%f:%l:%m")

;; Error ///1
(setglobal! :bellOff :all)
(setglobal! :errorBells true)
(setglobal! :visualBell true)

;; Fold ///1
(setglobal! :foldEnable false)
;; Close fold when cursor moves out of foldable line if &foldclose is "all".
;; (setglobal! :foldMethod :indent)
;; (setglobal! :foldMarker "///,//<")
;; ;; Note: &foldlevel instead is local to window.
;; (setglobal! :foldLevelStart 1)
(setglobal! :foldNestMax 5)
;; (setglobal! :foldClose "all")
(setglobal! :foldOpen [:hor
                       :insert
                       :mark
                       :percent
                       :quickfix
                       :search
                       :tag
                       :undo])

;; (setglobal! :imDisable true)
(setglobal! :imInsert 0)
(setglobal! :imSearch 0)
(setglobal! :imCmdline true)

(setglobal! :fileFormats [:unix :dos :mac])

(let [in-wsl? vim.env.WSL_DISTRO_NAME]
  (when in-wsl?
    (g! :clipboard {:name "WSL Clipboard"
                          :copy {:+ [:clip.exe] :* [:clip.exe]}
                          :paste {:+ [:nvim_paste_on_wsl]
                                  :* [:nvim_paste_on_wsl]}
                          :cache_enabled true})))

;; Diagnostic ///1
(setglobal! :spellLang "en_us,cjk")
(setglobal! :spellOptions "camel")

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
