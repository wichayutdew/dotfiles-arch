Push the verified commit if any, then post the approved response messages. Prefer MCP over CLI.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Ledger: `{{last.summary}}`

Execute only approved `remoteActions`. For GitHub reviewer replies use `add_reply_to_pull_request_comment`; use `add_issue_comment` only for a general PR comment. Never force-push, resolve, approve, or merge.

`published`: push and replies confirmed.
`no-actions`: nothing to do.
`retry`: transient failure.
`superseded` / `blocked`: remote moved or ambiguous.
