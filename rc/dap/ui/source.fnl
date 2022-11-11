;; TOML: debug.toml
;; Repo: rcarriga/nvim-dap-ui

(import-macros {: setlocal! : nnoremap! : augroup! : au! : str->keycodes}
               :my.macros)

(local dap (require :dap))
(local dapui (require :dapui))

(local local-mappings {})
(set local-mappings.widgets ;
     {:i dap.step_into
      :I dap.step_over
      :o dap.step_out
      :<C-o> dap.step_back
      :r dap.repl.open
      :c dap.continue
      ;; VSCode like
      :<F5> dap.continue
      :<S-F5> dap.terminate
      :<F6> dap.pause
      :<F10> dap.step_over
      :<F11> dap.step_into
      :<S-F11> dap.step_out})

(fn enable-local-mappings-to-widgets []
  (each [lhs rhs (pairs local-mappings.widgets)]
    (nnoremap! [:<buffer>] lhs rhs)))

(augroup! :rcDapUI/SetlocalMappingsOnLaunch
  (au! :FileType [:dapui_*] enable-local-mappings-to-widgets))

(dapui.setup {:mappings {:expand [:zo :zO]
                         ;;  Toggle showing any children of variable in "Scope".
                         :open [:o :<CR>]
                         :remove [:x :dd :D]
                         :edit [:e]
                         ;;  Only in [Watch Expressions].
                         :repl [:r]
                         :toggle :t
                         :close [:ZZ :ZQ :Zz :Zq]}
              :floating {;; @type '"single"'|'"double"'|'"rounded"'
                         :border :rounded
                         ;; @type number # Set ratio between 0 and 1.
                         :max_width nil
                         ;; @type number # Set ratio between 0 and 1.
                         :max_height nil
                         :mappings {:close [:ZZ :ZQ :Zz :Zq]}}})

;; `:h dap-extensions`:
;; - event_<event>: https://microsoft.github.io/debug-adapter-protocol/specification#Events
;; - <command> is for request responses:
;; https://microsoft.github.io/debug-adapter-protocol/specification#Requests

(tset dap.listeners ;
      ;; FIXME: it fails to listen the event.
      :after :event_initialized :dapui_config
      (fn []
        (vim.cmd ;; Copy current window to a new tab.
                 (str->keycodes "sp | silent normal! <C-w>T"))
        (dapui.open)
        ;; (setlocal! :keywordPrg ":lua require'dapui'.float_element()")))
        ;; Enable dap.ui.widgets.hover by `K` in dapui windows.
        (setlocal! :keywordPrg ":lua require'dap.ui.widgets'.hover()")))

(tset dap.listeners ;
      :before :event_terminated :dapui_config ;
      dapui.close)

(tset dap.listeners ;
      :before :event_exited :dapui_config ;
      dapui.close)

(tset dap.listeners ;
      :before :disconnect :dapui_config ;
      dapui.close)
