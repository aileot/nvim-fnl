(import-macros {: setlocal!} :my.macros)

(local {: Operator} (require :my.utils))

(local lsp vim.lsp.buf)

(fn inherit-opts-for-gf [func]
  #(let [o vim.o
         save-opts {:path o.path
                    :isfname o.isfname
                    :suffixesadd o.suffixesadd
                    :includeexpr o.includeexpr}]
     (func)
     (each [k v (pairs save-opts)]
       (setlocal! k v))))

(local document-diagnostics vim.diagnostic.document-diagnostics)
(local workspace-diagnostics vim.diagnostic.workspace-diagnostics)

(local definitions lsp.definition)
(local references lsp.references)
(local declarations lsp.declarations)
(local type-definitions lsp.type_definitions)
(local implementations lsp.implementations)

(local hover (inherit-opts-for-gf lsp.hover))
(local signature-help (inherit-opts-for-gf lsp.signature_help))

(local rename lsp.rename)

(local add-workspace-folder lsp.add_workspace_folder)
(local remove-workspace-folder lsp.remove_workspace_folder)

(local document-symbols lsp.document_symbols)
(local workspace-symbols lsp.workspace_symbols)

(local outgoing-calls lsp.outgoing_calls)
(local incoming-calls lsp.incoming_calls)

(local code-actions lsp.code_action)
(local range-code-actions
       (Operator.new (fn [start end]
                       (lsp.code_action {:range {: start : end}}))))

(local format (fn []
                (lsp.format {:async true})
                (vim.notify "[lsp] formatted entire buffer")))

(local range-format
       (Operator.new (fn [start end]
                       (lsp.format {;
                                    :async true
                                    :range {: start : end}})
                       (vim.notify "[lsp] formatted in range"))))

{: document-diagnostics
 : workspace-diagnostics
 : definitions
 : references
 : declarations
 : type-definitions
 : implementations
 : hover
 : signature-help
 : rename
 : add-workspace-folder
 : remove-workspace-folder
 : document-symbols
 : workspace-symbols
 : outgoing-calls
 : incoming-calls
 : code-actions
 : range-code-actions
 : format
 : range-format}
