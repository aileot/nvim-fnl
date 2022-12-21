;; TOML: denops.toml
;; Repo: 4513ECHO/denops-gitter.vim

(import-macros {: command! : g! : first} :my.macros)

(g! "gitter#token"
    (first (vim.fn.readfile (vim.fs.normalize :$VIM_API_TOKEN/gitter))))

(command! :GitterReadingVimrc "tabe gitter://room/vim-jp/reading-vimrc")
