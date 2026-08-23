# Workflow Specifications

This directory defines autonomous workflow specifications in `agent/workflows/` composed from stage prompts in `agent/workflows/steps/`.

---

## Review title format

All PR/MR titles created by these workflows follow the [Conventional Commits](https://www.conventionalcommits.org/) grammar:

```
type(scope)!?: brief description
```

- `type` must be one of: `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`.
- `scope` is optional.
- `!` for breaking changes is optional.
- The subject after the colon must be a brief, imperative description of the change.

Workflow-specific rules:

- **`/work`** — no verified Jira source exists. Use a semantic descriptive title only; do not append a ticket key. Example: `feat(api): add rate limiting to registration endpoint`.
- **`/ticket`** — requires the verified Jira key. Record the key in the plan artifact and repeat it verbatim in brackets: `fix(scope): [PROJ-1234] resolve missing header`. The bracketed key must exactly match the approved `jiraTicket` value.
- **`/sprint-triage`** — aggregates many support tickets with no single canonical representative. Use a semantic descriptive title only; do not select a representative ticket or append a `[KEY]`. Example: `docs(triage): publish 2026-08-10 to 2026-08-21 support findings`.

Malformed titles or mismatched Jira evidence block publication before any remote mutation.

---

## 1. `/work` — Local Work
Prepares a dedicated workspace, drafts a plan for Plannotator review, implements changes with TDD, independently verifies, and publishes the verified branch as a template-based PR/MR.

```mermaid
flowchart TD
    Start([Start: /work]) --> Prep[prepare-workspace]
    Prep -->|ready| Plan[plan + Plannotator]
    Prep -->|retry| Prep
    Prep -->|blocked| Pause[$pause]

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|workspace-refresh| Prep
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|passed| Pub[publish]
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver

    Pub -->|published| Done([$done])
    Pub -->|retry| Pub
    Pub -->|blocked| Pause
```

---

## 2. `/ticket` — Jira Ticket Work
Prepares an isolated worktree, reads Jira acceptance criteria, drafts a plan for Plannotator review, implements with TDD, independently verifies, and publishes the verified branch as a template-based PR/MR.

```mermaid
flowchart TD
    Start([Start: /ticket]) --> Prep[prepare-workspace]
    Prep -->|ready| Plan[plan + Plannotator]
    Prep -->|retry| Prep
    Prep -->|blocked| Pause[$pause]

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|workspace-refresh| Prep
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|passed| Pub[publish]
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver

    Pub -->|published| Done([$done])
    Pub -->|retry| Pub
    Pub -->|blocked| Pause
```

---

## 3. `/jira` — Epic & Story Creation
Normalizes input, verifies Jira issue types and field metadata, approves an Epic/Story creation plan in Plannotator, and creates the hierarchy.

```mermaid
flowchart TD
    Start([Start: /jira]) --> Draft[draft]
    Draft -->|ready| Plan[plan + Plannotator]
    Draft -->|retry| Draft
    Draft -->|blocked| Pause[$pause]

    Plan -->|approved| Create[create]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Create -->|ready| Done([$done])
    Create -->|retry| Create
    Create -->|blocked| Pause
```

---

## 4. `/investigate` — Evidence & Findings
Retrieves scope/Jira context, gates scope through Plannotator, investigates facts/root causes, and validates findings before writing report.

```mermaid
flowchart TD
    Start([Start: /investigate]) --> Ret[retrieve + Plannotator]
    Ret -->|approved| Inv[investigate]
    Ret -->|changes-requested| Ret
    Ret -->|retry| Ret
    Ret -->|blocked| Pause[$pause]

    Inv -->|ready| Val[validate]
    Inv -->|retry| Inv
    Inv -->|blocked| Pause

    Val -->|approved| Done([$done])
    Val -->|gaps| Inv
    Val -->|retry / blocked| Val
```

---

## 5. `/mr-review` — Hosted Code Review
Fetches MR/PR context and discussions, drafts an evidence-based review with proposed inline comments for Plannotator review, publishes comments, and verifies published state.

```mermaid
flowchart TD
    Start([Start: /mr-review]) --> Fetch[fetch]
    Fetch -->|fetched| Review[review + Plannotator]
    Fetch -->|blocked| Pause[$pause]

    Review -->|approved| Pub[publish]
    Review -->|changes-requested| Review
    Review -->|blocked| Pause

    Pub -->|published| Ver[verify]
    Pub -->|blocked| Pause

    Ver -->|verified| Done([$done])
    Ver -->|failed| Pub
    Ver -->|retry / blocked| Ver
```

---

## 6. `/mr-comment` — Review Comment Fixes
Fetches unresolved review discussions, checks out the branch, plans code fixes and discussion replies for Plannotator approval, implements fixes, verifies, and publishes commits + replies.

```mermaid
flowchart TD
    Start([Start: /mr-comment]) --> Fetch[fetch]
    Fetch -->|ready| Checkout[checkout-source]
    Fetch -->|retry| Fetch
    Fetch -->|blocked| Pause[$pause]

    Checkout -->|ready| Plan[plan + Plannotator]
    Checkout -->|retry| Checkout
    Checkout -->|blocked| Pause

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|ready| Del[deliver]
    Ver -->|no-actions| Done([$done])
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver

    Del -->|published / no-actions| Done
    Del -->|retry| Del
    Del -->|superseded / blocked| Pause
```

---

## 7. `/sprint-triage` — Support Ticket Triage & Knowledge Base
Collects OpsBot/Slack ticket threads and drafts redacted records in step handoffs, stores complete ledger and draft content in the Plannotator plan artifact, then checks out & binds KB repo only after approval to write report + ledger + index, verify, and publish to GitLab & Confluence.

```mermaid
flowchart TD
    Start([Start: /sprint-triage]) --> Collect[collect]
    Collect -->|ready| Draft[draft]
    Collect -->|retry| Collect
    Collect -->|blocked| Pause[$pause]

    Draft -->|ready| Plan[plan + Plannotator]
    Draft -->|retry| Draft
    Draft -->|blocked| Pause

    Plan -->|approved| Checkout[checkout]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Checkout -->|ready| Imp[implement]
    Checkout -->|retry| Checkout
    Checkout -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|ready| Pub[publish]
    Ver -->|failed| Imp
    Ver -->|retry| Ver
    Ver -->|blocked| Pause

    Pub -->|ready| Conf[confirm]
    Pub -->|retry| Pub
    Pub -->|blocked| Pause

    Conf -->|ready| Done([$done])
    Conf -->|retry| Conf
    Conf -->|blocked| Pause
```

