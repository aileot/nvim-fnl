;; TOML: external.toml
;; Repo: skanehira/denops-openai.vim

(import-macros {: first : expand : g!} :my.macros)

(g! :openai_config
    {:apiKey (first (vim.fn.readfile (expand :$VIM_API_TOKEN/openai)))})
