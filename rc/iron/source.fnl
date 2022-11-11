;; TOML: shell.toml
;; Repo: hkupty/iron.nvim

(local iron (require :iron.core))

(iron.setup {:config {:scratch_repl true
                      :repl_open_cmd "bot 80 split"
                      :keymaps {:send_motion :<Space>sc
                                :visual_send :<Space>sc
                                :send_file :<Space>sf
                                :send_line :<Space>sl}}})
