---
name: explore-ppdac-infra
description: >-
  Explore a codebase for PPDAC measurement infrastructure: inventory what
  already exists, identify gaps, and write a PPDAC-infra-plan for the remaining
  infra. Use when exploring scientific evaluation, PPDAC, GOAL measurement,
  or before build-ppdac-infra / run-ppdac-infra.
disable-model-invocation: true
---

# Explore PPDAC Infra

Exploratory phase only. Do not implement harnesses, timers, or data stores. Survey the repo, pin the GOAL and HYPOTHESIS, and write a **PPDAC-infra-plan** that `build-ppdac-infra` can execute.

The user supplies the GOAL. If it is missing or vague, inspect the repo, propose a precise GOAL (what improves, in what units, under what conditions), and confirm before writing the plan.

## Problem

1. Restate the GOAL as a measurable claim.
2. Formulate HYPOTHESIS: *this implementation (or this change) affects the GOAL in this direction, for this reason.*
3. Name the code under test: modules, APIs, configs, or pipelines.

Stop Problem only when GOAL, HYPOTHESIS, and scope are explicit enough to design an experiment.

## Inventory (do not build)

Find existing mechanisms that could produce quantitative evidence:

- Metrics, counters, timers, traces, logs, profilers
- Benchmarks, load tests, eval harnesses, fixtures, golden sets
- CI jobs that already record performance or quality
- Stores or formats already used for run artifacts (CSV, JSONL, DB, dashboards)

For each item: path, what it measures, whether it hits the hypothesized code path, and what is missing.

## Plan the remaining infra

Design the lightest procedure that can accept or reject the HYPOTHESIS. Reuse what exists. Specify only the minimum new infra (timers, counters, traces, or a small harness).

The plan must include:

- Metrics that operationalize the GOAL
- Baseline vs treatment
- Workload or fixture that exercises the relevant path
- Sample size, repetitions, noise / warmup / caching
- Success / no-effect criteria
- Artifact location and format
- What to reuse vs what `build-ppdac-infra` must add
- How to confirm a run actually hit the hypothesized path

Choose the lightest evidence method that can test the HYPOTHESIS:

| Approach | Role | Techniques |
|---|---|---|
| Static tracing | Decide *what* to measure and *where* to instrument | Dependency graphs, call hierarchy, config/feature-flag tracing |
| Dynamic execution | Observe the live path | Traces, spans, debug runs, log injection |
| Synthetic tests | Isolate targeted logic | Unit harnesses, mocks, replay fixtures, microbenchmarks |

Static tracing cannot statistically prove the GOAL. The plan must end in dynamic or synthetic numbers.

## Deliverable

Write `ppdac/PPDAC-infra-plan.md` in the project (create `ppdac/` if needed):

```markdown
# PPDAC Infra Plan: <GOAL>

## Problem
- **GOAL**:
- **HYPOTHESIS**:
- **Scope**:

## Existing infra
- What exists, where, what it measures, gaps

## Remaining infra to build
- New instrumentation, harnesses, stores (minimum only)

## METHODS
- **Metrics**:
- **Baseline vs treatment**:
- **Workload / fixtures**:
- **Sample size / repetitions**:
- **Success / no-effect criteria**:
- **Artifact location and format**:
- **Path-hit verification**:

## Build notes for build-ppdac-infra
- Ordered implementation steps
- Out of scope
```

Tell the user the plan is ready for `build-ppdac-infra`. Do not start building.
