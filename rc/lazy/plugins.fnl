(import-macros {: g! : nmap! : <Cmd> : expand : evaluate} :my.macros)

(import-macros {: preloaded
                : on-startup
                : on-demand
                : colorscheme
                : dep
                : trigger-map!} :rc.lazy.macros)

;; cspell:ignoreRegExp :[a-zA-Z0-9-_]+/
(local plenary :nvim-lua/plenary.nvim)
(local web-devicons :kyazdani42/nvim-web-devicons)
(local denops :vim-denops/denops.vim)

[(preloaded :folke/lazy.nvim)
 ;;; Fennel compiler
 (preloaded :rktjmp/hotpot.nvim {:init #(require :rc.hotpot.add)})
 ;;; Fennel Macro
 (preloaded :aileot/nvim-laurel)
 (on-demand :embear/vim-localvimrc
            {:init #(do
                      (g! :localvimrc_ask 1) ; 1: Ask before sourcing any local vimrcs.
                      (g! :localvimrc_persistent 1) ; 1: Save the decisions with upper case.
                      (g! :localvimrc_persistence_file
                          (expand :$XDG_CACHE_HOME/localvimrc))
                      (g! :localvimrc_python2_enable false)
                      (g! :localvimrc_name [:.local.vimrc :.nvimrc]))})
 (on-startup :wakatime/vim-wakatime)
 (on-startup :samjwill/nvim-unception
             {:init #(do
                       (g! :unception_open_buffer_in_new_tab true)
                       (g! :unception_enable_flavor_text false))})
 ;;; Parinfer ///1
 ;; (on-demand :liquidz/dps-parinfer {:deps denops})
 (on-demand :eraserhd/parinfer-rust {:build "cargo build --release"})
 ;; (on-demand :harrygallagher4/nvim-parinfer-rust
 ;;            {:deps (dep :eraserhd/parinfer-rust {:rtp :target/release})
 ;;; Performance ///1
 (on-demand :dstein64/vim-startuptime {:cmd :StartupTime})
 (on-demand :antoinemadec/FixCursorHold.nvim
            {:config #(require :rc.FixCursorHold.source)})
 ;; A workaround for performance issue to sync the unnamed register to `+`
 ;; register via `set clipboard=unnamedplus`.
 ;; https://github.com/neovim/neovim/issues/11804
 ;; (on-demand :EtiamNullam/deferred-clipboard.nvim
 ;;            {:config #(lua "require'deferred-clipboard'.setup({ lazy = true })")})
 ;;; Appearance ///1
 ;; Highlight by Lua pattern.
 (on-demand :folke/paint.nvim)
 ;; ;; Replace UI for messages, cmdline, and popupmenu.
 ;; (on-demand :folke/noice.nvim {:deps [:MunifTanjim/nui.nvim]})
 ;; Draw animated vertical line at the current scope of indent as cursor moves.
 (on-demand :echasnovski/mini.indentscope)
 ;; Flash cursor on jumping a distance.
 (on-demand :DanilaMihailov/beacon.nvim)
 ;; Underlines appear on every word under the cursor.
 (on-demand :itchyny/vim-cursorword)
 ;; Show git-status/diagnostics/search on scrollbar.
 (on-demand :lewis6991/satellite.nvim)
 ;; Manage Statusline/Winbar/Tabline.
 (on-demand :rebelot/heirline.nvim {:config [:rc.heirline.setup]})
 ;; Create Color Code in Neovim
 ;; Note: To automate its highlighter on color codes, load on events.
 (on-demand :uga-rosa/ccc.nvim {:config [:rc.ccc.keymap :rc.ccc.setup]})
 ;;; Motion ///1
 (on-demand :bkad/CamelCaseMotion {:config [:rc.CamelCaseMotion.keymap]})
 (on-demand :ggandor/leap.nvim
            {:config [:rc.leap.keymap :rc.leap.setup]
             :deps [:ggandor/leap-spooky.nvim]})
 (on-demand :aileot/vim-among_HML {:config [:rc.among_HML.add]})
 (on-demand :aileot/nvim-sticky-cursor {:config [:rc.sticky-cursor.keymap]})
 (on-demand :aileot/nvim-repeatable {:config [:rc.repeatable.post]})
 ;;; Insert ///1
 (on-demand :Shougo/ddc.vim
            {:event [:InsertEnter :CmdlineEnter]
             :config [:rc.ddc.post]
             :deps [denops
                    :Shougo/ddc-source-cmdline
                    :Shougo/ddc-source-cmdline-history
                    :Shougo/ddc-source-input
                    :Shougo/ddc-source-mocword
                    :aileot/ddc-source-typos
                    :gamoutatsumi/ddc-emoji
                    :tani/ddc-git
                    :4513ECHO/ddc-github
                    :Shougo/ddc-source-around
                    :matsui54/ddc-buffer
                    :LumaKernel/ddc-source-file
                    :tani/ddc-oldfiles
                    :Shougo/ddc-source-nvim-lsp
                    :matsui54/ddc-ultisnips
                    :matsui54/ddc-dictionary
                    :Shougo/ddc-source-omni
                    :matsui54/ddc-filter_editdistance
                    :matsui54/ddc-converter_truncate
                    :Shougo/ddc-sorter_rank
                    :Shougo/ddc-matcher_head
                    :Shougo/ddc-matcher_length
                    :tani/ddc-fuzzy
                    :matsui54/denops-popup-preview.vim
                    (dep :Shougo/ddc-ui-pum
                         {:deps [:Shougo/pum.vim] :config [:rc.pum.post]})]})
 (on-demand :SirVer/ultisnips
            {:event [:InsertEnter]
             :config [:$DEIN_RC_DIR/ultisnips/add.vim
                      :$DEIN_RC_DIR/ultisnips/source.vim
                      :$DEIN_RC_DIR/ultisnips/post.vim]})
 (on-demand :aileot/vim-spellhack {:config [:rc.spellhack.keymap]})
 (on-demand :windwp/nvim-autopairs
            {:event :InsertEnter :config [:rc.autopairs.post]})
 ;;; TextObj ///1
 (on-demand :kana/vim-textobj-user)
 ;; (deps [(dep :osyo-manga/vim-textobj-from_regexp)]))
 ;;; Browse ///1
 (on-demand :dyng/ctrlsf.vim
            {:keys (trigger-map! [:n :x] :<Plug>CtrlSF)
             :init #(vim.cmd "source $DEIN_RC_DIR/ctrlsf/add.vim")
             :config #(vim.cmd "source $DEIN_RC_DIR/ctrlsf/source.vim")})
 (on-demand :lambdalisue/fern.vim
            {:cmd :Fern
             :init #(require :rc.fern.keymap)
             :config #(require :rc.fern.setup)
             :deps [(dep :lambdalisue/fern-renderer-nerdfont.vim
                         {:config #(do
                                     (set vim.g.fern#renderer :nerdfont)
                                     (set vim.g.fern#renderer#nerdfont#indent_markers
                                          true))})
                    :lambdalisue/nerdfont.vim
                    (dep :lambdalisue/fern-git-status.vim
                         {:config #(vim.fn.fern_git_status#init)})
                    :lambdalisue/fern-mapping-git.vim]})
 (on-demand :stevearc/aerial.nvim
            {:cmd :Aerial
             :init #(require :rc.aerial.add)
             :config #(require :rc.aerial.setup)})
 ;;; Fold ///1
 (on-demand :lewis6991/foldsigns.nvim
            {:config #(let [m (require :foldsigns)]
                        (m.setup))})
 (on-demand :kevinhwang91/nvim-ufo {:deps :kevinhwang91/promise-async})
 ;;; Telescope ///1
 (on-demand :nvim-telescope/telescope.nvim
            {:config [:rc.telescope.keymap :rc.telescope.setup]
             :deps [:nvim-lua/popup.nvim
                    plenary
                    (dep :prochri/telescope-all-recent.nvim
                         {:config [:rc.telescope.all-recent.setup]
                          :deps [:kkharji/sqlite.lua]})
                    (dep :nvim-telescope/telescope-fzf-native.nvim
                         {:build :make
                          :config [:rc.telescope.fzf-native.setup]})
                    (dep :pwntester/octo.nvim {:cmd :Octo :deps [web-devicons]})
                    (dep :tsakirist/telescope-lazy.nvim
                         {:opts {:extensions {:lazy {:mappings {:open_plugins_picker :<C-h>
                                                                :open_in_find_files :<M-f>
                                                                :open_in_line_grep :<M-g>}}}}
                          :config (fn []
                                    (-> (require :telescope)
                                        (. :load_extension)
                                        (evaluate :lazy))
                                    (nmap! :<Space>zp (<Cmd> "Telescope lazy")))})]})
 ;;; Colorschemes ///1
 (colorscheme :rebelot/kanagawa.nvim {:name :kanagawa})
 (colorscheme :projekt0n/github-nvim-theme {:name :github})
 (colorscheme :rhysd/vim-color-spring-night {:name :spring-night})
 ;;; Git ///1
 (on-demand :tpope/vim-fugitive
            {:config [:rc.fugitive.add :rc.fugitive.source]})
 (on-demand :lambdalisue/gin.vim
            {:deps [denops] :cmd [:Gin :GinStatus] :init [:rc.gin.keymap]})
 (on-demand :lewis6991/gitsigns.nvim
            {:deps [plenary]
             :config [:rc.gitsigns.keymap :rc.gitsigns.setup :rc.gitsigns.post]})
 (on-demand :akinsho/git-conflict.nvim
            {:event [:BufReadPre] :config [:rc.git-conflict.source]})
 ;;; LSP ///1
 (on-demand :neovim/nvim-lspconfig {:config [:rc.lsp.config.post]})
 (on-demand "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
            {:config [:rc.lsp_lines.add]})
 (on-demand :joechrisellis/lsp-format-modifications.nvim {:deps [plenary]})
 (on-demand :aznhe21/actions-preview.nvim)
 ;; Show code context in statusline or winbar
 (on-demand :SmiteshP/nvim-navic {:config [:rc.navic.setup]})
 (on-demand :andrewferrier/textobj-diagnostic.nvim)
 ;; Adapt linter, formatter, etc., for Language Server.
 (on-demand :jose-elias-alvarez/null-ls.nvim)
 (on-demand :LostNeophyte/null-ls-embedded)
 (on-demand :pwntester/codeql.nvim)
 ;; SchemaStore for jsonls
 (on-demand :b0o/SchemaStore.nvim)
 ;;; Debug ///1
 (on-demand :mfussenegger/nvim-dap
            {:config [:rc.dap.add :rc.dap.post]
             :deps [(dep :rcarriga/nvim-dap-ui {:config [:rc.dap.ui.source]})
                    :jbyuki/one-small-step-for-vimkind]})
 ;;; Treesitter ///1
 (on-demand :nvim-treesitter/nvim-treesitter
            {:build ":TSUpdate"
             :deps [:yioneko/nvim-yati
                    (dep :m-demare/hlargs.nvim
                         {:config [:$DEIN_RC_DIR/treesitter/hlargs/source.lua]})]})
 (on-demand :windwp/nvim-ts-autotag
            {:config [:rc.treesitter.autotag.setup]
             :ft [:ejs
                  :eruby
                  :html
                  :htmldgango
                  :javascript.jsx
                  :javascriptreact
                  :jsx
                  :php
                  :svelte
                  :tsx
                  :typescript.tsx
                  :typescriptreact
                  :xml]})
 ;;; Markdown ///1
 (on-demand :nora75/markdowntable {:cmd [:TableMake :ToTable :UnTable]})
 (on-demand :mzlogin/vim-markdown-toc {:config [:source/markdown-toc.vim]})
 (on-demand :iamcco/markdown-preview.nvim
            {:cmd [:MarkdownPreviewToggle]
             :build ":call mkdp#util#install()"
             :config [:source/markdown-preview.vim]})
 ;;; External ///1
 (on-demand :lambdalisue/suda.vim
            {:event :CmdLineEnter
             :cmd :Suda
             :init [:rc.suda.keymap]
             :config [:rc.suda.setup]})
 (on-demand :tyru/open-browser.vim
            {:cmd :OpenBrowser
             :init [:rc.open-browser.add]
             :config [:rc.open-browser.source]})
 (on-demand :glacambre/firenvim
            {:cond #vim.g.started_by_firenvim
             :build ":call firenvim#install(0)"
             :config [:rc.firenvim.add]})
 (on-demand :skanehira/denops-openai.vim
            {:deps [denops] :cmd :OpenaiChat :setup [:rc.denops.openai.setup]})
 ;;; Ftplugin ///1
 (on-demand :barrett-ruth/import-cost.nvim {:build "sh install.sh yarn"})]
