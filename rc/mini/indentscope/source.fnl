;; TOML: appearance.toml
;; Repo: echasnovski/mini.indentscope

(import-macros {: when-not : augroup! : au! : b! : hi!} :my.macros)

(local {: contains?} (require :my.utils))

(local {: gen_animation &as indentscope} (require :mini.indentscope))

(hi! :MiniIndentscopeSymbol {:fg "#77fac6"})

(local default-config
       {;; Help: MiniIndentscope.gen_animation
        :animation (gen_animation.exponential {:duration 20
                                               :easing :in
                                               ;; step
                                               ;; total
                                               :unit :step})})

(indentscope.setup default-config)

(augroup! :rcMiniIndentscopeSource
  (au! [:BufReadPost] [:desc "[indentscope] disable in small buffer"]
       #(let [min-lines 8]
          (when (< (vim.fn.line "$") min-lines)
            (b! :miniindentscope_disable true)
            (augroup! :rcMiniIndentscopeSourceEnableIfSwelled
              (au! [:BufWritePost] [:<buffer>]
                   #(when (<= min-lines (vim.fn.line "$"))
                      (b! :miniindentscope_disable nil)
                      (indentscope.auto_draw default-config)))))))
  (au! [:FileType] [:desc "[indentscope] disable in specific buffers"]
       #(let [buftypes-enabled ["" :help :terminal]]
          (when-not (contains? buftypes-enabled vim.bo.buftype)
            (b! :miniindentscope_disable true)))))
