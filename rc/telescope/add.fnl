;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope.nvim

(import-macros {: noremap-operator! : <Cmd> : expand} :my.macros)

(local normalize vim.fs.normalize)

(noremap-operator! :<Space>Z (<Cmd> :Telescope))
(noremap-operator! :<Space>z<CR> (<Cmd> "Telescope resume"))

(noremap-operator! :<Space>zb (<Cmd> "Telescope buffers"))
(noremap-operator! :<Space>zo (<Cmd> "Telescope oldfiles"))

(noremap-operator! :<Space>zg (<Cmd> "Telescope git_files"))
(noremap-operator! :<Space>zl (<Cmd> "Telescope git_bcommits"))
(noremap-operator! :<Space>zL (<Cmd> "Telescope git_commits"))

(noremap-operator! :<Space>zh (<Cmd> "Telescope help_tags"))
(noremap-operator! :<Space>zm (<Cmd> "Telescope man_pages"))

(noremap-operator! :<Space>zc (<Cmd> "Telescope commands"))
(noremap-operator! :<Space>za (<Cmd> "Telescope autocommands"))
(noremap-operator! :<Space>zH (<Cmd> "Telescope highlights"))

(noremap-operator! "<Space>z:" (<Cmd> "Telescope command_history"))
(noremap-operator! :<Space>z/ (<Cmd> "Telescope current_buffer_fuzzy_find"))

(noremap-operator! "<Space>z\"" (<Cmd> "Telescope registers"))

;; Mappings ///1
(fn keymap-wrapper [opts]
  (let [{: keymaps} (require :telescope.builtin)]
    (keymaps opts)))

(noremap-operator! :<Space>zN #(keymap-wrapper {:modes [:n]}))
(noremap-operator! :<Space>zI #(keymap-wrapper {:modes [:i]}))
(noremap-operator! :<Space>zC #(keymap-wrapper {:modes [:c]}))
(noremap-operator! :<Space>zX #(keymap-wrapper {:modes [:x]}))
(noremap-operator! :<Space>zS #(keymap-wrapper {:modes [:s]}))
(noremap-operator! :<Space>zT #(keymap-wrapper {:modes [:t]}))

;; Find/Grep ///1
(fn fd-wrapper [extra-opts]
  (let [default-opts {:follow true :hidden true}
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

(lambda find-root [path]
  (let [root-markers [:.git]
        root-patterns [(vim.fn.stdpath :config)
                       (vim.fn.stdpath :cache)
                       (vim.fn.stdpath :data)
                       (vim.fn.stdpath :state)
                       (normalize :$XDG_CONFIG_HOME)
                       (normalize :$XDG_CACHE_HOME)
                       (normalize :$XDG_DATA_HOME)
                       (normalize :$XDG_STATE_HOME)
                       (normalize :$VIMRUMTIME)]
        first-root-marker-dir (-> (vim.fs.find root-markers
                                               {: path :upward true})
                                  (. 1)
                                  (vim.fs.dirname))
        first-root-pattern (-> (vim.fs.find root-patterns
                                            {: path
                                             :upward true
                                             :type :directory})
                               (. 1))
        only-one? (or first-root-marker-dir first-root-pattern)]
    (or only-one? ;
        (if (< (length first-root-marker-dir) (length first-root-pattern))
            first-root-pattern
            first-root-marker-dir))))

(noremap-operator! :<Space>zv ;
                   #(fd-wrapper {:search_dirs [(normalize :$XDG_CONFIG_HOME/nvim)]}))

(noremap-operator! :<Space>z. ;
                   #(fd-wrapper {:search_dirs [(normalize :$DOTFILES_HOME)]}))

(noremap-operator! :<Space>ze ;
                   #(fd-wrapper {:search_dirs [:/etc :/usr/share]}))

(noremap-operator! :<Space>zr ;
                   #(fd-wrapper {:search_dirs [(normalize :$VIMRUNTIME)]}))

(noremap-operator! :<Space>zq ;
                   #(fd-wrapper {:search_dirs [(normalize :$GHQ_ROOT)]}))

(noremap-operator! ["Search through plugin installed directories"] :<Space>zp ;
                   #(fd-wrapper {:search_dirs [(normalize :$DEIN_CACHE_HOME)
                                               (normalize :$XDG_DATA_HOME/nvim/site/pack)]}))

(noremap-operator! :<Space>z<BS> ;
                   #(fd-wrapper {:search_dirs [(normalize :$XDG_DATA_HOME/Trash)]}))

(noremap-operator! :<Space>z<Space> ;
                   #(fd-wrapper {:search_dirs [(find-root (expand "%:p"))]}))

(noremap-operator! :<Space>rv ;
                   #(grep-wrapper {:search_dirs [(normalize :$XDG_CONFIG_HOME/nvim)]}))

(noremap-operator! :<Space>rr ;
                   #(grep-wrapper {:search_dirs [(normalize :$VIMRUNTIME)]}))

(noremap-operator! :<Space>r. ;
                   #(grep-wrapper {:search_dirs [(normalize :$DOTFILES_HOME)]}))

(noremap-operator! :<Space>zr ;
                   #(grep-wrapper {:search_dirs [(normalize :$VIMRUNTIME)]}))

(noremap-operator! :<Space>r<Space> ;
                   #(grep-wrapper {:search_dirs [(find-root (expand "%:p"))]}))
