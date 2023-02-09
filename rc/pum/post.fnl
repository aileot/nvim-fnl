;; TOML: ddc.toml
;; Repo: Shougo/pum.vim

(import-macros {: evaluate : nmap! : imap! : augroup! : au! : <Cmd>} :my.macros)

(local {: pum : ddc} (require :rc.pum.options))

(vim.fn.pum#set_option pum.default)
(vim.fn.ddc#custom#patch_global ddc.global-patch)

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

;; FIXME: Start completion on the first CmdlineEnter without the following
;; autocmd.
(fn with-completion [key]
  (-> (require :rc.pum.cmdline) ;
      (. :enable-cmdline-completion) ;
      (evaluate))
  key)

(nmap! ":" [:expr] #(with-completion ":"))
(nmap! "/" [:expr] #(with-completion "/"))
(nmap! "?" [:expr] #(with-completion "?"))

(augroup! :rcPumPostEnableCmdlineCompletion
  (au! :CmdLineEnter [:once] #(-> (require :rc.pum.cmdline)
                                  (. :enable-cmdline-completion)
                                  (evaluate))))

;; vim:nowrap
