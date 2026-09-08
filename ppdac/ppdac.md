# PPDAC Science Pipeline

Three skills, one GOAL: determine whether the codebase statistically supports a stated GOAL. Do not treat “the code looks like it should work” as proof. A valid result is measurable progress, no impact, or regression.

| Order | Skill | Does | Writes |
|---|---|---|---|
| 1 | `explore-ppdac-infra` | Explore the project. Inventory existing measurement infra. Plan the rest. | `PPDAC-infra-plan` |
| 2 | `build-ppdac-infra` | Implement the remaining infra from that plan. | Runbook: how to run the infra |
| 3 | `run-ppdac-infra` | Execute the infra. Collect data, analyze, conclude. | `SCIENCE_REPORT` |

Run them in order. Later skills consume the earlier artifacts; they do not redo exploration or redesign the experiment unless the user says so.

## Terms

- **GOAL**: The quantifiable property to measure (latency, token calls, accuracy, …). Anchors every later step.
- **HYPOTHESIS**: A testable claim that a specific implementation choice advances the GOAL.
- **METHODS**: Instrumentation, workload, metrics, comparison, and success criteria.
- **PPDAC-infra-plan**: The experiment + infrastructure plan produced by explore.
- **SCIENCE_REPORT**: The reproducible record of Problem, Plan, Data, Analysis, and Conclusion.
