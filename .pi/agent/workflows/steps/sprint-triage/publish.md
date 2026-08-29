Push the KB branch, open the MR, and append the human guide to Confluence. Prefer MCP.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Ledger: `{{last.summary}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.

1. Push without force. Create the MR via GitLab MCP using the approved title and verified host template only. If none is verified, do not block or ask for confirmation: create it without description adjustment, read back its description as the template, then update only the managed region.
2. Re-read the Confluence page as HTML. Block if its version or hash drifted. Extract the approved `Exact append HTML` fragment from the plan artifact, append it at `confluence.appendMode` to the fetched page body, and update the page through the Atlassian MCP with `contentFormat: "html"`. Do not send Markdown, Markdown code fences, or an HTML-escaped fragment. Preserve the page title and all pre-existing body content.

`ready`: MR and Confluence append confirmed.
`retry`: transient API failure.
`blocked`: hash mismatch or mutation failure.
