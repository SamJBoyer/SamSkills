# Big Project Planner

Two skills, one GOAL: turn a product description into an actionable plan, then prove every external dependency in that plan is actually reachable. Do not treat a plausible stack as proven.

| Order | Skill | Does | Writes |
|---|---|---|---|
| 1 | `big-project-planner` | Take a product description. Iteratively add detail until the project is actionable. | `PROJECT-PLAN` |
| 2 | `smoketest-stack` | Take that plan. Smoke-test every external dependency. | `SMOKETEST-REPORT` |

Run them in order. `smoketest-stack` consumes the plan; it does not reopen product intent unless the user says so.

## Terms

- **PRODUCT**: The user's description of what to build. The planner adds detail until this is actionable.
- **ACTIONABLE**: A builder can start the first slice without inventing product intent, and `smoketest-stack` can name and hit every external dependency.
- **PROJECT-PLAN**: The plan produced by `big-project-planner`.
- **EXTERNAL DEPENDENCY**: Anything outside this codebase the product must reach (API, DB, queue, auth, package, image, cloud, device).
- **SMOKE**: The lightest live check that the dependency exists and is reachable. A mock is not a smoke test.
