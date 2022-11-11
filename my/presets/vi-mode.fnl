(local {: color} (require :my.presets.colors))

(local mode-colors {:n color.green
                    :i color.violet
                    :c color.orange
                    ;; Terminal mode
                    :t color.blue
                    ;; Replace mode
                    :R color.red
                    ;; Prompt mode
                    :r color.lightblue
                    ;; Visual mode
                    :v color.yellow
                    :V color.yellow
                    "\022" color.yellow
                    ;; Select mode
                    :s color.cyan
                    :S color.cyan
                    "\019" color.cyan
                    ;; Shell/External
                    :! color.magenta})

(local mode-names {:n :NORMAL
                   :no :OPERATOR
                   :nov :OPERATOR
                   :noV :OPERATOR
                   "no\022" :OPERATOR
                   :niI :INSERT
                   :niR :REPLACE
                   :niV :REPLACE
                   :nt :NORMAL
                   :ntT :NORMAL
                   :v :VISUAL
                   :vs :S-ONCE
                   :V :V-LINE
                   :Vs :S-ONCE
                   "\022" :V-BLOCK
                   "\022s" :S-ONCE
                   :s :SELECT
                   :S :S-LINE
                   "\019" :S-BLOCK
                   :i :INSERT
                   :ic :COMPLETE
                   :ix :COMPLETE
                   :R :REPLACE
                   :Rc :COMPLETE
                   :Rx :COMPLETE
                   :Rv :REPLACE
                   :Rvc :COMPLETE
                   :Rvx :COMPLETE
                   :c :COMMAND
                   :cv :Ex
                   :r "..."
                   :rm :More
                   :r? :CONFIRM
                   :! :SHELL
                   :t :TERM})

{: mode-names : mode-colors}
