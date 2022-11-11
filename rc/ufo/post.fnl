;; TOML: fold.toml
;; Repo: kevinhwang91/nvim-ufo

(import-macros {: setglobal! : setlocal! : nnoremap! : if-not}
               :my.macros)

(local ufo (require :ufo))

(local foldtext (require :rc.ufo.foldtext))
(local {: contains? : large-file?} (require :my.utils))

(setglobal! :foldLevelStart 99)

(fn has-foldmarker? []
  (< 0 (vim.fn.search (vim.wo.foldmarker:match "^(%S+),") ;
                      :cnw)))

(fn provider_selector [bufnr _filetype buftype]
  (let [fde vim.wo.foldexpr
        fdm vim.wo.foldmethod
        ?provider ;
        (if (contains? [:prompt :terminal :quickfix] buftype)
            (setlocal! :foldEnable false)
            (or (= fdm :marker) (has-foldmarker?))
            (setlocal! :foldMethod :marker)
            (not= fde :0)
            (setlocal! :foldMethod :expr)
            ;; Otherwise
            (let [clients (vim.lsp.get_active_clients {: bufnr})
                  ;; TODO: Better implementation
                  lsp-provider? (accumulate [lsp-provider? false ;
                                             _ client ;
                                             (pairs clients) ;
                                             &until lsp-provider?]
                                  (?. client :config :capabilities
                                      :textDocument :foldingRange
                                      :lineFoldingOnly))]
              (if lsp-provider? :lsp
                  (and (= fdm :manual) (= fde "nvim_treesitter#foldexpr()")
                       (let [max-bytes (* 1024 500)]
                         (large-file? max-bytes bufnr)))
                  ;; Note: The performance of "treesitter" provider is the worst
                  ;; according to the plugin anthor kevinhwang91:
                  ;; https://github.com/kevinhwang91/nvim-ufo/issues/83#issuecomment-1259441067
                  :treesitter)))]
    (or ?provider :indent)))

(ufo.setup {:fold_virt_text_handler foldtext
            :open_fold_hl_timeout 400
            :enable_get_fold_virt_text true
            ;; Without `vim.schedule`, ufo sometimes misses local &foldexpr.
            :provider_selector #(vim.schedule provider_selector)})

(fn keep-cursor-height [func]
  (assert (= :function (type func)) (.. "expected function, got " (type func)))
  (let [(ok? among-HML) (pcall require :among_HML)]
    (if-not ok? (func) ;
            (among-HML.keep_cursor func))
    ok?))

(nnoremap! :zm #(keep-cursor-height ufo.closeFoldsWith))
(nnoremap! :zM #(keep-cursor-height ufo.closeAllFolds))
(nnoremap! :zr #(keep-cursor-height ufo.openFoldsExceptKinds))

(nnoremap! :zR #(keep-cursor-height ufo.openAllFolds))

(nnoremap! :zk ufo.goPreviousClosedFold)
(nnoremap! :zj ufo.goNextClosedFold)

(nnoremap! ["Jump to prev fold and open it"] :zK
           (fn []
             (ufo.goPreviousClosedFold)
             (vim.cmd.normal! :zv)
             (let [(ok? among-HML) (pcall require :among_HML)]
               (when ok?
                 (among-HML.scroll 0.15)))))

(nnoremap! ["Jump to next fold and open it"] :zJ
           (fn []
             (ufo.goNextClosedFold)
             (vim.cmd.normal! :zv)
             (let [(ok? among-HML) (pcall require :among_HML)]
               (when ok?
                 (among-HML.scroll 0.15)))))
