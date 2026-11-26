# Grok Bot Adapter Guide / Grok Bot 接入指南

[English](#english) | [简体中文](#简体中文)

---

## English

**Grok Bot** setups typically combine custom system instructions, scheduled/external intel feeds, and either tool webhooks or a local companion runner. Because Grok Bot may not natively manage multiple persistent local sub-agents, use this kit in **Hub-and-Spoke** or **Handoff** mode.

### 1. System Prompt / Custom Instructions
Load a condensed version of `prompts/en/AGENTS.md` + `prompts/en/ROUTING.md` into your Grok Bot's System Prompt / Project Instructions, and attach `DISPATCH.md` as a reference document in the project knowledge base.

### 2. Two Practical Operating Modes
- **Mode A — Grok Bot as Dispatcher (with Webhook / MCP Workers)**:
  - Wire `ROUTING.md` entries to MCP servers or webhook endpoints (each endpoint = one specialist worker).
  - Connect a lightweight SQLite / Supabase / Notion MCP tool to back the 4 tables from `schemas/audit_tables.sql`.
  - Keep outbound actions behind an explicit user confirmation step + `outbox_receipts` check.
- **Mode B — Grok Bot as Upstream Research / Intel Worker**:
  - Let Grok Bot run web/X-native discovery on a schedule and emit a structured **6-element handoff report** (sources, timestamps, counts, unverified flags) to your local Dispatcher (OpenBot or OpenManusBot).
  - The local Dispatcher audits every link/count against local tables before anything reaches the user.

### 3. Prompt Adjustments for Grok Bot
- Keep the **Communication Contract** (Verdict first, 3–5 bullets, 1 question max) verbatim — it prevents chatty drift.
- Replace SQL tool names with your connected storage tool or structured handoff block (`task_key`, `status`, `evidence`, `unverified_items`).
- Enforce **Zero Fabrication**: if a source is behind a login or rate limit, output `unverified` explicitly instead of guessing.

---

## 简体中文

**Grok Bot** 常见形态是自定义指令 + 联网/社交搜索 + Webhook/MCP 工具（或与本机 Agent 协同）。根据是否自挂执行工具，推荐两种接法：

### 1. 提示词注入方式
将 `prompts/zh-CN/AGENTS.md` 与 `prompts/zh-CN/ROUTING.md` 写入 Grok Bot 的系统指令（Custom Instructions / Project Instructions），将 `DISPATCH.md` 放入知识文件作为派活口径参考。

### 2. 两种落地模式
- **模式 A：Grok Bot 当调度员（接 MCP / Webhook 执行层）**
  - 将 `ROUTING.md` 中的每个执行角色映射到对应的 MCP 工具或 Webhook 服务。
  - 接一个轻量 SQLite / 云数据库 MCP 落地 `schemas/audit_tables.sql` 的四张表。
  - 所有外发动作强制「先预览确认 + 查 `outbox_receipts` 去重」。
- **模式 B：Grok Bot 当上游情报执行层（向本地调度员交接）**
  - 利用 Grok 强项做实时公开信息/社媒检索，定时输出带「来源链接、采集时间、条数、未核验项标注」的结构化简报。
  - 交回本地 OpenBot / OpenManusBot 调度员做三数字门审、入库去重与附件交付。

### 3. 适配要点
- 原样保留 **回答格式协议**（结论在前、3–5 条编号、一次只问 1 个问题），显著降低废话率。
- 严格保留 **零编造与未核到实标**：遇登录墙或 403 如实标注「未核到」，绝不硬编字段。
