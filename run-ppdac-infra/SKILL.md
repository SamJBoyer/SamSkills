---
name: run-ppdac-infra
description: >-
  Execute PPDAC measurement infrastructure from a PPDAC-infra-plan and runbook,
  then write a SCIENCE_REPORT with data, analysis, and conclusion. Use when
  running evals/benchmarks after build-ppdac-infra, or when asked to produce a
  SCIENCE_REPORT from existing PPDAC infra.
disable-model-invocation: true
---

# Run PPDAC Infra

Execute the built infra and produce a **SCIENCE_REPORT**. Follow the plan and runbook; do not invent a new experiment or rebuild infra. If either artifact is missing, look for `ppdac/PPDAC-infra-plan.md` and `ppdac/PPDAC-infra-runbook.md`. If they are absent, stop and send the user to `explore-ppdac-infra` then `build-ppdac-infra`.

## Data

Run the procedure in the runbook (baseline and treatment, stated sample size). Store artifacts where the plan specified (CSV, JSON Lines, or the project metrics store).

Each record should include timestamp, run/commit identity, condition, GOAL metric(s), covariates, and provenance.

If a run did not hit the hypothesized path, discard or label it. Do not analyze the wrong experiment.

## Analysis

Compare artifacts against the HYPOTHESIS in the plan:

- Parse logs, traces, counters, and state dumps.
- Verify returned payloads or persisted state after the run.
- Summarize the GOAL metric: central tendency, spread, baseline-vs-treatment difference.
- Decide whether telemetry moves in the hypothesized direction, stays flat, or moves the other way, and whether the sample is stable enough to say so.

If the data contradict the HYPOTHESIS, isolate the variance and record a refined sub-hypothesis in the report. Do not silently rewrite the original GOAL. Do not start a new infra project in this skill.

## Conclusion

State:

1. Supported, rejected, or inconclusive.
2. Progress toward the GOAL: yes, no impact, or regression.
3. Effect size, uncertainty, and experimental limits.
4. What to measure or change next, if anything.

A negative result (no impact) is a valid, successful report.

## Deliverable

Write `ppdac/SCIENCE_REPORT.md`:

```markdown
# Science Report: <GOAL>

## Problem
- **GOAL**:
- **HYPOTHESIS**:
- **Scope** (code, configs, pipelines under test):

## Plan
- **METHODS**:
- **Metrics**:
- **Baseline vs treatment**:
- **Workload / fixtures**:
- **Success criteria**:
- **Instrumentation added or reused**:

## Data
- **Location**:
- **Format**:
- **Runs / sample size**:
- **Provenance** (commit, env, date):

## Analysis
- Summary of the GOAL metric (baseline vs treatment)
- Trace / state checks that confirm the hypothesized path ran
- Effect size and uncertainty
- Discrepancies and any refined sub-hypothesis

## Conclusion
- Supported / rejected / inconclusive
- Progress toward GOAL: yes / no impact / regression
- Limits and next measurement
```
