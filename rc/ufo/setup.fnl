;; TOML: fold.toml
;; Repo: kevinhwang91/nvim-ufo

(import-macros {: set! : setlocal! : nmap!} :my.macros)

(local ufo (require :ufo))

(local foldtext (require :rc.ufo.foldtext))
(local {: contains? : large-file?} (require :my.utils))

(set! :foldLevel 99)
(set! :foldLevelStart 99)

(fn has-foldmarker? []
  (< 0 (vim.fn.search (vim.wo.foldmarker:match "^(%S+),") ;
                      :cnw)))

(fn provider_selector [bufnr _filetype buftype]
  (let [fde vim.wo.foldexpr
        fdm vim.wo.foldmethod]
    (if (contains? [:prompt :terminal :quickfix] buftype)
        (setlocal! :foldEnable false)
        (or (= fdm :marker) (has-foldmarker?))
        (setlocal! :foldMethod :marker)
        (not= fde :0)
        (setlocal! :foldMethod :expr)
        ;; Otherwise
        (match-try (vim.lsp.get_active_clients {: bufnr})
          clients
          (accumulate [fold-capable? false ;
                       _ client (pairs clients) ;
                       &until fold-capable?]
            (?. client :config :capabilities :textDocument :foldingRange
                :lineFoldingOnly))
          (catch true :lsp ;
                 _ (if (and (= fdm :manual) (= fde "nvim_treesitter#foldexpr()")
                           (let [max-bytes (* 1024 500)]
                             (large-file? max-bytes bufnr)))
                      ;; Note: The performance of "treesitter" provider is the
                      ;; worst according to the plugin anthor kevinhwang91:
                      ;; https://github.com/kevinhwang91/nvim-ufo/issues/83#issuecomment-1259441067
                      :treesitter
                      :indent))))))

(ufo.setup {:fold_virt_text_handler foldtext
            :open_fold_hl_timeout 400
            :enable_get_fold_virt_text true
            ;; Without `vim.schedule`, ufo sometimes misses local &foldexpr.
            :provider_selector #(vim.schedule provider_selector)})

(fn keep-cursor-height [func]
  (assert (= :function (type func)) (.. "expected function, got " (type func)))
  (match (pcall require :among_HML)
    (true among-HML) (among-HML.keep_cursor func)
    _ (func)))

(nmap! :zm #(keep-cursor-height ufo.closeFoldsWith))
(nmap! :zM #(keep-cursor-height ufo.closeAllFolds))
(nmap! :zr #(keep-cursor-height ufo.openFoldsExceptKinds))

(nmap! :zR #(keep-cursor-height ufo.openAllFolds))

(nmap! :zk ufo.goPreviousClosedFold)
(nmap! :zj ufo.goNextClosedFold)

(nmap! [:desc "Jump to prev fold and open it"] :zK
       (fn []
         (ufo.goPreviousClosedFold)
         (vim.cmd.normal! :zv)
         (match (pcall require :among_HML)
           (true among-HML) (among-HML.scroll 0.15))))

(nmap! [:desc "Jump to next fold and open it"] :zJ
       (fn []
         (ufo.goNextClosedFold)
         (vim.cmd.normal! :zv)
         (match (pcall require :among_HML)
           (true among-HML) (among-HML.scroll 0.15))))
