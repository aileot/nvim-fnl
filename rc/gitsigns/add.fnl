;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(import-macros {: when-not
                : nnoremap!
                : xnoremap!
                : noremap-textobj!
                : noremap-operator!
                : <Cmd>} :my.macros)

(local {: Operator} (require :my.utils))

(nnoremap! :<Space>gm [:desc "Preview hunk or blame"]
           #(let [wins (vim.api.nvim_list_wins)
                  gitsigns (require :gitsigns)]
              (gitsigns.preview_hunk)
              (let [preview-appears? (= wins (vim.api.nvim_list_wins))]
                (when-not preview-appears?
                  (gitsigns.blame_line {:full true :ignore_whitespace true})))))

(nnoremap! :U (<Cmd> "Gitsigns reset_hunk"))
(xnoremap! :U (.. (<Cmd> "*Gitsigns reset_hunk") :<Esc>))

(nnoremap! [:desc "Operator to reset hunk" :<callback>] :<BSlash>U
           (Operator.new (fn [start end]
                           (-> (require :gitsigns)
                               (. :reset_hunk start end)))))

(nnoremap! :<Space>gP (<Cmd> "up | Gitsigns stage_buffer"))
(nnoremap! :<Space>gw (<Cmd> "up | Gitsigns stage_buffer"))

(noremap-operator! :<Space>gp [:desc "Stage hunks in range" :<callback>]
                   (Operator.new (fn [start end]
                                   ;; Note: stage_hunk is repeatable by default
                                   (vim.cmd.update)
                                   (let [[row1] start
                                         [row2] end]
                                     ((. (require :gitsigns) :stage_hunk) [row1
                                                                           row2])))))

(noremap-textobj! :ic (<Cmd> "Gitsigns select_hunk"))
(noremap-textobj! :ac (<Cmd> "Gitsigns select_hunk"))
