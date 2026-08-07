# Local workflow specification

This directory defines the local workflow specification in `agent/workflows/`.
The YAML specifications compose stage prompts in `agent/workflows/steps/`.

```mermaid
flowchart TD
    S[Workflow specification] --> W[/work.workflow.yaml/]
    S --> T[/ticket.workflow.yaml/]
    S --> J[/jira.workflow.yaml/]
    S --> I[/investigate.workflow.yaml/]
    S --> R[/mr-review.workflow.yaml/]
    S --> C[/mr-comment.workflow.yaml/]

    W --> WP[plan → implement → verify]
    T --> TP[plan → implement → verify]
    J --> JP[draft → plan approval → create]
    I --> IP[retrieve → investigate → validate]
    R --> RP[plan → review → confirm → publish]
    C --> CP[plan → implement → verify → confirm → publish]
```

`/jira` accepts one readable Markdown-file path or a quick Story breakdown. Its
`draft` stage creates no Jira records. Its Plannotator-gated `plan` stage
validates project metadata, required fields, and dependency links through
Atlassian MCP. Approval authorizes only `create` to make the reviewed Epic and
Stories and re-read them for verification.

```mermaid
flowchart LR
    P[Plan] --> I[Implement]
    I --> V{Verify}
    V -->|pass| D[Done]
    V -->|needs changes| I
```
