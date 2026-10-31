# Stage: traffic-evidence

Use the invoking request, requested scope and complete research/source evidence, inline or through readable full-content references.

---

Capture or verify traffic/load/capacity evidence for the research draft. Do not write or publish to the destination(s).

Input: `the invoking request`
Approved scope: `the requested scope artifact and approval evidence`
Draft and captured results: `{{last.summary}}`

## Applicability and access

- When traffic/load/capacity is outside scope, return ready with an explicit not-applicable result and the complete draft unchanged. Do not run queries or add a gate.
- Otherwise use the available authorized observability or analytics sources: a metrics/logs API, dashboard, database, exported aggregate dataset, or suitable connector. Discover actual capabilities, schema and permissions; no particular vendor or internal service is required.
- Reuse valid captured results with provenance. Execute only missing/stale measurements. Missing optional telemetry/rendering is a limitation; decision-critical unavailable evidence is a factual blocker, not a fabricated observation.
- Run bounded read-only aggregate queries. Respect resource guards; narrow a failed query rather than repeatedly retrying an expensive scan. Do not export raw customer identifiers or sensitive event payloads.

## Backend workload

1. Locate existing instrumentation and verify datasource, metric type, units, route, environments/regions and customer versus test/mirror traffic. Code identifies the emitter; executed aggregates establish volume. Do not invent a metric for a proposed endpoint.
2. Use aggregation appropriate to the source: rates/increases for cumulative counters, supported count/average/quantile semantics for histograms, or verified log/event counts. Time-series cardinality is not request volume.
3. Query a bounded complete window and record requested/returned timestamps, timezone, interval, lookback and warnings. Cover relevant deployments without cherry-picking a low-volume environment.
4. Use non-overlapping buckets for totals. Average rate uses the full declared window in seconds, not only nonempty buckets. Missing telemetry is not measured zero.
5. Compute combined peaks by summing aligned buckets before taking the maximum; never sum independent maxima.
6. Name what was counted. Route executions are not unique users, transport success need not equal business success, and response duration/cache hits do not prove freshness.

## Consumer exposure

1. Trace the relevant feature, analytics definition and actual emitter. Verify exact event/element, action, platform/variant, rollout gates and repeated emission behavior. A DOM label is not necessarily an analytics event identity.
2. Discover the actual dataset/schema, partition/timestamp fields and stored values before writing SQL or filters. Begin with a narrow completed partition/window.
3. Execute aggregates for the intended exposure action. Separate clicks, visits and child impressions unless the model explicitly includes them. Do not relabel repeated events as unique users.
4. Aggregate in the data source; align time buckets before calculating combined peak. Check join cardinality so dimension joins do not multiply events.
5. Empty results mean no matching rows in that source/window/filter. Check deployment, instrumentation and gating before concluding there is no usage.

## Conditional load model

- Keep observed backend requests, exposure events and modeled extra requests distinct.
- State reads per fetch/render, eligibility, experiment allocation, rollout expansion, caching, batching, refetches and retries. Fetch-before-visibility and repeated visibility can break a one-event/one-request assumption.
- Do not multiply one batch read by its number of returned items. Request-local deduplication does not establish cross-service deduplication.
- Keep future consumers and missing telemetry as explicit budgets/unknowns. Do not invent audience percentages, demand series or capacity headroom.
- State whether backend and analytics windows/timezones align. Independent averages do not prove a jointly observed peak or available capacity.

## Visual proof

- Generate links only from verified resource identities, queries, variables and time ranges. A returned image may be an error page; inspect its content.
- Verify read, render and create/write access separately. Readable metadata does not grant mutation authority.
- Create/update a dashboard only within explicitly approved publication authority and available write access; read it back before claiming success.
- Label local charts and importable drafts as local/unpublished. Missing instrumentation stays a gap, not a fabricated zero curve.

## Required proof record

For each numeric claim, retain:
- Status: measured, derived, modeled, unavailable or failed; quantity, units and meaning.
- Identity: instrumentation/emitter revision and datasource or dataset.
- Selection: exact route/event/action, environments, platforms, variants and other filters.
- Window: start/end, timezone/partitions, step/lookback and requested versus returned coverage.
- Execution: exact query or export operation, original aggregate result, warnings/errors and missing-data handling.
- Derivation: total, average denominator, aligned-bucket peak, model multipliers and assumptions.
- Visual: verified link/graph and window, or explicit local/unpublished/unavailable status.

Put the result and key filters/derivation beside the claim. Preserve complete raw aggregates in an approved evidence artifact/reference; a detached screenshot or link alone is insufficient.

`ready`: complete draft and measured/modelled proof reconciled, or not-applicable result with unchanged complete draft.
`refresh`: evidence materially changes the investigation; update the working plan and research/report draft before the next user review.
`handoff`: transient evidence work remains; retain captured results and exact remaining queries.
`blocked`: decision-critical evidence/access/authority cannot be obtained safely.

## Required response

# Completed
<complete reconciled draft/reference, applicability, proof records, source/query/results, derivations, visual status and limitations>

# Remaining
<exact remaining evidence work, or None.>
