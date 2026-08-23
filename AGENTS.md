# Global Agent Rules

Produce minimal-diff, evidence-backed changes adhering to local repository conventions.

## Core Guiding Principles

### 1. Grounding & Evidence
- **Grounding**: Always capture branch, `HEAD`, and `git status --short`. Preserve unrelated checkouts and changes.
- **Claims Taxonomy**:
  - `FACT`: Direct source cited (`path:line` or tool output + timestamp).
  - `HYPOTHESIS`: Confidence level + explicit falsifier.
  - `UNKNOWN`: Next check required to verify.
- **Search**: Use `rg` or `rg --files` (never `find`). For versioned APIs/libraries, use Context7 (`resolve-library-id` -> `query-docs`).
- **URLs & generated prose**: Before emitting any URL in any workflow output, validate its syntax and that it resolves to the intended observed resource; never infer a URL from text, line references, IDs, or labels. Omit an unverified link and state that it could not be verified. Write comments and replies as concise, natural, context-specific human prose—never placeholders, fabricated wording, or mechanical templates.

### 2. Planning (Read-Only)
- **Drafting Location**: Draft plans to `~/.plannotator/plans/` (or `./PLAN.md`).
- **Plannotator Gate Protocol**:
  - Submit the **complete Markdown text content** directly into the `artifact` parameter on `submit`. Never submit just a file path string.
  - Keep plans under 60 lines unless detailed schema/diff appendices are required: goals, non-goals, verified files/symbols, test mapping, and risks.
  - Never edit code before Plannotator approval.

### 3. Implementation & Verification
- **One Writer**: Implement the smallest coherent change using TDD (prove red -> green).
- **Independent Verification**: Run focused checks first, then required test/lint suites. Report exact command outputs.
- **Safety**: Never push, commit, merge, or mutate external services without explicit user authorization. Never print secrets.

### 4. Communication
- **Chat**: Ultra-terse, caveman style (exact technical terms, zero filler).
- **Plans, Contracts, & Warnings**: Full, unambiguous professional language.

## Progressive Disclosure & Skills

| Domain | Resource / Skill |
|---|---|
| Skill Orchestration | `using-superpowers` |
| Worktree Isolation | `using-git-worktrees` |
| Code Standards & TDD | `coding-standards`, `test-driven-development` |
| Verification | `verification-before-completion`, `lint-commands` |
| Jira & Tickets | `jira-ticket` |
| Production & Incident Triage | `start-triage`, `start-on-call`, `grafana-logs` |
| Subagents & Delegation | `cavecrew`, `subagent-driven-development` |
| Concise Commits & Review | `commit-format` |

