;; TOML: browse.toml
;; Repo: kana/vim-altr

;; cspell:words altr
(local normalize vim.fs.normalize)

(local rules ;
       [["%.vim" "test/%.vimspec" "tests/%.vimspec"]
        ["%.js" "%.spec.js" "%.test.js"]
        ["%.ts" "%.spec.ts" "%.test.ts"]
        ["%.jsx" "%.spec.jsx" "%.test.jsx"]
        ["%.tsx" "%.spec.tsx" "%.test.tsx"]
        ["%.fnl" "%.lua"]
        ["%/fnl/%.fnl" "/%/lua/%.lua"]
        ;; Note: Preceding `/` is required to match against hotpot cache path.
        ["/%/fnl/%.fnl" (normalize "$XDG_CACHE_HOME/nvim/hotpot/%/fnl/%.lua")]])

;; Add rules to altr-default-rules.
(each [_ rule (ipairs rules)]
  (vim.fn.altr#define rule))
