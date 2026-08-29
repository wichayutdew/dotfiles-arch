Check the local work against each approved verdict and the reviewer's intent. Read-only.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Ledger: `{{last.summary}}`

`passed`: verdicts and checks hold; hand `remoteActions` to deliver.
`no-actions`: nothing left to push or reply.
`failed`: return to implement with the exact gap.
`retry`: transient read-only failure.
`blocked`: corrupted workspace.
