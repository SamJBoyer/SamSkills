---
name: smoketest-stack
description: >-
  Takes a project plan and smoke-tests every external dependency with a live
  check. Use after big-project-planner, or when asked to smoketest the stack,
  APIs, services, or external dependencies in a plan.
disable-model-invocation: true
---

# Smoketest Stack

Take a plan and smoke-test every external dependency. A mock is not a smoke test. Do not reopen product intent or redesign the stack unless the plan is impossible as written (say why, stop, or send the user back to `big-project-planner`).

If no plan is in context, look for `plan/PROJECT-PLAN.md`. If it is missing, stop and tell the user to run `big-project-planner` first.

## Inventory

Read the plan's **External dependencies** list. That list is the work. Do not rediscover the product.

If a dependency is clearly required by the named stack but absent from the list, add it to the report as **discovered** and smoke-test it too. Do not silently ignore it. Do not rewrite the plan.

If the plan has no external dependencies and the stack implies none, record that and stop.

## Smoke

For each dependency, run the lightest **live** check that proves it exists and is reachable. If the plan names a smoke check, use that. Otherwise:

| Kind | Default smoke |
|---|---|
| API | Public health/GET if available; else credential present + one documented read |
| DB | Connect and a no-op query (`SELECT 1` or equivalent). No migrations. |
| Queue | Connect or list. Do not publish load. |
| Auth | Config present; fetch well-known / JWKS or equivalent |
| Package | Resolve the named package and version from the registry |
| Image | Pull or inspect the tagged image manifest |
| Cloud | Identity works (`whoami` or equivalent). Do not provision. |
| Device / binary | Binary on PATH, or the documented port responds |

Run independent checks in parallel when safe. Prefer read-only. If a check would be destructive or would provision paid resources, use the next-lightest read-only check and note the limit.

Missing credentials: record **blocked**, tell the user what env/account is needed, do not invent secrets, do not print secret values.

A dependency that is "not running yet because we have not built it" is not an external dependency. Skip host-local app processes that the plan says this project will implement.

## Deliverable

Write `plan/SMOKETEST-REPORT.md`:

```markdown
# Smoketest Report: <product>

## Plan
- Path to the PROJECT-PLAN this tests

## Results
For each dependency:
- **Name**:
- **Kind**:
- **Check run**:
- **Result** (pass / fail / blocked):
- **Evidence** (status, reachable endpoint, resolved version — no secrets):
- **Blocker** (if fail/blocked):

## Discovered
- Dependencies smoked that were not listed in the plan

## Summary
- Pass / fail / blocked counts
- What must be true before a builder starts
```

Tell the user the smoke results. Do not start building the product. Do not "fix" a failed dependency unless the user asks.

## Do not

- Mock, stub, or assume a dependency works.
- Provision infrastructure or spend money to make a check pass.
- Implement the product or change the plan's product intent.
- Skip a listed dependency because it "probably works."
