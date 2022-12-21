(import-macros {: feedkeys!} :my.macros)

(local actions (require :telescope.actions))
(local action_layout (require :telescope.actions.layout))
(local {: open-at-once} (require :rc.telescope.actions))

(macro set-keys [str]
  `{1 ,str :type :command})

{:i {:<C-c> actions.close
     :<M-f> (set-keys :<C-g>U<S-Right>)
     :<M-b> (set-keys :<C-g>U<S-Left>)
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
     :<M-q> actions.smart_add_to_qflist
     :<M-S-q> actions.smart_send_to_qflist
     ;; Mnemonic: Location list is Window-local.
     :<M-w> actions.smart_add_to_loclist
     :<M-S-w> actions.smart_send_to_loclist
     :<C-u> false
     :<C-d> false
     "<C-]>" action_layout.toggle_preview
     :<M-Space> (fn []
                  ;; Continue to Normal mapping prefix `<Space>`.
                  ;; It makes it easier to switch to different
                  ;; telescope source.
                  (feedkeys! :<Esc><Space> :mi))}
 :n {:<C-c> actions.close
     :<Esc> actions.close
     :<CR> (+ actions.select_default actions.center)
     :<C-x> false
     :<C-v> false
     :<C-t> false
     :o (partial open-at-once :horizontal)
     :O (partial open-at-once :vertical)
     :gO (partial open-at-once :tab)
     :<M-q> actions.smart_add_to_qflist
     :<M-S-q> actions.smart_send_to_qflist
     ;; Mnemonic: Location list is Window-local.
     :<M-w> actions.smart_add_to_loclist
     :<M-S-w> actions.smart_send_to_loclist
     :j actions.move_selection_next
     :k actions.move_selection_previous
     :<Up> false
     :<Down> false
     :<C-u> actions.preview_scrolling_up
     :<C-d> actions.preview_scrolling_down
     "<C-]>" action_layout.toggle_preview
     :<M-Space> (fn []
                  ;; Whether in Normal mode or in Insert mode.
                  (feedkeys! :<Esc><Space> :mi))}}
