;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope.nvim

(import-macros {: nmap! : <Cmd> : expand} :my.macros)

(local {: find-root} (require :my.utils))

(nmap! :<Space>Z (<Cmd> :Telescope))
(nmap! :<Space>z<CR> (<Cmd> "Telescope resume"))

(nmap! :<Space>zb (<Cmd> "Telescope buffers"))
(nmap! :<Space>zo (<Cmd> "Telescope oldfiles"))

(nmap! :<Space>zq (<Cmd> "Telescope quickfix"))
(nmap! :<Space>zQ (<Cmd> "Telescope quickfixhistory"))

(nmap! :<Space>zh (<Cmd> "Telescope help_tags"))
(nmap! :<Space>zm (<Cmd> "Telescope man_pages"))

(nmap! :<Space>zc (<Cmd> "Telescope commands"))
(nmap! :<Space>za (<Cmd> "Telescope autocommands"))
(nmap! :<Space>zH (<Cmd> "Telescope highlights"))

(nmap! "<Space>z:" (<Cmd> "Telescope command_history"))
(nmap! :<Space>z/ (<Cmd> "Telescope current_buffer_fuzzy_find"))

(nmap! "<Space>z\"" (<Cmd> "Telescope registers"))

(lambda git-source [name ?opts]
  (let [{name source} (require :telescope.builtin)
        default-opts {:cwd (vim.fn.expand "%:h") :initial_mode :normal}
        opts (if ?opts (vim.tbl_extend :force default-opts ?opts) ;
                 default-opts)]
    (source opts)))

(nmap! :<Space>zgf [:desc "[telescope] git-files"]
       #(git-source :git_files {:initial_mode :insert}))

(nmap! :<Space>zgc [:desc "[telescope] git-commits"] #(git-source :git_commits))

(nmap! :<Space>zgC [:desc "[telescope] git-commits for current buffer"]
       #(git-source :git_bcommits))

;; Mnemonic: "y" looks like a branch of tree.

(nmap! :<Space>zgy [:desc "[telescope] git-branches"]
       #(git-source :git_branches))

(nmap! :<Space>zgs [:desc "[telescope] git-stash"] #(git-source :git_stash))

;; Mappings ///1
(fn keymap-wrapper [opts]
  (let [{: keymaps} (require :telescope.builtin)]
    (keymaps opts)))

(nmap! :<Space>zN [:desc "[telescope] Nmaps"] #(keymap-wrapper {:modes [:n]}))

(nmap! :<Space>zI [:desc "[telescope] Imaps"] #(keymap-wrapper {:modes [:i]}))

(nmap! :<Space>zC [:desc "[telescope] Cmaps"] #(keymap-wrapper {:modes [:c]}))

(nmap! :<Space>zX [:desc "[telescope] Xmaps"] #(keymap-wrapper {:modes [:x]}))

(nmap! :<Space>zS [:desc "[telescope] Smaps"] #(keymap-wrapper {:modes [:s]}))

(nmap! :<Space>zT [:desc "[telescope] Tmaps"] #(keymap-wrapper {:modes [:t]}))

;; Find/Grep ///1
(fn fd-wrapper [extra-opts]
  (let [default-opts {:follow true
                      :hidden true
                      :no_ignore true
                      :no_ignore_parent true}
        opts (collect [k v (pairs extra-opts) &into default-opts]
               (values k v))
        {: find_files} (require :telescope.builtin)]
    (find_files opts)))

(fn grep-wrapper [extra-opts]
  (let [default-opts {:search ""}
        opts (collect [k v (pairs extra-opts) &into default-opts]
               (values k v))
        {: grep_string} (require :telescope.builtin)]
    (grep_string opts)))

;; Keymap: fd ///1

(nmap! :<Space>zv [:desc "[telescope] paths of nvimrc"]
       #(fd-wrapper {:search_dirs [(expand :$XDG_CONFIG_HOME/nvim)]}))

(nmap! :<Space>z. [:desc "[telescope] paths of dotfiles"]
       #(fd-wrapper {:search_dirs [(expand :$DOTFILES_HOME)]}))

(nmap! :<Space>zd [:desc "[telescope] paths of $NVIM_DEV_HOME"]
       #(fd-wrapper {:search_dirs [(expand :$NVIM_DEV_HOME)]}))

(nmap! :<Space>ze [:desc "[telescope] paths of /usr/share"]
       #(fd-wrapper {:search_dirs [:/etc :/usr/share]}))

(nmap! :<Space>zr [:desc "[telescope] paths of $VIMRUNTIME"]
       #(fd-wrapper {:search_dirs [(expand :$VIMRUNTIME)]}))

(nmap! :<Space>zq [:desc "[telescope] paths of $GHQ_ROOT"]
       #(fd-wrapper {:search_dirs [(expand :$GHQ_ROOT)]}))

(nmap! :<Space>zp [:desc "[telescope] paths of plugins"]
       #(fd-wrapper {:search_dirs [(expand :$DEIN_CACHE_HOME)
                                   (expand :$XDG_DATA_HOME/nvim/site/pack)]}))

(nmap! :<Space>z<BS> [:desc "[telescope] paths of trashes"]
       #(fd-wrapper {:search_dirs [(expand :$XDG_DATA_HOME/Trash)]}))

(nmap! :<Space>z<Space> [:desc "[telescope] paths of current project"]
       #(fd-wrapper {:search_dirs [(find-root (expand "%:p"))]}))

(nmap! :<Space>zD [:desc "[telescope] paths of $MY_DEV"]
       #(fd-wrapper {:search_dirs [(expand :$MY_DEV)]}))

;; Keymap: rg ///1

(nmap! :<Space>rv [:desc "[telescope] grep files in nvimrc"]
       #(grep-wrapper {:search_dirs [(expand :$XDG_CONFIG_HOME/nvim)]}))

(nmap! :<Space>r. [:desc "[telescope] grep files in dotfiles"]
       #(grep-wrapper {:search_dirs [(expand :$DOTFILES_HOME)]}))

(nmap! :<Space>rd [:desc "[telescope] grep files in $NVIM_DEV_HOME"]
       #(grep-wrapper {:search_dirs [(expand :$NVIM_DEV_HOME)]}))

(nmap! :<Space>rr [:desc "[telescope] grep files in $VIMRUNTIME"]
       #(grep-wrapper {:search_dirs [(expand :$VIMRUNTIME)]}))

(nmap! :<Space>rq [:desc "[telescope] grep files in $GHQ_ROOT"]
       #(grep-wrapper {:search_dirs [(expand :$GHQ_ROOT)]}))

(nmap! :<Space>r<Space> [:desc "[telescope] grep files in current project"]
       #(grep-wrapper {:search_dirs [(find-root (expand "%:p"))]}))
