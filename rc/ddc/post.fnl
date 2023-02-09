;; TOML: ddc.toml
;; Repo: Shougo/ddc.vim

(local global-patch (require :rc.ddc.patch.global))
(local filetype-patch (require :rc.ddc.patch.filetype))

(vim.fn.ddc#custom#patch_global global-patch)
(filetype-patch.apply)

(vim.schedule vim.fn.ddc#enable)
