;; TOML: telescope.toml
;; Repo: nvim-telescope/telescope.nvim

(import-macros {: augroup! : au!} :my.macros)

(local telescope (require :telescope))
(local lsp (require :my.lsp))
(local defaults (require :rc.telescope.default-config))

(fn ts-builtin [method ?opts]
  (let [builtin (require :telescope.builtin)
        func (. builtin method)]
    (func ?opts)))

(fn ts-builtin-lsp [method ?opts]
  (let [builtin (require :telescope.builtin)
        func (. builtin (.. :lsp_ method))]
    (func ?opts)))

(set lsp.documentDiagnostics #(ts-builtin :diagnostics {:bufnr 0}))
(set lsp.workspaceDiagnostics #(ts-builtin :diagnostics))

(set lsp.definition #(ts-builtin-lsp :definitions))
(set lsp.references #(ts-builtin-lsp :references))
(set lsp.declaration #(ts-builtin-lsp :declarations))
(set lsp.typeDefinition #(ts-builtin-lsp :type_definitions))
(set lsp.implementation #(ts-builtin-lsp :implementations))

(set lsp.documentSymbols #(ts-builtin-lsp :document_symbols))
(set lsp.workspaceSymbols #(ts-builtin-lsp :workspace_symbols))

(telescope.setup {: defaults})

(augroup! :rcTelescopePostWorkaroundNoFoldFoundInBufferFromTelescope
  (au! :Syntax "normal! zx"))
