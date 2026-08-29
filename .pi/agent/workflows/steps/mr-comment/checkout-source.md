Check out the reviewed source branch. Mechanical only.

Input: `{{workflow.input}}`
Evidence: `{{last.summary}}`

Never stash, reset, clean, or delete unrelated files.

`ready`: source branch bound. Include `workspace: {cwd: "<path>"}`.
`retry`: transient fetch error.
`blocked`: dirty unrelated checkout or missing remote.
