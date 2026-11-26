# OpenManusBot Adapter Guide / OpenManusBot 接入指南

[English](#english) | [简体中文](#简体中文)

---

## English

**OpenManusBot** (OpenManus-based multi-agent bots) separates a **Planning / Orchestrator Agent** from specialized tool-calling **Worker Agents** (browser, shell/code, file, MCP). This kit slots cleanly into the Planner/Orchestrator layer to stop runaway tool loops and enforce SuperAgent-style governance.

### 1. Role Mapping
| Kit Component | OpenManusBot Placement |
|---|---|
| `AGENTS.md` + `ROUTING.md` | Orchestrator / Planner system prompt |
| `DISPATCH.md` (6-element brief) | Sub-agent / Flow task prompt template |
| `schemas/audit_tables.sql` | Local SQLite DB exposed via a Python/MCP `ledger` tool |
| `skills/dispatcher-routing` | Orchestrator planning & post-step verification hook |
| `skills/parallel-split` | DAG / `asyncio.gather` fan-out planner rule |

### 2. Recommended Wiring
1. **Separate Tool Permissions Physically**:
   - Give the **Dispatcher/Orchestrator** only read-only inspection tools, `ledger` SQL tools, and `delegate(worker, brief)` — remove shell/browser write tools from the Orchestrator so the *Never-DIY* rule is enforced by code, not willpower.
   - Give specialist workers (`browser_worker`, `code_worker`, `ops_worker`, `docs_worker`) only the tools for their remit, and **no** outbound email/publish credentials.
2. **Add a Pre-Send Hook for `outbox_receipts`**:
   - Wrap any external-send tool (email, Slack/Feishu/Telegram, GitHub push, deploy) with a middleware check: verify an active row in `mandates` (`revoked_at IS NULL`) and `INSERT OR IGNORE` into `outbox_receipts` before execution.
3. **Add a Shadow-Mode Flag for Scheduled Flows**:
   - Pass `shadow=True` on newly created cron flows so the worker returns its planned action to the Orchestrator, which logs it into `shadow_actions` instead of invoking outbound tools.
4. **Enforce Bounded Retries**:
   - Configure worker timeouts and cap automatic retries at **2** (with the minimal-deliverable clause on retry #2) before escalating cleanly to the user.

---

## 简体中文

**OpenManusBot**（基于 OpenManus 架构的多 Agent 机器人）天然区分 **规划编排器（Planner / Orchestrator）** 与 **工具执行节点（Browser / Code / File / MCP Workers）**。将本套件接入编排层，可以彻底解决工具死循环、越界操作与重复外发问题。

### 1. 架构映射
| 套件组件 | OpenManusBot 落点 |
|---|---|
| `AGENTS.md` + `ROUTING.md` | Orchestrator / Planner 系统提示词 |
| `DISPATCH.md`（六要素简报） | 子 Agent / Flow 派发模板 |
| `schemas/audit_tables.sql` | 本地 SQLite + 轻量 Python/MCP 账本工具 |
| `skills/dispatcher-routing` | 编排前置路由与执行后验收节点 |
| `skills/parallel-split` | 并发 DAG / `asyncio.gather` 拆分规则 |

### 2. 推荐工程化接法
1. **用工具权限把“绝不自己干”写死**：
   - 编排层（调度员）只挂只读核查工具、账本 SQL 工具与 `delegate(worker, brief)`，剥离 Shell 写权限和浏览器操作权限，让路由红线变成硬隔离。
   - 各执行节点按职责最小授权，且不直接持有外发凭据。
2. **给外发工具套一层 `outbox_receipts` 中间件**：
   - 所有发信、群消息、推送、部署工具执行前，先验 `mandates` 未作废且命中授权范围，再写 `outbox_receipts` 去重键，写完再发。
3. **给定时 Flow 加 `shadow` 开关**：
   - 新建定时任务默认 `shadow=True`，只把计划动作写入 `shadow_actions` 不真执行，人工审核通过后再切正式模式。
4. **限制重试次数**：
   - 执行节点超时最多自动重派 **2 次**（第 2 次附最小可核验交付保底条款），仍失败则停止循环并向用户给选项。
