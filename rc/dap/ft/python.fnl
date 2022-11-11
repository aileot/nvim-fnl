(local dap (require :dap))

;; cspell:word venv debugpy
(tset dap.configurations :python ;
      [{:type :python
        :request :launch
        :name "Python: Launch File"
        :program "${file}"
        :pythonPath #(let [venv-path vim.env.VIRTUAL_ENVIRONMENT]
                       (if venv-path
                           (.. venv-path :/bin/python)
                           :/usr/bin/python))}])

;; fnlfmt: skip
(tset dap.adapters :python ;
      {:type :executable
       :command :python
       :args [:-m :debugpy.adapter]})
