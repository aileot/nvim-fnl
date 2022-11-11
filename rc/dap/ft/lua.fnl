;; TOML: debug.toml
;; Repo: jbyuki/one-small-step-for-vimkind

(local dap (require :dap))

(tset dap.configurations :lua ;
      [{:type :nvim-lua
        :request :attach
        :name "Attach to running Neovim instance"
        :host :127.0.0.1
        :port #(let [port (tonumber (vim.fn.input "Port: "))]
                 (assert port "Please input a port number")
                 port)}])

(tset dap.adapters :nvim-lua
      (fn [callback config]
        (callback {:type :server :host config.host :port config.port})))
