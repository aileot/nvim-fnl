(vim.cmd "
runtime! mappings/*.vim
runtime lazy/init.vim
runtime once/init.vim
")

(require :my.lazy.augroups)
(require :my.lazy.colorscheme)
(require :my.lazy.startpage)
(require :after-plugins.findpath)
(require :after-plugins.backup-files)
(require :my.lazy.viewer-mode)
(require :my.lazy.filetypes)
(require :my.lazy.diff)
(require :my.lazy.nmaps)
(require :my.lazy.imaps)
(require :my.lazy.cmaps)
(require :my.lazy.tmaps)
(require :my.lazy.textobj-maps)
(require :my.lazy.commands)
