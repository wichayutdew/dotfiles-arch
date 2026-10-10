---
name: investigate
description: Investigate a Jira issue or question through scope approval, evidence gathering, validation, and a written report.
---

# Investigate

## Workflow direction

Treat the text that invoked this skill as the authoritative investigation request. Derive Jira, repository, logs, and other integration context from that request and the active workspace.

Execute the linked stages sequentially. Carry the complete invoking request and prior stage artifacts forward; do not replace source evidence with a summary. Follow the declared outcome route after each stage.

Use the model and thinking level specified for each stage. Model selection does not approve a plan or authorize publication. Ask one focused question only when a required business fact, access grant, or authority cannot be discovered. Stop for explicit human approval at an approval gate.

## Stages

| Stage | Prompt | Model | Thinking | Outcomes |
| --- | --- | --- | --- | --- |
| intake | [intake.md](intake.md) | `nvidia/nemotron-3.5-lightning:free` | low | `ready` → plan; `blocked` → pause; `handoff` → intake |
| plan | [plan.md](plan.md) | `nvidia/nemotron-3-ultra-550b-a55b:free` | high | `ready` → research; `gaps` → intake; `blocked` → pause; `handoff` → plan |
| research | [research.md](research.md) | `poolside/laguna-s-2.1:free` | high | `ready` → validate; `blocked` → pause; `handoff` → research |
| validate | [validate.md](validate.md) | `cohere/north-mini-code:free` | high | `ready` → write-report; `gaps` → research; `blocked` → pause; `handoff` → validate |
| write-report | [write-report.md](write-report.md) | `nvidia/nemotron-3.5-lightning:free` | low | `ready` → done; `gaps` → validate; `blocked` → pause; `handoff` → write-report |

## Scope approval gate

Before `plan` can continue with `ready`, obtain explicit approval for an artifact with these exact headings:

- level 1: `Report destination`
- level 2: `Goal/Acceptance Criteria`
- level 2: `Non Goal`
- level 2: `Investigation Resources`
- level 2: `Questions`

Obtain explicit human approval of the complete artifact before continuing.
