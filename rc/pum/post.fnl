;; TOML: ddc.toml
;; Repo: Shougo/pum.vim

(import-macros {: inoremap! : augroup! : au! : <Cmd>} :my.macros)

(let [ddc-global-patch ;
      {:completionMenu :pum.vim
       :backspaceCompletion true
       :autoCompleteEvents [:InsertEnter
                            :TextChangedI
                            :TextChangedP
                            :CmdlineEnter
                            :CmdlineChanged]}]
  (vim.fn.ddc#custom#patch_global ddc-global-patch))

(local default-pum-options ;
       {:use_complete false
        :reversed false
        :scrollbar_char "│"
        :highlight_selected :PmenuSel
        :highlight_abbr :Pmenu
        :highlight_matches ""
        :highlight_kind :Comment
        :highlight_menu :Pmenu})

(vim.fn.pum#set_option default-pum-options)

(inoremap! [:literal :expr] :<C-n>
           "pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : ddc#map#manual_complete()")

(inoremap! [:literal :expr] :<C-p>
           "pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : ddc#map#manual_complete()")

(inoremap! [:literal :expr] :<C-S-n>
           "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(+1)<CR>' : ddc#map#manual_complete()")

(inoremap! [:literal :expr] :<C-S-p>
           "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(-1)<CR>' : ddc#map#manual_complete()")

(inoremap! :<C-y> (<Cmd> "call pum#map#confirm()"))
(inoremap! :<C-e> (<Cmd> "call pum#map#cancel()"))

(augroup! :rcPumPost/EnableCmdlineCompletion
          (au! :CmdLineEnter
               #(-> (require :rc.pum.cmdline)
                    (: :enable-cmdline-completion))))

{: default-pum-options}

;; vim:nowrap
