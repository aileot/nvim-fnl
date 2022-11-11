;; TOML: ddc.toml
;; Repo: Shougo/ddc.vim

(import-macros {: inoremap!} :my.macros)

(let [global-patch (require :rc.ddc.patch.global)
      filetype-patch (require :rc.ddc.patch.filetype)]
  (vim.fn.ddc#custom#patch_global global-patch)
  (filetype-patch.apply))

(when (pcall #(inoremap! [:expr :unique] :<C-n>
                         "ddc#map#can_complete() ? ddc#map#manual_complete() : '<C-n>'"))
  (pcall #(inoremap! [:expr :unique] :<C-p>
                     "ddc#map#can_complete() ? ddc#map#manual_complete() : '<C-p>'")))

(vim.schedule #(vim.fn.ddc#enable))
