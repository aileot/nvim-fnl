;; TOML: init.toml
;; Repo: rktjmp/hotpot.nvim

(import-macros {: fn? : printf : command! : augroup! : au!} :my.macros)

(local {: alias!} (require :my.utils))

(alias! :fnl :Fnl)
;; Note: Expansion depends on &l:iskeyword.
(alias! :fnl= :Fnl=)

(command! :HotpotCacheClear #(let [{: clear-cache} (require :hotpot.api.cache)]
                               (clear-cache)))

(command! :HotpotCacheForceUpdate
          #(let [{: clear-cache} (require :hotpot.api.cache)]
             (clear-cache)
             (vim.fn.system [:nvim :--headless :+q])))

(augroup! :rcHotpotAdd
  (au! :FileType [:desc "Load private ftplugins written in Fennel"]
       ;; Ref: $VIMRUNTIME/ftplugin.vim
       ;; Note: `:runtime` doesn't invoke `SourceCmd` so that hotpot
       ;; cannot compile files.
       ;; "runtime! ftplugin/<amatch>.fnl ftplugins/<amatch>/*.fnl"))
       ;; Note: ftplugin files in Fennel must be written by myself. No needs to
       ;; count all the `ftplugin/<amatch>.fnl`s through `&runtimepath`.
       #(let [mod-name (printf "my.ftplugin.%s" $.match)
              (ok? mod) (pcall require mod-name)]
          (when ok?
            (assert (fn? mod)
                    (.. "expected function, dump:\n" (vim.inspect mod)))
            (mod)))))
