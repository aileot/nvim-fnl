{:ddc {:global-patch {:ui :pum
                      :backspaceCompletion true
                      :autoCompleteEvents [:InsertEnter
                                           :TextChangedI
                                           :TextChangedP
                                           :CmdlineEnter
                                           :CmdlineChanged]}}
 :pum {:default {:use_complete false
                 :padding true
                 :reversed false
                 :scrollbar_char "│"
                 :highlight_selected :PmenuSel
                 :highlight_abbr :Pmenu
                 :highlight_matches ""
                 :highlight_kind :Comment
                 :highlight_menu :Pmenu}}}
