# OpenBot Adapter Guide / OpenBot 接入指南

[English](#english) | [简体中文](#简体中文)

---

## English

**OpenBot** maps 1-to-1 to this kit out of the box because it natively provides workspace `AGENTS.md`, a shared SQLite database, agent-to-agent messaging (`openbot.send_message`), concurrent sub-tasks (`openbot.start_task`), routines, and file attachments.

### 1. File Placement
Place the prompt trio in your Dispatcher agent's working directory:
```text
<OpenBot>/Agents/<dispatcher-agent-id>/
├── AGENTS.md       <- copy from prompts/en/AGENTS.md (or zh-CN)
├── DISPATCH.md     <- copy from prompts/en/DISPATCH.md
└── ROUTING.md      <- copy from prompts/en/ROUTING.md (customize worker names)
```

### 2. Initialize the 4 Shared Tables
Run `schemas/audit_tables.sql` via `openbot.execute_data` (one statement per call or via your OpenBot shared DB workflow). Every agent can read shared tables; keep `dispatch_tasks`, `mandates`, `outbox_receipts`, and `shadow_actions` owned by the Dispatcher.

### 3. Tool Mapping in OpenBot
| Kit Concept | OpenBot Tool |
|---|---|
| Discover specialist roster | `openbot.list_agents` |
| Cross-agent dispatch | `openbot.send_message` (`expectsReply: true`) |
| Same-agent parallel sub-task | `openbot.start_task` (respect host `taskLimit`, default 4) |
| Audit ledgers read/write | `openbot.query_data` / `openbot.execute_data` |
| Human confirmation / outbound preview | `openbot.ask_ui` (confirm card) / `openbot.ask_user` |
| File-first delivery | `openbot.attach_files_to_response` |
| Silent scheduled runs (no news) | `openbot.routine_no_update` |

### 4. Register Local Skills
Use `openbot.create_skill` (or place under `<dispatcher-workspace>/.agents/skills/`) to load `skills/dispatcher-routing/` and `skills/parallel-split/`.

### 5. Recommended Routine Pattern
Set specialist agents' scheduled routines to forward their structured summary back to the Dispatcher. The Dispatcher verifies the 3 numbers (DB rows, list rows, active rows), attaches the shared deliverable file, and replies with a single verdict line — or calls `openbot.routine_no_update` when nothing changed.

---

## 简体中文

**OpenBot** 与本套件天然 1:1 契合：原生提供工作区 `AGENTS.md`、共享 SQLite 数据库、跨 Agent 派活（`openbot.send_message`）、同 Agent 并行子任务（`openbot.start_task`）、定时任务与附件交付。

### 1. 文件放置
将提示词三件套放到调度员 Agent 工作目录根路径：
```text
<OpenBot>/Agents/<dispatcher-agent-id>/
├── AGENTS.md       <- 复制自 prompts/zh-CN/AGENTS.md
├── DISPATCH.md     <- 复制自 prompts/zh-CN/DISPATCH.md
└── ROUTING.md      <- 复制自 prompts/zh-CN/ROUTING.md（按你的团队改执行层名称）
```

### 2. 初始化四张共享治理表
通过 `openbot.execute_data` 执行 `schemas/audit_tables.sql` 中的四张建表语句。`dispatch_tasks`、`mandates`、`outbox_receipts`、`shadow_actions` 均由调度员统一写入维护。

### 3. OpenBot 工具映射
| 套件机制 | OpenBot 对应工具 |
|---|---|
| 查看执行层名单 | `openbot.list_agents` |
| 跨 Agent 派活 | `openbot.send_message`（`expectsReply: true`） |
| 同 Agent 并行子任务 | `openbot.start_task`（注意宿主 `taskLimit`，默认 4） |
| 读写治理账本 | `openbot.query_data` / `openbot.execute_data` |
| 人工确认 / 外发预览 | `openbot.ask_ui` / `openbot.ask_user` |
| 附件交付清单与报告 | `openbot.attach_files_to_response` |
| 定时无新增静默 | `openbot.routine_no_update` |

### 4. 装载两项本地技能
通过 `openbot.create_skill`（或放进调度员 `.agents/skills/`）装载 `skills/dispatcher-routing/` 与 `skills/parallel-split/`。

### 5. 定时汇总推荐接法
执行层 Agent 定时跑完后把回执交给调度员；调度员核对三个数字（表行数、清单条数、在途/有效条数）后附文件给用户，无新增且无异常时调用 `openbot.routine_no_update` 不打扰用户。
