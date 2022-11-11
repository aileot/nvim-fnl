;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope.nvim

(import-macros {: augroup! : au! : feedkeys!} :my.macros)

(local telescope (require :telescope))
(local actions (require :telescope.actions))
(local action_layout (require :telescope.actions.layout))

(local {: open-at-once} (require :rc.telescope.actions))

(local normalize vim.fs.normalize)

(let [mappings {:i {:<C-c> actions.close
                    :<M-f> {1 :<C-g>U<S-Right> :type :command}
                    :<M-b> {1 :<C-g>U<S-Left> :type :command}
                    ;; :<M-d> {1 :<C-g>U<S-Del> :type :command}
                    :<C-p> actions.cycle_history_prev
                    :<C-n> actions.cycle_history_next
                    ;; :<C-g> actions.move_selection_better
                    ;; :<C-t> actions.move_selection_worse
                    :<M-p> actions.move_selection_previous
                    :<M-n> actions.move_selection_next
                    :<C-x> false
                    :<C-v> false
                    :<M-s> (partial open-at-once :horizontal)
                    :<M-v> (partial open-at-once :vertical)
                    :<M-t> (partial open-at-once :tab)
                    :<C-u> false
                    :<C-d> false
                    "<C-]>" action_layout.toggle_preview
                    :<M-Space> (fn []
                                 ;; Continue to Normal mapping prefix `<Space>`.
                                 ;; It makes it easier to switch to different
                                 ;; telescope source.
                                 (feedkeys! :<Esc><Space> :i))}
                :n {:<C-c> actions.close
                    :<Esc> actions.close
                    :<CR> (+ actions.select_default actions.center)
                    :<C-x> false
                    :<C-v> false
                    :<C-t> false
                    :o (partial open-at-once :horizontal)
                    :O (partial open-at-once :vertical)
                    :gO (partial open-at-once :tab)
                    :j actions.move_selection_next
                    :k actions.move_selection_previous
                    :<Up> false
                    :<Down> false
                    :<C-u> actions.preview_scrolling_up
                    :<C-d> actions.preview_scrolling_down
                    "<C-]>" action_layout.toggle_preview
                    :<M-Space> (fn []
                                 ;; Whether in Normal mode or in Insert mode.
                                 (feedkeys! :<Esc><Space> :i))}}
      defaults ;
      {: mappings
       :vimgrep_arguments [:rg
                           :--color=never
                           :--no-heading
                           :--with-filename
                           :--line-number
                           :--column
                           ;; Remove indentations
                           ;; :--trim
                           :--hidden
                           :--smart-case]
       ;; reset, row, follow
       :selection_strategy :reset
       :sorting_strategy :ascending
       ;; horizontal, vertical, flex
       :layout_strategy :vertical
       :layout_config {:horizontal {:width 0.92
                                    :height 0.96
                                    :prompt_position :top}
                       :vertical {;; Reverse preview position
                                  ;; :mirror true
                                  :preview_height 0.3
                                  :width 0.92
                                  :height 0.96
                                  :prompt_position :top}}
       :preview {:timeout 200 :check_mime_type false}
       :file_ignore_patterns ["%.chr$"
                              "%.dat$"
                              "%.ex5$"
                              "%.exe$"
                              "%.wnd$"
                              "/%.git/"
                              "^%.$"
                              :/node_modules/
                              :LICENSE$
                              (normalize :^$HOME$)]
       :path_display {;; Note: Truncate head of paths to fit in window.
                      ;; The number indicates the right padding width from the
                      ;; edge of window.
                      :truncate 1}
       :winblend 20
       :border []
       :borderchars ["─" "│" "─" "│" "╭" "╮" "╯" "╰"]
       :use_less true
       :use_env {:COLORTERM :truecolor}
       :color_devicons true}]
  (telescope.setup {: defaults}))

(augroup! :rcTelescopePost/WorkaroundNoFoldFoundInBufferFromTelescope
          (au! :Syntax "normal! zx"))
