---
name: parallel-split
description: Splits a single user message containing multiple independent instructions into parallel cross-agent dispatches or concurrent sub-tasks, preventing unnecessary serial bottlenecks while guarding against file/database write conflicts.
---

# Multi-Instruction Parallel Splitting

## Steps

1. **Extract & classify every instruction first.**
   List each item's goal, deliverable, touched files/tables, dependencies, and owning agent. Mark strict `A -> B` dependencies as **serial**; mark everything else as **parallel candidates**. *(Pitfall: treating a multi-part message as one queue forces serial execution inside a single turn.)*

2. **Check write conflicts before parallelizing.**
   Map which files, folders, and DB tables/keys each task writes to. Never run two tasks in parallel if they modify the same file or a table without a unique key. Read-only tasks always parallelize safely.

3. **Choose the right concurrency tier.**
   - **Tier 1 (Preferred)**: Cross-agent dispatch — each specialist agent runs in its own isolated context (true parallelism).
   - **Tier 2**: Same-agent concurrent sub-tasks — for independent work staying with the Dispatcher, within the host's concurrency limit (check your host's `taskLimit` / `concurrentTurns` settings first).
   - **Tier 3**: Serial execution — only when strict data dependency or write conflict exists.

4. **Lock hard boundaries in every parallel brief.**
   Specify exact inputs, output paths, acceptance criteria, and off-limits files/tables. Sub-tasks often share a workspace and cannot see the parent chat — vague briefs cause silent overwrites.

5. **Respect dependency waves.**
   Launch all dependency-free tracks immediately. Launch dependent tracks only after upstream artifacts are verified.

6. **Send an immediate dispatch receipt.**
   Tell the user right away: how many parallel tracks launched, what each owns, and which items wait serially (with reason).

7. **Audit every track before merging.**
   Verify each output file, path, and DB row individually. Never treat a silent or empty track as completed.

8. **Pause before any outbound action.**
   Parallelism amplifies accidental sends. Always require explicit user approval (plus `outbox_receipts`) before external sends, posts, or deploys.

## Output Checklist

- [ ] Every user instruction has an explicit owner (worker agent / sub-task / serial wave).
- [ ] No two concurrent tasks write to the same file or keyless table.
- [ ] Concurrent sub-tasks do not exceed host concurrency limits.
- [ ] User received an immediate receipt showing parallel vs. serial tracks.
- [ ] Every track's deliverable is verified by file path, table count, or status before final merge.
- [ ] Skip splitting when the user only gave a single cohesive task.
