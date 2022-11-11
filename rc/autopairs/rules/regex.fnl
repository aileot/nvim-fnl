;; TOML: insert.toml
;; Repo: windwp/nvim-autopairs

(local Rule (require :nvim-autopairs.rule))

[(Rule "\\(" "\\)")
 (Rule "\\{" "\\}")
 (Rule "\\[" "\\]")
 ;; Vim regex
 (Rule "\\<" "\\>" :vim)
 (Rule "\\%(" "\\)" :vim)
 (Rule "\\%[" "\\]" :vim)
 (Rule "%(" ")" :vim)
 (Rule "%[" "]" :vim)]
