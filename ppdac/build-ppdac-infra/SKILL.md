---
name: build-ppdac-infra
description: >-
  Implement PPDAC measurement infrastructure from a PPDAC-infra-plan and write
  a runbook explaining how to run it. Use when building eval/benchmark/metrics
  harnesses after explore-ppdac-infra, or when given a PPDAC-infra-plan to implement.
disable-model-invocation: true
---

# Build PPDAC Infra

Take a **PPDAC-infra-plan** and implement it. Do not reopen Problem or redesign METHODS unless the plan is impossible as written (say why, stop, or send the user back to `explore-ppdac-infra`).

If no plan is in context, look for `ppdac/PPDAC-infra-plan.md`. If it is missing, stop and tell the user to run `explore-ppdac-infra` first.

## Build

Implement only what the plan lists as remaining infra. Reuse existing hooks the plan named.

- Prefer a fast, deterministic harness.
- Add the minimum: timers, counters, traces, or a small writer of structured results.
- Persist records the run skill can analyze: timestamp, commit/run id, condition (baseline vs treatment), GOAL metric(s), covariates, provenance.
- Include a check that the hypothesized code path actually ran (flag, counter, span, or assertion).
- Do not build a research platform larger than the plan.

## Deliverable

Write `ppdac/PPDAC-infra-runbook.md` explaining how to run the infra (not the scientific conclusion). Use this shape:

```markdown
# PPDAC Infra Runbook: <GOAL>

## Plan
- Path to the PPDAC-infra-plan this implements
- GOAL and HYPOTHESIS (copied, not rewritten)

## Prerequisites
- Commands, services, env, data/fixtures

## How to run
- Exact commands for baseline and treatment
- How to set sample size / repetitions if configurable
- How to identify commit, config, and condition in the output

## Artifacts
- Location and format of result files
- Record schema (field names)
- How to confirm the hypothesized path was hit

## Smoke check
- Fastest command that proves the infra is wired
- What success looks like

## Troubleshooting
- Common failures and fixes
```

Tell the user the infra is ready for `run-ppdac-infra`. Do not execute the full experiment or write a SCIENCE_REPORT.
