-- MultiBot Dispatch Harness — SuperAgent Governance & State Ledgers (SQLite)
-- 4 core tables: dispatch_tasks, mandates, outbox_receipts, shadow_actions
-- All tables enforce natural unique keys for idempotent UPSERT writes.

-- 1. Task Dispatch Ledger (Single Source of Truth for Delegated Work)
-- State machine: draft -> dispatched -> in_progress -> review -> done | blocked | cancelled
CREATE TABLE IF NOT EXISTS dispatch_tasks (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  task_key       TEXT NOT NULL UNIQUE,          -- e.g. 'intel-daily-20261126' or 'web-landing-v2'
  title          TEXT NOT NULL,
  requester      TEXT NOT NULL DEFAULT 'user',
  brief          TEXT NOT NULL,                 -- 6-element dispatch brief summary
  owner_agent_id TEXT,
  owner_name     TEXT,
  status         TEXT NOT NULL DEFAULT 'draft'
                 CHECK (status IN ('draft','dispatched','in_progress','review','done','blocked','cancelled')),
  acceptance     TEXT,                          -- Measurable verification criteria
  deliverable    TEXT,                          -- Expected file path(s), URL(s), or table(s)
  shadow         INTEGER NOT NULL DEFAULT 0,    -- 1 = shadow/dry-run task, 0 = live
  created_at     TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at     TEXT NOT NULL DEFAULT (datetime('now')),
  closed_at      TEXT,
  note           TEXT                           -- Blocker reason, retry count, or audit proof
);

CREATE INDEX IF NOT EXISTS idx_dispatch_tasks_status ON dispatch_tasks(status);
CREATE INDEX IF NOT EXISTS idx_dispatch_tasks_owner  ON dispatch_tasks(owner_name);

-- 2. Authorization Mandate Ledger
-- Only 'direct_request' and 'followup_confirmed' count as live execution authorization.
-- 'rule_allowed' and 'inferred' are candidates only and require user confirmation before risky execution.
CREATE TABLE IF NOT EXISTS mandates (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  mandate_key    TEXT NOT NULL UNIQUE,          -- e.g. 'deploy-site-20261126'
  requester      TEXT NOT NULL DEFAULT 'user',
  basis          TEXT NOT NULL
                 CHECK (basis IN ('direct_request','followup_confirmed','allowlist','rule_allowed','inferred')),
  scope          TEXT NOT NULL,                 -- Exact authorized action & target boundary
  task_id        TEXT,                          -- Optional reference to dispatch_tasks.task_key
  granted_at     TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at     TEXT,
  revoked_at     TEXT,                          -- Non-null means immediately invalid; never reuse
  revoked_reason TEXT,
  note           TEXT
);

CREATE INDEX IF NOT EXISTS idx_mandates_active ON mandates(revoked_at, expires_at);

-- 3. Outbox Receipts (Write-Before-Send Idempotency Ledger)
-- Always INSERT a row (status='queued') BEFORE sending any external message, email, post, form, or payment.
-- Update to 'sent' or 'failed' immediately after. Never log a failed send as 'sent'.
CREATE TABLE IF NOT EXISTS outbox_receipts (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  dedupe_key     TEXT NOT NULL UNIQUE,          -- Deterministic idempotency key (channel+recipient+payload)
  task_id        TEXT,                          -- Reference to dispatch_tasks.task_key
  target_kind    TEXT NOT NULL,                 -- e.g. 'email', 'im', 'webhook', 'publish', 'payment'
  target         TEXT NOT NULL,                 -- Recipient / endpoint / site name
  body_hash      TEXT NOT NULL,                 -- SHA-256 of outbound content
  status         TEXT NOT NULL DEFAULT 'queued'
                 CHECK (status IN ('queued','sent','failed','cancelled')),
  created_at     TEXT NOT NULL DEFAULT (datetime('now')),
  sent_at        TEXT,
  error          TEXT,
  note           TEXT
);

CREATE INDEX IF NOT EXISTS idx_outbox_status ON outbox_receipts(status);

-- 4. Shadow Mode Actions (Dry-Run Audit Log for Proactive / Scheduled Behaviors)
-- New routines or agent-initiated actions log what they WOULD do without executing,
-- until the user reviews the log and approves promotion to live mode.
CREATE TABLE IF NOT EXISTS shadow_actions (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  action_key     TEXT NOT NULL UNIQUE,          -- Deterministic key per routine run & intent
  routine        TEXT NOT NULL,                 -- Routine or trigger name
  intent         TEXT NOT NULL,                 -- Why the agent wanted to act
  would_do       TEXT NOT NULL,                 -- Exact action/payload it would have executed
  risk           TEXT NOT NULL DEFAULT 'medium'
                 CHECK (risk IN ('low','medium','high')),
  observed_at    TEXT NOT NULL DEFAULT (datetime('now')),
  reviewed_at    TEXT,
  verdict        TEXT                           -- 'approved_to_live', 'keep_shadow', 'rejected'
                 CHECK (verdict IS NULL OR verdict IN ('approved_to_live','keep_shadow','rejected')),
  note           TEXT
);

CREATE INDEX IF NOT EXISTS idx_shadow_verdict ON shadow_actions(verdict);
