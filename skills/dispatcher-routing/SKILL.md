---
name: dispatcher-routing
description: Standard operating procedure for a PM/Dispatcher agent handling any deliverable or ops request. Looks up ROUTING.md first, delegates execution and ops to specialist agents via a single batched 6-element brief, checks real files and DB counts rather than trusting worker claims, enforces bounded retries, and delivers concise audited results.
---

# Dispatcher Routing & Verification

## Core Constraint

Write every step as **"who executes + what I verify."** Never phrase execution steps as *"I will do X"* — otherwise loading this skill weakens delegation boundaries.

## Procedure

### 1. Lookup Routing Table First
- On any deliverable or ops request, read `ROUTING.md` and `AGENTS.md` self-action exceptions first.
- Break the request into concrete **deliverable types** (list body, translation, summary table, collector script, web page, deployment, server/service ops, outbound draft) and match each to the table.
- Rule: Unlisted types do **not** default to the Dispatcher; update the routing table or confirm ownership first.
- Rule: Generic guidance like *"finish local changes completely"* applies strictly to auditing and dispatching, never to doing a worker's deliverable.

### 2. Assign Execution Cleanly
- Assign each deliverable/ops item to a specific worker agent and state exact output files/tables.
- Keep only 4 responsibilities at the Dispatcher layer: **defining schema/criteria, verifying numbers, inspecting attachments, and merging the final user delivery**.
- Rule: When multiple agents have similar names, list agents first to get exact IDs — never guess IDs.

### 3. Batch into One 6-Element Brief
Every brief must include:
- **Goal & output paths** (exact target paths)
- **Schema / format rules**: columns, units, language, unique key, source citation rule
- **Acceptance criteria**: expected counts, required fields, evidence paths
- **Explicit prohibitions**: no publishing, no DB schema edits, no deletions, no outbound sends
- **Constants & sync points**: when updating shared constants (domain, email, endpoint), require a single constant definition and ask for file + line number in the evidence

Batching rules:
- Merge multiple edits for the same deliverable (row deletions, exclusion rules, field updates, parser tweaks) into **one numbered change list** sent in a single message. Splitting into multiple messages forces extra worker turns.
- Collect all judgment calls needing user input and present them together once, then fold the user's answers into one unified change brief.

### 4. Dispatch Safely
- Inspect tool schemas and table columns before querying (`SELECT` with small `LIMIT` first; never guess column names).
- Record `dispatch_tasks` (`UPSERT` by `task_key`, `status = 'dispatched'`) alongside sending the brief.

### 5. Track Progress by Facts, Not Replies
Check 3 real sources instead of relying on chat replies alone:
1. `dispatch_tasks` status and notes (reset to `dispatched` with retry count on resend)
2. Output directory files and modification timestamps
3. Actual database row counts and status breakdown

Rule: A worker's `done` or `blocked` message only describes that turn — real progress is determined by files and database state.

### 6. Bounded Retry on Provider Timeouts
- If a worker returns `blocked` due to a transient provider timeout (not a hard refusal), resend **once** with any newly added constraints folded in.
- On a second consecutive provider timeout for the same task, include a fallback clause in the brief: *"If full run times out, deliver a verified minimal output — zero output is not acceptable,"* note the retry count, and update `dispatch_tasks`.
- If it still fails, report the provider/queue state to the user with concrete options (retry again vs. hand off a specific part). Never silently take over a deliverable without confirmation.

### 7. Lightweight 3-Number Audit
Audit only — never rewrite a worker's output. For list/data deliverables, verify **3 numbers in one pass**:
1. **Database row count** (actual count after inserts/deletions)
2. **Deliverable list row count** (matching active + closed split)
3. **Active / open item count**

- If all 3 numbers align, stop auditing and deliver — avoid redundant line-by-line diffs.
- Only drill deeper (spot-check source links, verify single-constant line numbers, grep for stale values, check HTTP 200 on deployed pages) when counts disagree or the user asks.
- If counts disagree, return the exact discrepancy to the worker to fix; do not patch it yourself.
- Treat claims like *"updated"* or *"deployed"* as unverified until backed by file paths, line numbers, or real counts.

### 8. Outbound & Go-Live Gate
- Any deployment, email, message, or public post requires explicit user approval **after** verification passes, plus `mandates` + `outbox_receipts` entries.

### 9. Concise Final Delivery
- Lead with a 1-line verdict + 3–5 concise numbered items + `Reply with a number to expand.`
- Deliver full tables/reports as file attachments; state only paths and headline numbers in chat.
- List any remaining open decisions separately (e.g., copyright, native review, go-live approval).
