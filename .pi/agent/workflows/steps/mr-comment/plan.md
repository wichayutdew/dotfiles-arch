Decide each unresolved review comment. Read-only on the bound checkout.

Input: `{{workflow.input}}`
Evidence: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Submit exactly:

# <Outcome title>
## Comments

For every unresolved comment:

### Suggestion
What the reviewer asked for.
### Verdict
Implement or not, and how. Back it with code evidence.
### Response message
Human reply to post if this comment is handled.
### Metadata
One value per bullet, never a packed sentence:
- `commentId`: `<id>`
- `discussionId`: `<id>`
- `reviewer`: `<name>`
- `path`: `<path>`
- `line`: `<line>`
- `host`: `<host>`.

Then:

## Implementation plan
Scoped files and observable changes. Empty if reply-only.
## Validation
Tests or checks with assessable benefit.
## Execution appendix (machine-readable)
JSON: `repository`, `workerCommands`, `reviewerCommands`, `remoteActions` (MCP-first replies and push).

`submit` when every comment has all four subheads.
`retry`: transient API failure.
`blocked`: unsafe or missing anchors.
