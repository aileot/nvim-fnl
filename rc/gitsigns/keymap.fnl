;; TOML: git.toml
;; Repo: lewis6991/gitsigns.nvim

(import-macros {: printf
                : num?
                : echo!
                : augroup!
                : au!
                : nmap!
                : range-map!
                : textobj-map!
                : <Cmd>} :my.macros)

(local {: del-augroup! : Operator} (require :my.utils))

(fn preview-hunk-or-blame []
  (vim.schedule #(do
                   (vim.cmd "Gitsigns preview_hunk")
                   (let [{: is_open} (require :gitsigns.popup)
                         msg (if (is_open :hunk) "[gitsigns] Preview hunk"
                                 (do
                                   (vim.cmd "Gitsigns blame_line full=true ignore_whitespace=true")
                                   "[gitsigns] Show blame"))]
                     (echo! msg)))))

(nmap! :<Space>gm [:desc "Preview hunk or blame"] `preview-hunk-or-blame)
(do
  (var ?id nil)
  (nmap! :<Space>og [:desc "[gitsigns] Toggle hunk/blame popup"]
         #(set ?id
               (if (num? ?id)
                   (do
                     (pcall vim.api.nvim_del_autocmd ?id)
                     (echo! "[gitsigns] Disable popup"))
                   (do
                     (preview-hunk-or-blame)
                     (au! nil [:InsertEnter :TextChanged] [:once]
                          #(pcall vim.api.nvim_del_autocmd ?id))
                     (au! nil :CursorMoved `preview-hunk-or-blame))))))

(nmap! :<Space>oD [:desc "[gitsigns] Toggle word-diff"]
       #(let [gitsigns (require :gitsigns)
              enabled? (gitsigns.toggle_word_diff)
              msg (printf "[gitsigns] word-diff %s"
                          (if enabled? :enabled :disabled))]
          (gitsigns.toggle_linehl enabled?)
          (when enabled?
            (let [id (augroup! :rcGitsignsAdd/ToggleWordDiff)]
              (au! id [:InsertEnter] [:once]
                   #(let [enabled? (gitsigns.toggle_word_diff)]
                      (gitsigns.toggle_linehl enabled?)
                      (pcall del-augroup! id)))))
          (echo! msg)))

(range-map! :U [:silent] ":Gitsigns reset_hunk<CR>")

(nmap! [:desc "Operator to reset hunk" :expr] :<BSlash>U
       #(Operator.new (fn [a]
                        (let [{: reset_hunk} (require :gitsigns)]
                          (reset_hunk [a.row1 a.row2])))))

(nmap! :<Space>gP (<Cmd> "up | Gitsigns stage_buffer"))
(nmap! :<Space>gw (<Cmd> "up | Gitsigns stage_buffer"))

(range-map! :<Space>gp [:desc "Stage hunks in range" :expr]
            #(Operator.new (fn [a]
                             (let [{: stage_hunk} (require :gitsigns)]
                               ;; Note: stage_hunk is repeatable by default
                               (vim.cmd.update)
                               (stage_hunk [a.row1 a.row2])))))

(textobj-map! :ic [:silent] ":Gitsigns select_hunk<CR>")
(textobj-map! :ac [:silent] ":Gitsigns select_hunk<CR>")
