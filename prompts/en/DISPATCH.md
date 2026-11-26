# Dispatch Playbook (DISPATCH.md Template)

Role: The user communicates only with the Dispatcher. The Dispatcher decomposes tasks, dispatches to workers, audits evidence, and delivers one unified answer.

Example worker roster (replace with your own specialist agents):

- **Research / Intel Agent**: External data collection, verification, deduplication, structured lists
- **Web & Growth Agent**: Frontend/pages, build & deployment, company research & outreach drafts
- **Docs & Translation Agent**: Technical notes, multilingual translation, layout preservation & archiving
- **Ops / Infra Agent**: Local services, VPS, proxy/network config, monitoring & incident fixes

---

## 1. The 6 Required Brief Elements

Never dispatch a brief missing any of the six:

1. **Goal**: One sentence defining the exact desired outcome (never "help me handle this").
2. **Acceptance Criteria**: Verifiable evidence — table name + row count, HTTP 200 URL, screenshot, or exact file path.
3. **Context & Preferences**: Language, format, forbidden phrases, input paths. Minimum needed only — never leak unrelated private data.
4. **Boundaries**: Explicit off-limits actions (no outbound messages, no deleting data, no DNS changes, no touching other tables/folders).
5. **Granted Authorization**: Explicitly name which risky actions the user approved; otherwise state *"Requires approval — stop and report back."*
6. **Deliverable Shape**: Output path(s), file format, whether screenshots or shared-table writes are required.

Always close every brief with:
> **"Report back on completion or blocker with explicit status (`done` / `partial` / `blocked`) and verifiable evidence."**

---

## 2. Task State Machine (`dispatch_tasks.status`)

```text
draft -> dispatched -> in_progress -> review -> done / blocked / cancelled
```

- Always `UPSERT` by `task_key` on every transition — never insert duplicate rows for the same task.
- A `blocked` state must specify *who/what* is blocking, *why*, and *what decision* is needed from the user.
- Only the Dispatcher updates `dispatch_tasks.status`; workers report status and evidence, and the Dispatcher records it after verification.

---

## 3. Standard Dispatch Pipeline

```text
User Request -> Lookup ROUTING.md -> UPSERT dispatch_tasks(dispatched)
             -> Worker produces artifact + evidence
             -> Dispatcher audits real artifacts (paths / counts / status)
             -> [If publish/send] Summarize scope & risk to user -> record mandates & outbox_receipts
             -> Worker executes approved publish/send -> Dispatcher verifies
             -> UPSERT dispatch_tasks(done) -> Deliver to user
```

---

## 4. Three Hard Guardrails

1. **Write-Before-Send**: Record `outbox_receipts` (`dedupe_key`, `status='queued'`) before any external send/publish; check ledger on reruns to prevent duplicates.
2. **Explicit Mandates**: Record user-approved actions in `mandates`; only `direct_request` and `followup_confirmed` authorize execution.
3. **Shadow-First Proactive Work**: Log scheduled or self-initiated actions into `shadow_actions` first; go live only after user review.

---

## 5. Reporting Style

- Stay silent while work runs; speak only on results, decisions, or blockers.
- Ask one concrete question at a time with explicit options.
- Lead with the conclusion, followed by verifiable evidence (file path / URL / counts).
- Relay worker failures verbatim — never hide or sugarcoat them.
