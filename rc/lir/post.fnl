;; TOML: browse.toml
;; Repo: tamago324/lir.nvim

(import-macros {: setlocal! : xnoremap! : <C-u> : join} :my.macros)

(local lir (require :lir))
(local (devicons-available? devicons) (pcall require :nvim-web-devicons))

(macro actions [action]
  (let [lir-actions `(require :lir.actions)]
    `(. ,lir-actions ,action)))

(macro another-actions [mod action]
  `(let [(ok?# lir-actions#) (pcall require (.. :lir. ,mod :.actions))]
     (when ok?#
       (. lir-actions# ,action))))

(macro rc-actions [mod action]
  (let [lir-actions `(require (.. :rc.lir.actions. ,mod))]
    `(. ,lir-actions ,action)))

(lir.setup {:show_hidden_files true
            :hide_cursor false
            :devicons_enable devicons-available?
            :mappings {:z. (actions :toggle_show_hidden)
                       :o (actions :split)
                       :O (actions :vsplit)
                       :gO (actions :tabedit)
                       :h (actions :up)
                       :l (actions :edit)
                       :<CR> (actions :edit)
                       :cd (actions :mkdir)
                       :cf (actions :newfile)
                       :cF (rc-actions :create_new_files)
                       :R (actions :rename)
                       :gR (another-actions :mmv :mmv)
                       :D (actions :delete)
                       :Y (actions :yank_path)
                       :yy (another-actions :clipboard :copy)
                       :x (another-actions :clipboard :cut)
                       :P (another-actions :clipboard :paste)
                       :mm (another-actions :mark :toggle_mark)
                       :mk (fn []
                             (another-actions :mark :toggle_mark)
                             (vim.cmd.normal! :k))
                       :mj (fn []
                             (another-actions :mark :toggle_mark)
                             (vim.cmd.normal! :j))}
            :on_init (fn []
                       (setlocal! :number false)
                       (setlocal! :signColumn :no)
                       (xnoremap! [:<buffer> :silent] :m
                                  (<C-u> "lua require'lir.mark.actions'.toggle_mark('v')"))
                       (xnoremap! [:<buffer> :silent] :Y
                                  (<C-u> (join " "
                                               [:lua
                                                "require'lir.mark.actions'.toggle_mark('v')"
                                                "require'lir.clipboard.actions'.copy()"])))
                       (xnoremap! [:<buffer> :silent] :x
                                  (<C-u> (join " "
                                               [:lua
                                                "require'lir.mark.actions'.toggle_mark('v')"
                                                "require'lir.clipboard.actions'.cut()"]))))})

;; (when devicons-available?
;;   (devicons.setup {:override {:lir_folder_icon {:icon ""
;;                                                 :color "#7ebae4"
;;                                                 :name :LirFolderNode}}}))
