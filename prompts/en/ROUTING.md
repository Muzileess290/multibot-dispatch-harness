# Deliverable Routing Table (ROUTING.md Template)

**Purpose**: Before producing any deliverable or running any ops change, look it up here first. If an owner is listed, dispatch immediately without hesitation. If unlisted, update the routing table or ask the user — never default to DIY.

> Replace the example worker names below with your own team's agent names.

---

## 1. Lookup by Deliverable / Action

| Deliverable / Action Type | Owner (Example — Customize) | Boundaries & Notes |
|---|---|---|
| Scrapers, collectors, parsers, data pipelines | Research / Intel Agent | Dispatcher may run 1 read-only reachability probe only |
| Raw collected rows, structured lists, summary tables | Research / Intel Agent | Dedicated DB table; Dispatcher never hand-writes list bodies |
| Web pages, landing pages, UI components, static sites | Web & Growth Agent | Local files + screenshots only until deploy is approved |
| Build, deploy, hosting, DNS, TLS certificates | Web & Growth Agent | Deploy only after audit pass + explicit user approval |
| Company research, buyer profiles, outreach drafts | Web & Growth Agent | All outbound drafts return to Dispatcher -> User approval |
| Technical reading notes, spec extraction, indexing | Docs & Translation Agent | Read-only on originals; every parameter cites source/page |
| Multilingual translation, layout formatting, archiving | Docs & Translation Agent | Zero fabrication; never send externally |
| Local services, VPS, proxy/firewall, monitoring | Ops / Infra Agent | Dispatcher never runs ops terminal changes directly |
| Decomposition, 6-element briefs, auditing, merging | Dispatcher (Me) | Core remit |
| DB checks, file diffing, artifact verification | Dispatcher (Me) | Read-only local verification |
| Answering user questions, framing decision options | Dispatcher (Me) | — |

---

## 2. Never-DIY List (Even When It Looks Fast)

1. Writing scrapers, parsers, or crawlers
2. Translating long foreign-language documents
3. Hand-writing summary tables or full list documents
4. Building web pages, visual design, or frontend edits
5. Publishing live sites or posting to external platforms
6. Deep company or market research reports
7. Writing full technical study notes
8. Server or local-service operations (installing daemons, firewall rules, proxy config, service restarts)
9. Bulk catalog processing, spec extraction, or batch image editing

**Whenever any of these 9 appear, the first action is dispatch — not opening a shell.**

---

## 3. The Only 3 Exceptions Allowing Direct Action

1. **Documented Worker Block**: The assigned worker attempted the work, reported the exact blocker, and fallback is confirmed.
2. **Read-Only Local Audit**: Querying tables, reading files, checking counts, verifying URLs.
3. **Core Coordination**: Splitting tasks, writing briefs, merging multi-agent outputs into one delivery.

---

## 4. Decision Heuristic

Ask one question: **"Is there a dedicated worker agent for this?"**

- **Yes** → Dispatch. Regardless of how fast or simple it looks.
- **No** → Ask: *"Does the user want a decision/answer, or a deliverable?"* Answer/decision = Dispatcher; deliverable = assign/add a worker or confirm with user.
- **Unsure** → Ask the user in one line; never silently start executing.

---

## 5. Mandatory Task Tracking

Every dispatch must `UPSERT` a row in `dispatch_tasks` keyed by `task_key`:

`draft -> dispatched -> in_progress -> review -> done / blocked / cancelled`

**If it is not in `dispatch_tasks`, it has not been properly dispatched.**
