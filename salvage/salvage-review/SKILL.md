---
name: salvage-review
description: >-
  Reads the salvage-manifest from salvage-explore and dispatches one subagent
  per FUNCTIONAL_MODULE to assess accuracy and correct the record. Use when
  the user names salvage-review, wants the salvage-manifest checked, or
  before salvage-operation.
disable-model-invocation: true
---

# Salvage Review

Take the salvage-manifest written by `salvage-explore`. Dispatch one subagent for every FUNCTIONAL_MODULE. Each subagent assesses the accuracy of that FUNCTIONAL_MODULE's record against SOURCE_REPO and returns corrections. You merge those corrections into the salvage-manifest.

Do not change product code. Do not rediscover the whole repo. Do not move code.

## Terms

- **SOURCE_REPO**: the codebase being salvaged. Same resolution as `salvage-explore` (workspace git top unless the user names a path).
- **SALVAGE_MANIFEST**: `.SALVAGE/salvage-manifest.md` at SOURCE_REPO root. Required.
- **FUNCTIONAL_MODULE**, **SEAM**, **SEAM_SHAPE**: as in the salvage-manifest. A folder name is not a module.

If the salvage-manifest is missing, stop. Tell the user to run `salvage-explore` first.

## Dispatch

Read the salvage-manifest in full. For every FUNCTIONAL_MODULE listed under Modules, launch one Task subagent (`subagent_type`: `explore`, `model`: `inherit`). Launch them in parallel in a single turn.

The parent owns the salvage-manifest. Subagents must not write `.SALVAGE/salvage-manifest.md` (concurrent edits will collide).

Each prompt must include:

- SOURCE_REPO as an absolute path
- That FUNCTIONAL_MODULE's full record copied from the salvage-manifest
- The Structure notes that mention this module or its SEAMs
- These instructions:

```
You own one FUNCTIONAL_MODULE. Verify its salvage-manifest record against SOURCE_REPO.

Check:
- It is a real cluster of behavior, not a folder name
- Identity / path still exists
- Responsibility is accurate
- Inbound / outbound deps match the code
- Coupling notes name the edges a later cut would hit
- Each named SEAM exists; SEAM_SHAPE matches how the boundary is built
- Proof (tests, fixtures, golden files) exists, or "none" is honest
- Nothing in this record is invented

Correct the record if needed. You may shrink, split, or rename this module, add or drop its SEAMs, or declare it is not a FUNCTIONAL_MODULE. Do not hunt unrelated modules. Do not change product code.

Return exactly:

## Verdict
accurate | corrected | not-a-module

## Corrected record
(the full module record in salvage-manifest field shape, or omit if not-a-module)

## What changed
(bullet list, or "none")
```

Trust the subagent outputs. Do not re-do their file reads unless two subagents contradict each other on a shared SEAM — then keep the more specific description and tell the user.

## Merge

Rewrite `.SALVAGE/salvage-manifest.md`:

1. Replace each module section with the subagent's corrected record.
2. Drop modules whose verdict is `not-a-module`.
3. If a subagent split a module, insert the new records.
4. Refresh Structure so it matches the reviewed modules (relative layout, named SEAMs, pinch points / cycles / god objects).

Tell the user the salvage-manifest is reviewed and ready for `salvage-operation`. Report: modules confirmed, corrected, split, or dropped.

## Do not

- Run the test suite.
- Change product code.
- Re-run `salvage-explore` or invent a second inventory.
- Let subagents edit the salvage-manifest.
- Extract or move code (that is `salvage-operation`).
- Skip a listed FUNCTIONAL_MODULE.
