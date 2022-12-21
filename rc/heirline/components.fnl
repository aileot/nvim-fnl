;; TOML: appearance.toml
;; Repo: rebelot/heirline.nvim

(import-macros {: when-not : ++ : printf : augroup! : au! : expand} :my.macros)

(local {: get_icon_color} (require :nvim-web-devicons))

(local {: contains? : git} (require :my.utils))

(local icons (require :my.presets.icons))
(local {: color} (require :my.presets.colors))
(local {: mode-colors} (require :my.presets.vi-mode))

(local mode (require :my.components.mode))
(local {: scrollbar} (require :my.components.widget))
(local {: dap : lsp : vim} (require :my.components.status))

(local utils (require :heirline.utils))
(local {: window-width : gather} (require :rc.heirline.utils))

(local components {})

(set components.default ;
     {:hl {:fg color.fg :bg color.bg}})

(augroup! :rcHeirlineComponents)

(local max-textwidth 80)

;; Utils ///1
(set components.space {:provider " "})
(set components.align {:provider "%="})
(set components.separator-to-left {:provider icons.to-left.rounded-line})
(set components.separator-to-right {:provider icons.to-right.rounded-line})
;; Note: `update` affects their children
(set components.update-win-width
     {:init (fn [self]
              (tset self :win-width (window-width)))})

(set components.update-path
     {:init (fn [self]
              (set self.path (vim.api.nvim_buf_get_name 0)))})

;; Mode ///1
(set components.mode ;
     {;;:update [:ModeChanged :BufEnter]
      :hl (fn [self]
            (let [mode-initial (self.mode:sub 1 1)]
              {:fg (. mode-colors mode-initial) :bg color.bg :bold true}))
      :init (fn [self]
              ;; Used in provider & hl functions
              (tset self :mode (vim.fn.mode 1))
              ;; Note: This autocmd to update statusline/tabline on entering
              ;; Operator-pending mode incredibly consumes CPU.
              (comment (when-not self.loaded?
                         (au! :rcHeirlineComponents ;
                              :ModeChanged ["*:*o"]
                              ["Let heirline update mode component on Operator-pending mode"]
                              :redrawstatus)
                         (tset self :loaded? true))))
      :provider (fn [self]
                  (mode.mix self.mode))})

;; Git ///1
(set components.git-status
     (let [theme {:added color.green :changed color.yellow :removed color.red}
           git-branch-name ;
           {:hl (fn [self]
                  self.hl-branch)
            ;; :update [:BufWinEnter :BufEnter :FileChangedShellPost]
            :init (fn [self]
                    (let [bufnr (if (contains? [:gitcommit] vim.bo.filetype)
                                    ;; Inherit branch name of the last window.
                                    (-> (vim.fn.winnr "#") (vim.fn.winbufnr))
                                    0)]
                      ;; (vim.wait 200 #(?. vim.b bufnr :gitsigns_status_dict))
                      (let [?status (. vim.b bufnr :gitsigns_status_dict)
                            ?head (or (?. ?status :head) "")
                            fg (if (= "" ?head) color.red (?head:match "/")
                                   color.yellow
                                   (contains? [:main :master] ?head)
                                   color.violet color.green)
                            bg color.bg]
                        (tset self :status
                              (when ?status
                                (collect [k v (pairs ?status)]
                                  (if (= v 0) (values k nil) (values k v)))))
                        (tset self :hl-branch {: fg : bg :bold true}))))
            :provider (fn [self]
                        (let [prefix ""
                              ?head (?. self.status :head)]
                          (.. " %-6(" prefix " " (or ?head :none) "%) ")))}
           git-diff-count-added {:provider (fn [self]
                                             (let [?count-added (?. self
                                                                    :status
                                                                    :added)
                                                   end-row (vim.fn.line "$")]
                                               (if (= ?count-added end-row)
                                                   " NEW"
                                                   (when ?count-added
                                                     (.. " " ?count-added " ")))))
                                 :hl {:bg theme.added}}
           git-diff-count-changed {:provider (fn [self]
                                               (when (?. self :status :changed)
                                                 (.. " " self.status.changed
                                                     " ")))
                                   :hl {:bg theme.changed}}
           git-diff-count-removed {:provider (fn [self]
                                               (when (?. self :status :removed)
                                                 (.. " " self.status.removed
                                                     " ")))
                                   :hl {:bg theme.removed}}
           git-diff-count-init {:hl {:fg color.bg}
                                :update [:BufWinEnter
                                         :BufEnter
                                         :FileChangedShellPost
                                         :BufWritePost]}
           git-diff-counts (gather git-diff-count-init ;
                                   {:provider icons.to-right.rounded-solid
                                    :hl (fn [self]
                                          {:bg theme.added
                                           :fg (or (?. self :hl-branch :bg)
                                                   color.fg)})}
                                   git-diff-count-added
                                   {:provider icons.to-right.rounded-solid
                                    :hl {:fg theme.added :bg theme.changed}}
                                   git-diff-count-changed
                                   {:provider icons.to-right.rounded-solid
                                    :hl {:fg theme.changed :bg theme.removed}}
                                   git-diff-count-removed
                                   {:provider icons.to-right.rounded-solid
                                    :hl {:fg theme.removed :bg color.bg}})
           git-stash-count {:update [:BufReadPost
                                     :CmdLineLeave
                                     :CmdWinLeave
                                     :ShellCmdPost
                                     :TermResponse
                                     :FileChangedShellPost]
                            :hl {:fg color.bg :bg color.lightblue}
                            :provider (fn [self]
                                        ;; WIP
                                        (when (?. self :status :root)
                                          (let [stashes ;
                                                (vim.fn.systemlist [:git
                                                                    :-C
                                                                    self.status.root
                                                                    :stash
                                                                    :list])]
                                            [{:provider icons.to-left.rounded-solid
                                              :hl {:fg color.lightblue}}
                                             {:provider " "}
                                             (length stashes)
                                             {:provider " "}
                                             {:provider icons.to-right.rounded-solid
                                              :hl {:fg color.lightblue}}])))}]
       (gather git-branch-name git-diff-counts)))

;; LSP ///1
(set components.ls-names {:update [:LspAttach
                                   :LspDetach
                                   :VimResized
                                   :WinClosed
                                   :WinNew]
                          :provider lsp.names})

;; Cursor ///1
(set components.ruler {:update [:CursorMoved :VimResized :WinClosed :WinNew]
                       :provider ;; %l: cursor line number
                       ;; %c: cursor column number
                       ;; %L: number of lines in the buffer
                       ;; %P: percentage of displayed window
                       "%7(%l/%3L%):%2c"})

(set components.percentage {:update [:BufWinEnter :BufEnter :WinScrolled]
                            :provider "%P"})

(set components.scrollbar {:hl {:fg color.lightblue :bg color.bg}
                           :update [:CursorMoved]
                           :provider scrollbar})

(set components.nesting
     (let [type-hl-group {:File :Directory
                          :Module :Include
                          :Namespace "@namespace"
                          :Package :Include
                          :Class :Struct
                          :Method :Method
                          :Property "@property"
                          :Field "@field"
                          :Constructor "@constructor"
                          :Enum "@field"
                          :Interface :Type
                          :Function :Function
                          :Variable "@variable"
                          :Constant :Constant
                          :String :String
                          :Number :Number
                          :Boolean :Boolean
                          :Array "@field"
                          :Object :Type
                          :Key "@keyword"
                          :Null :Comment
                          :EnumMember "@field"
                          :Struct :Struct
                          :Event :Keyword
                          :Operator :Operator
                          :TypeParameter :Type}]
       {:update [:BufEnter :CursorMoved]
        :condition (fn [self]
                     (match (pcall require :nvim-navic)
                       (true navic) (do
                                      (tset self :navigator navic)
                                      (navic.is_available))
                       _ (match (pcall require :nvim-gps)
                           (true gps) (do
                                        (tset self :navigator gps)
                                        (gps.is_available)))))
        :init (fn [self]
                (let [navigator self.navigator
                      children []
                      sep "  "
                      sep-component {:provider sep}
                      ?data (navigator.get_data)]
                  (when ?data
                    (each [i d (ipairs ?data)]
                      (let [child [{:provider d.icon
                                    :hl (?. type-hl-group d.type)}
                                   {:provider (or d.name d.text)}]]
                        (when (< 0 i (length ?data))
                          (table.insert child sep-component))
                        (table.insert children child)))
                    ;; Overwrite the previous one
                    (tset self 1 (self:new children 1)))))}))

;; DAP ///1
(set components.dap-status
     {:hl {:fg (. (utils.get_highlight :Debug) :fg)}
      :condition (fn [self]
                   (let [(ok? dap) (pcall require :dap)]
                     (when ok?
                       (let [?session (dap.session)]
                         (tset self :dap dap)
                         (when (?. ?session :config)
                           (let [filename self.path
                                 program (?. ?session :config :program)]
                             (= filename program)))))))
      :provider (fn [self]
                  (.. " " (self.dap.status)))})

;; Diagnostics ///1
(set components.diagnostics
     (let [theme {:error color.red
                  :warn color.yellow
                  :hint color.green
                  :info color.blue}
           {: count-error : count-warn : count-info : count-hint} ;
           (require :my.components.diagnostics)
           section {:init (fn [self]
                            (tset self :error (count-error))
                            (tset self :warn (count-warn))
                            (tset self :info (count-info))
                            (tset self :hint (count-hint)))
                    :update [:DiagnosticChanged]
                    :hl {:fg color.bg}}
           error-count {:provider (fn [self]
                                    (if (= 0 self.error) "" (.. self.error " ")))
                        :hl {:bg theme.error}}
           warn-count {:provider (fn [self]
                                   (if (= 0 self.warn) "" (.. self.warn " ")))
                       :hl {:bg theme.warn}}
           info-count {:provider (fn [self]
                                   (if (= 0 self.info) "" (.. self.info " ")))
                       :hl {:bg theme.info}}
           hint-count {:provider (fn [self]
                                   (if (= 0 self.hint) "" (.. self.hint " ")))
                       :hl {:bg theme.hint}}
           diagnostics-counts [{:provider icons.to-left.rounded-solid
                                :hl {:fg theme.error}}
                               error-count
                               {:provider icons.to-left.rounded-solid
                                :hl {:fg theme.warn :bg theme.error}}
                               warn-count
                               {:provider icons.to-left.rounded-solid
                                :hl {:fg theme.info :bg theme.warn}}
                               info-count
                               {:provider icons.to-left.rounded-solid
                                :hl {:fg theme.hint :bg theme.info}}
                               hint-count
                               {:provider icons.to-left.rounded-solid
                                :hl {:fg theme.bg :bg theme.hint}}]]
       (gather section diagnostics-counts)))

;; Buffer ///1
(set components.root-name
     {:update [:BufWinEnter :BufEnter]
      :provider (fn []
                  (let [?root (?. vim.b.gitsigns_status_dict :root)
                        filetype vim.bo.filetype]
                    (if (contains? [:help :man] filetype) filetype ;
                        ?root (vim.fn.fnamemodify ?root ":t")
                        (let [path (expand "%:p:~")
                              ?protocol (path:match "^(%S-)://")]
                          (if ?protocol ?protocol ;
                              (path:match "^~/") :$HOME
                              path)))))})

(set components.path-after-root ;
     {:update [:BufWinEnter :BufEnter :VimResized :WinClosed :WinNew]
      :provider (fn [self]
                  (let [?root (?. vim.b.gitsigns_status_dict :root)
                        win-width self.win-width
                        full-path self.path
                        target-path (full-path:gsub "^%S-://(%S+)" "%1")
                        path (if (< (length target-path) max-textwidth
                                    (* win-width (/ 3 4)))
                                 (if ?root
                                     ;; Note: `gsub` instead fails to truncate
                                     ;; when `?root` includes any Lua pattern letter.
                                     (full-path:sub (+ 2 (length ?root)))
                                     (-> (vim.fn.fnamemodify target-path ":~")
                                         (: :gsub "^~/" "")))
                                 (let [dir (vim.fn.fnamemodify target-path
                                                               ":h:t")
                                       filename (vim.fn.fnamemodify target-path
                                                                    ":t")
                                       dir-fname ;
                                       (.. dir "/" filename)
                                       truncated-path ;
                                       (if (< (length dir-fname)
                                              (* win-width (/ 1 4)))
                                           dir-fname
                                           filename)]
                                   (.. "/" truncated-path)))]
                    (.. "%8(" path "%)")))})

(set components.path-from-root
     [{:provider (fn [self]
                   (let [max-width (math.floor (* self.win-width (/ 3 4)))]
                     (.. "%1." max-width "(")))}
      components.root-name
      {:provider "://"}
      components.path-after-root
      {:provider "%)"}])

(set components.modified?
     (let [icon ""]
       {:update [:BufModifiedSet :FileChangedShellPost]
        :hl {:fg color.red}
        :provider #(when vim.bo.modified
                     (.. " " icon))}))

(set components.file-size
     {:update [:BufWinEnter :BufEnter :BufWritePost]
      :provider (let [suffixes [:b :k :M :g :T :P :E]]
                  (fn [self]
                    ;; Ref: https://github.com/feline-nvim/feline.nvim/blob/5d6a054c476f2c2e3de72022d8f59764e53946ee/lua/feline/providers/file.lua#L149
                    (let [byte-size (vim.fn.getfsize self.path)
                          max-idx (length suffixes)]
                      (when (< 0 byte-size)
                        (var idx 1)
                        (var size byte-size)
                        (while (and (<= idx max-idx) (< 1024 size))
                          (set size (/ size 1024))
                          (++ idx))
                        (let [format (if (= 1 idx) "%g%s" "%.2f%s")]
                          (printf format size (. suffixes idx)))))))})

(set components.file-type
     {:update [:FileType :VimResized :WinClosed :WinNew]
      :provider #(if (= "" vim.bo.filetype) "[none]" vim.bo.filetype)})

(set components.file-icon
     {:init (fn [self]
              (let [path (expand "%:p:~")
                    extension (expand path ":e")
                    (icon icon-color) (get_icon_color path extension
                                                      {:default true})]
                (tset self :icon icon)
                (tset self :icon-color icon-color))
              :hl
              (fn [self]
                {:fg self.icon-color})
              :provider
              (fn [self]
                (when self.icon
                  (.. self.icon " "))))})

(set components.file-path ;
     {:update [:BufEnter :VimResized :WinNew :WinClosed]
      :provider #(let [path (expand "%:p:~")
                       editor-width vim.go.columns
                       min-width 10
                       max-width (math.floor (* editor-width (/ 3 4)))
                       path (if (= "" path) "[No Name]"
                                (if (< max-width (length path))
                                    (vim.fn.pathshorten path)
                                    path))]
                   (.. "%-" min-width "." max-width "(" path "%)"))})

;; Fold ///1
(set components.foldmethod
     {:update [:BufWinEnter :OptionSet :VimResized :WinNew :WinClosed]
      :provider #(let [fde vim.wo.foldexpr]
                   (if (= fde :0)
                       (.. :fdm= vim.wo.foldmethod)
                       (-> (.. :fde= fde)
                           (: :gsub "v:lnum" "")
                           (: :gsub "[#_]?[fF]old[eE]xpr" ""))))})

;; Tabline ///1
(set components.tabpages
     (let [tabpage {:hl (fn [self]
                          (if self.is_active {:fg color.yellow :bold true}
                              {:fg color.fg}))
                    :condition #(< 1 (length (vim.api.nvim_list_tabpages)))
                    :provider (fn [self]
                                ;; Note: `utils.make_tablist` provides `self.tabnr`
                                (.. "%" self.tabnr "T " self.tabnr " %T"))}]
       (utils.make_tablist tabpage)))

;; Misc ///1
(set components.last-command ;
     {:provider vim.last-command})

;; Export ///1
components
