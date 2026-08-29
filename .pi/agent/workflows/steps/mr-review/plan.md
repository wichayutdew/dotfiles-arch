Turn reviewer findings into comments the user can approve.

Input: `{{workflow.input}}`
Findings: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Submit exactly:

## Review 1: <short description>
- **Path / line:** `<path>:<line>`
- **Detailed suggestion:** <specific recommended change>
- **Verdict:** <topic> — <why this should be improved>
- **Comment:** <the exact human-sounding text to post>

Repeat this section for every comment to publish, incrementing the review number.

Then:

## Publication contract
Fenced JSON `actions` for GitLab MCP or GitHub pending-review MCP (`create`, one comment each, `submit_pending` + `COMMENT`). Use each review's **Comment** value as the published text. CLI only with `mcpFallback`. No approve, merge, close, resolve, or delete.

`submit` when every intended comment has Path / line, Detailed suggestion, Verdict, and Comment.
`retry`: transient read failure.
`blocked`: stale head.
