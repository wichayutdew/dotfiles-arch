Check the draft against the approved goal. Read-only. Do not write the report file.

Input: `{{workflow.input}}`
Approved scope: `{{reviewed.artifact}}`
Draft: `{{last.summary}}`

Re-check citations. Reject filler, missing stories, or claims that miss the goal.

`approved`: draft satisfies the goal.
`gaps`: return to research with exact gaps.
`retry`: transient read failure.
`blocked`: irreconcilable evidence.
