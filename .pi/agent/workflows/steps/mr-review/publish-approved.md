Publish only approved review actions. Prefer MCP over CLI.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Feedback: `{{reviewed.feedback}}`
Handoff: `{{last.summary}}`

GitHub: create pending review, add marked comments, submit `COMMENT`. Never approve, merge, resolve, close, or delete.

`published`: every approved action exists on the host.
`retry`: transient failure.
`blocked`: ambiguity or error.
