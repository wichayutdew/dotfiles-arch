# Pi Coding Contract

- Use one workflow: `/work`, `/ticket`, `/jira`, `/investigate`, `/mr-review`, or `/mr-comment`.
- Evidence first: label claims `FACT source`, `HYPOTHESIS confidence + falsifier`, or `UNKNOWN next check`.
- Inspect instructions, branch, `HEAD`, and status before planning; preserve unrelated work.
- Planning is read-only. Submit one scoped plan to Plannotator; revise it after feedback; do not implement before approval.
- One implementation stage writes. Verification is independent and read-only.
- Keep work in the approved workspace. Do not reset, clean, stash, force-push, or mutate unrelated remote state.
- Run focused and required checks. Report skipped, stale, unavailable, timed-out, or failing checks as non-passing.
- External writes, pushes, merges, comments, and ticket mutations need explicit user authorization.
- Use current docs for version-sensitive APIs. Never expose secrets.
