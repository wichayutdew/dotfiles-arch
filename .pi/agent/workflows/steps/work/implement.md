Implement the approved plan in the bound worktree.

Request: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Feedback: `{{reviewed.feedback}}`
Ledger: `{{last.summary}}`

Stay in `repositories[0].cwd`. Run only `worker` commands. Use TDD only for tests listed with an assessable benefit. Do not add tests to justify extra code. Leave pre-existing dirty files alone. Do not push, open reviews, or mutate Jira.

`ready`: red/green evidence and a commit. Pass the JSON contract unchanged.
`retry`: transient tool failure.
`blocked`: missing authority or unrecoverable failure.
