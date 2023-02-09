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

;; Note: The names derives from :h lsp-method

(local documentDiagnostics vim.diagnostic.document-diagnostics)
(local workspaceDiagnostics vim.diagnostic.workspace-diagnostics)

(local definition lsp.definition)
(local references lsp.references)
(local declaration lsp.declaration)
(local typeDefinition lsp.type_definition)
(local implementation lsp.implementation)

(local hover (inherit-opts-for-gf lsp.hover))
(local signatureHelp (inherit-opts-for-gf lsp.signature_help))

(local rename lsp.rename)

(local addWorkspaceFolder lsp.add_workspace_folder)
(local removeWorkspaceFolder lsp.remove_workspace_folder)

(local documentSymbols lsp.document_symbols)
(local workspaceSymbols lsp.workspace_symbols)

(local outgoingCalls lsp.outgoing_calls)
(local incomingCalls lsp.incoming_calls)

(local codeAction lsp.code_action)
(local rangeCodeAction
       #(Operator.run (fn [{: start : end}]
                        (lsp.code_action {:range {: start : end}}))))

(local format (fn []
                (lsp.format {:async true})
                (comment (vim.notify "[lsp] formatted entire buffer"))))

(local rangeFormat
       #(Operator.run (fn [{: start : end}]
                        (lsp.format {:async true :range {: start : end}})
                        (comment (vim.notify "[lsp] formatted in range")))))

{: documentDiagnostics
 : workspaceDiagnostics
 : definition
 : references
 : declaration
 : typeDefinition
 : implementation
 : hover
 : signatureHelp
 : rename
 : addWorkspaceFolder
 : removeWorkspaceFolder
 : documentSymbols
 : workspaceSymbols
 : outgoingCalls
 : incomingCalls
 : codeAction
 : rangeCodeAction
 : format
 : rangeFormat}
