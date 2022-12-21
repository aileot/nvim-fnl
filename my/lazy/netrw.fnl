;; Ref: $VIMRUNTIME/plugin/netrwPlugin.vim
;; Note: netrw is required to read remote files

(import-macros {: augroup! : au! : doautocmd! : g!} :my.macros)

(local {: del-augroup!} (require :my.utils))

(fn disable-netrw []
  "Prevent loading netrw and disable the file explorer."
  (g! :loaded_netrwPlugin true)
  (pcall del-augroup! :FileExplorer))

(fn idle-network-autocmds []
  "Enable \"Network\" augroup on-demand."
  (let [id (augroup! :myLazyNetrwExtractRemoteFeatures)]
    (lambda enable-network-autocmds [{: event : file}]
      ;; Note: Checked by `exists()` in netrwPlugin.vim; neither set it to
      ;; `nil` nor `false` is useless.
      (vim.cmd.unlet "g:loaded_netrwPlugin")
      (vim.cmd.source :$VIMRUNTIME/plugin/netrwPlugin.vim)
      (del-augroup! :FileExplorer)
      (del-augroup! id)
      ;; FIXME: It once fails with error: "'pattern' must be a string or table."
      (doautocmd! event {:group :Network :pattern file}))
    (au! id [:BufWriteCmd :FileWriteCmd]
         ["{file,ftp,rcp,scp,dav,davs,rsync,sftp,http}://*"]
         `enable-network-autocmds)
    (au! id [:BufReadCmd :FileReadCmd :SourceCmd]
         ["{file,ftp,rcp,scp,dav,davs,rsync,sftp,http,https}://*"]
         `enable-network-autocmds)))

{: disable-netrw : idle-network-autocmds}
