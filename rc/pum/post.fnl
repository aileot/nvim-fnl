;; TOML: ddc.toml
;; Repo: Shougo/pum.vim

(import-macros {: imap! : augroup! : au! : <Cmd>} :my.macros)

(let [ddc-global-patch ;
      {:ui :pum
       :backspaceCompletion true
       :autoCompleteEvents [:InsertEnter
                            :TextChangedI
                            :TextChangedP
                            :CmdlineEnter
                            :CmdlineChanged]}]
  (vim.fn.ddc#custom#patch_global ddc-global-patch))

(local default-pum-options ;
       {:use_complete false
        :padding true
        :reversed false
        :scrollbar_char "│"
        :highlight_selected :PmenuSel
        :highlight_abbr :Pmenu
        :highlight_matches ""
        :highlight_kind :Comment
        :highlight_menu :Pmenu})

(vim.fn.pum#set_option default-pum-options)

(when (pcall #(imap! [:literal :expr :unique] :<C-n>
                     "pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : ddc#map#manual_complete()"))
  (imap! [:literal :expr] :<C-p>
         "pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : ddc#map#manual_complete()")
  (imap! [:literal :expr] :<C-S-n>
         "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(+1)<CR>' : ddc#map#manual_complete()")
  (imap! [:literal :expr] :<C-S-p>
         "pum#visible() ? '<Cmd>call pum#map#insert_relative_page(-1)<CR>' : ddc#map#manual_complete()")
  (imap! :<C-y> (<Cmd> "call pum#map#confirm()"))
  (imap! :<C-e> (<Cmd> "call pum#map#cancel()")))

(augroup! :rcPumPostEnableCmdlineCompletion
  (au! :CmdLineEnter #(-> (require :rc.pum.cmdline)
                          (: :enable-cmdline-completion))))

{: default-pum-options}

;; vim:nowrap
