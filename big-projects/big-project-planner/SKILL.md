---
name: big-project-planner
description: >-
  Takes a product description and iteratively adds detail until the project is
  actionable, then writes a PROJECT-PLAN. Use when planning a big project,
  turning a product idea into an actionable plan, or before smoketest-stack.
disable-model-invocation: true
---

# Big Project Planner

Take a user's product description and iteratively add more detail until the project is actionable. Then use `smoketest-stack`, which takes a plan and smoke-tests every external dependency.

Do not wait between passes. Keep filling the largest remaining gap until the plan is actionable, then stop.

If there is no product description, stop and ask. Do not invent a product.

## Actionable

Stop iterating only when all of these are true:

- Problem, user, and success are explicit.
- MVP / first slice is bounded; later work is named as later.
- Stack is named.
- Every external dependency is named with purpose and a smoke check that would prove it.
- Constraints and non-goals are explicit.
- First implementation steps are ordered and small enough to start.

Prefer the user's words. When they did not specify a planning detail, pick a concrete default that fits the product, mark it as a **default**, and keep going. Do not pause for confirmation.

## Cycle

Repeat until actionable:

1. Restate the product as currently known (short).
2. Choose the **one** largest gap that still blocks actionability (wrong, missing, or too vague to build or to smoke-test).
3. Fill only that gap. Add the least detail that unblocks.
4. Re-evaluate.

Fill gaps in this order when several are open: product intent → first slice → surfaces → data → stack → external dependencies → constraints → first build sequence.

Do not dump a full PRD in one pass. Do not add detail that does not unblock action.

## Deliverable

Write `plan/PROJECT-PLAN.md` in the project (create `plan/` if needed):

```markdown
# Project Plan: <product>

## Product
- **Description**:
- **User / job**:
- **Success**:
- **Non-goals**:

## First slice
- In scope now
- Explicitly later

## Surfaces
- Clients, APIs, jobs, devices

## Data
- Core entities and relationships (not a full schema)

## Stack
- Language, runtime, host, major libraries

## External dependencies
For each:
- **Name**:
- **Purpose**:
- **Kind** (API / DB / queue / auth / package / image / cloud / device):
- **Smoke check** (lightest live proof it exists and is reachable):
- **Config / credentials** (env vars, accounts — not secret values):

## Constraints
- Platform, license, budget, time, compliance

## Defaults assumed
- Planning choices filled in because the user did not specify them

## First build sequence
- Ordered steps for the first slice
```

Tell the user the plan is ready for `smoketest-stack`. Do not start building. Do not smoke-test.

## Do not

- Implement the product.
- Smoke-test dependencies (that is `smoketest-stack`).
- Invent product intent that is not in the user's description.
- Keep adding polish after the plan is actionable.
