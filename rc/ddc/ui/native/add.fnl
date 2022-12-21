;; TOML: ddc.toml
;; Repo: Shougo/ddc-ui-native

(import-macros {: imap!} :my.macros)

(imap! [:literal :expr] :<C-n>
       "pumvisible() ? '<C-n>' : ddc#map#manual_complete()")

(imap! [:literal :expr] :<C-p>
       "pumvisible() ? '<C-p>' : ddc#map#manual_complete()")
