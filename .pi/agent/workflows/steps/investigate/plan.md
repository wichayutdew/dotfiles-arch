Define investigation scope. Read-only.

Input: `{{workflow.input}}`
Intake: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Submit exactly:

# Report destination
`~/repositories/investigation-findings/<slug>.md`
## Goal/Acceptance Criteria
## Non Goal
## Investigation Resources
Each tool or MCP and why it matters to the goal.
## Questions
Open questions for the user, or `None`.

`submit` when destination, goal, and resources are explicit.
`retry`: transient read failure.
`blocked`: empty input or required Jira missing.
