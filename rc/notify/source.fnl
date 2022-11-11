;; TOML: appearance.toml
;; Repo: rcarriga/nvim-notify

(import-macros {: nnoremap! : <Cmd>} :my.macros)

(local notify (require :notify))

(notify.setup {;; Animation type
               :stages :fade})

(set vim.notify notify)

(let [(ok? telescope) (pcall require :telescope)]
  (when ok?
    (telescope.load_extension :notify)
    (nnoremap! [:desc "Show notification history"] :<Space>eM
               (<Cmd> "Telescope notify"))))
