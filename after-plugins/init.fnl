(import-macros {: augroup! : au!} :my.macros)

(vim.cmd "
runtime rc/loaded.vim
runtime! mappings/*.vim
runtime lazy/init.vim
runtime once/init.vim
")

(require :after-plugins.augroups)
(require :after-plugins.colorscheme)
(require :after-plugins.startpage)
(require :after-plugins.findpath)
(require :after-plugins.backup-files)

(require :my.lazy.nmaps)
(require :my.lazy.filetypes)

(augroup! :afterVimEnter/LoadOnce
          (au! :OptionSet [:diff] [:once] #(require :my.lazy.diff))
          (au! :ModeChanged ["*:*[vV\022]"] [:once] #(require :my.lazy.xmaps))
          (au! :ModeChanged ["*:*[ovV\022]"] [:once] #(require :my.lazy.omaps))
          (au! :CmdLineEnter [:once] #(require :my.lazy.cmaps))
          (au! [:CmdLineEnter :CmdWinEnter]
               [:once :desc "Define additional user commands"] ;
               #(vim.schedule #(require :my.lazy.commands))))
