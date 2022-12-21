;; TOML: ddc.toml
;; Repo: Shougo/pum.vim

(import-macros {: augroup! : au! : cmap! : <Cmd>} :my.macros)

(local {: default-pum-options} (require :rc.pum.post))

(fn setup-cmdline-options []
  (let [cmd-type (vim.fn.getcmdtype)
        reverse? (not package.loaded.noice)
        new-pum-options {:reversed reverse?}
        keywordPattern "[-.0-9a-zA-Z_:#]*"
        cmdlineSources (match cmd-type
                         ":"
                         [:git-branch
                          :cmdline-history
                          :cmdline
                          :cmdline.suggest
                          :around
                          :dictionary]
                         "@"
                         [:cmdline-history :input :buffer :dictionary]
                         ;; "/" or "?"
                         _
                         [:cmdline-history :around :dictionary])
        new-ddc-patches {:ui :pum : keywordPattern : cmdlineSources}
        save-ddc-patch (vim.fn.ddc#custom#get_buffer)]
    (vim.fn.pum#set_option new-pum-options)
    (vim.fn.ddc#custom#patch_buffer new-ddc-patches)
    (augroup! :rcPumCmdlineRestoreCompletionOptions
      (au! :CmdlineLeave [:once]
           (fn []
             (vim.fn.pum#set_option default-pum-options)
             (vim.fn.ddc#custom#patch_buffer save-ddc-patch))))))

(fn enable-cmdline-completion []
  (let [reverse? (not package.loaded.noice)]
    (cmap! [:literal :expr] (if reverse? :<C-p> :<C-n>)
           "pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : ddc#map#complete('pum')")
    (cmap! [:literal :expr] (if reverse? :<C-n> :<C-p>)
           "pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : ddc#map#complete('pum')")
    (cmap! [:literal :expr] (if reverse? :<C-S-p> :<C-S-n>)
           "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(+1)<CR>' : ddc#map#complete('pum')")
    (cmap! [:literal :expr] (if reverse? :<C-S-n> :<C-S-p>)
           "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(-1)<CR>' : ddc#map#complete('pum')"))
  (cmap! :<C-y> (<Cmd> "call pum#map#confirm()"))
  (cmap! [:literal :expr] :<C-e>
         "pum#visible() ? '<Cmd>call pum#map#cancel()<CR>' : '<End>'. ddc#map#complete('pum')")
  (setup-cmdline-options)
  (vim.fn.ddc#enable_cmdline_completion))

{: enable-cmdline-completion}
