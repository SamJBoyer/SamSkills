# Distill

Prepare an existing project to be stripped for parts. A prototype is being rebuilt; some modules are useful enough to migrate intact. This work finds those modules and names the **seams** so they can be cleaved cleanly. It does not rebuild the successor and does not extract code.

This may become multiple skills. Until then, run the phases in order. Later phases consume earlier artifacts; they do not redo inventory unless the user says so.

| Order | Phase (future skill) | Does | Writes |
|---|---|---|---|
| 1 | `explore-distill` | Map the prototype. Inventory modules. Score salvage vs throw-away. | `DISTILL-inventory` |
| 2 | `plan-distill-seams` | Name seams, classify extractability, write cut contracts. | `DISTILL-PLAN` |
| 3 | `cleave-distill` *(not this document)* | Isolate a salvage module at a named seam. | Extracted module / adapter |

This document covers phases 1–2. Stop after the plan. Do not cleave.

## Terms

- **PROTOTYPE**: The existing project. Often messy, coupled, and scheduled for rebuild.
- **SUCCESSOR**: The rebuild. Out of scope here except as the destination that salvage must fit.
- **SALVAGE**: A module whose *implementation* is worth migrating intact (not merely whose idea is worth rewriting).
- **GLUE**: Wiring, host lifecycle, app-specific adapters, composition roots. Rarely salvage.
- **THROW-AWAY**: Prototype scaffolding, experiments, and fused code that will be rewritten.
- **SEAM**: A cut point: a boundary where behavior on one side can be separated behind a defined contract without editing the salvage interior.
- **CLEAVE**: Separating a salvage module at a seam. Successor work; not done here.
- **CUT CONTRACT**: What may cross the seam (calls, data, events, resources) and what must not.
- **DISTILL-inventory**: Module map and salvage scores from explore.
- **DISTILL-PLAN**: Seam map and ordered cleave instructions for a later skill.

## When to use

Use when a prototype must be rebuilt **and** the user wants intact modules, not a greenfield rewrite of everything. Trigger terms: distill, salvage, strip for parts, identify seams, cleave, extract modules, migrate intact, harvest from prototype.

Do not use for ordinary refactors, dependency cleanup with no successor, or “rewrite this file.” If nothing is worth migrating intact, say so and stop.

## Problem

1. Restate why the prototype is being rebuilt (what fails: architecture, scale, platform, ownership, quality).
2. Name the SUCCESSOR constraints that salvage must survive (language, runtime, host, license, isolation).
3. List user-nominated salvage candidates, or propose them after inventory.

Stop Problem only when the rebuild reason and successor constraints are explicit enough to score salvage. A module that cannot live under those constraints is not salvage.

## Explore (inventory)

Survey the repo. Do not refactor. Do not extract.

Map units the way the code actually clusters, not only how folders are named. A directory is not a module. A module is a cluster of behavior with a recognizable responsibility and a boundary you can point at (package, assembly, types, API, data model, process).

For each unit record:

- Path / identity
- Responsibility (one sentence)
- Inbound deps (who uses it)
- Outbound deps (what it uses)
- Coupling: imports, inheritance, shared mutable state, globals/singletons, events, config, I/O, host lifecycle
- Proof it works: tests, fixtures, golden files, or none
- Verdict: **salvage** / **adapter** / **rewrite** / **discard**

### Scoring salvage

Score the *implementation*, not the idea.

| Verdict | Meaning |
|---|---|
| salvage | Move intact. Outbound deps are stdlib, vendor, or already behind a contract. |
| adapter | Keep the core. One or two host assumptions need a thin seam. |
| rewrite | The idea is useful; the code is fused to the prototype. |
| discard | Not needed in the successor, or cheaper to rewrite than to extract. |

Default to **rewrite** or **discard**. Salvage is the exception. Prefer fewer, sharper modules over harvesting a private framework.

Treat as GLUE / THROW-AWAY unless proven otherwise:

- Composition roots, DI registration, app startup, scene/bootstrap
- UI shells, debug overlays, prototype cameras/controllers
- Copy-pasted variants and “v2” experiments
- God objects, shared mutable bags, stringly-typed event buses
- Code whose only tests are end-to-end through the whole prototype

### Coupling to hunt

Hidden coupling is the usual reason a “clean” folder cannot be cleaved:

- Static/global state, singletons, service locators
- Inheritance from host base classes
- Shared mutable models passed everywhere
- Config keys, file paths, resource IDs, magic strings
- Event buses and implicit message shapes
- Database schemas or stores owned by the host
- Framework lifecycle hooks (engine ticks, HTTP middleware, job runners)
- Cyclic imports between candidate modules

If a cluster has few edges to the rest of the graph, that pinch point is a candidate seam. If everything talks to one object, that object is not a seam; it is a blocker.

Write `distill/DISTILL-inventory.md`.

## Plan seams

For each salvage or adapter candidate, name the seam **as it exists today**, then the seam **required to cleave**. Prefer existing pinch points over inventing a new architecture.

A seam is real only if you can state:

1. **Interior** — files/types that must move together (the salvage unit).
2. **Host side** — what stays in the prototype / successor shell.
3. **Contract** — types, functions, events, or data that may cross.
4. **Forbidden crossings** — state, I/O, or host APIs that must not leak through.
5. **Blockers** — cycles, shared state, or missing contracts that make a cut dirty.

Classify the seam:

| Kind | Typical cut |
|---|---|
| Interface / protocol | Host depends on an abstraction the salvage already (or must) expose |
| Facade | One entry type hides a cluster; host talks only to the facade |
| Data | DTOs / schemas / files cross; behavior does not |
| Event / message | Asynchronous contract; no shared mutable objects |
| Process / service | Separate runtime; cut is a network or IPC API |
| Link / package | Assembly, crate, or package boundary already isolates the unit |

Do not propose a seam that requires rewriting the salvage interior to be understood. If the interior must change to exist at all, the verdict is **rewrite**, not **adapter**.

### Cut contract

For each planned cleave, specify:

- Public API of the salvage (what the successor may call)
- Inputs the salvage needs (injected deps, not host imports)
- Outputs and errors
- Resources (files, threads, GPU, network) and who owns them
- Tests that travel with the module
- Order relative to other cleaves (what must be cut first)

The plan must be executable by `cleave-distill` without rediscovering the graph.

## Deliverables

Create `distill/` if needed.

### `distill/DISTILL-inventory.md`

```markdown
# Distill Inventory: <prototype>

## Problem
- **Rebuild reason**:
- **Successor constraints**:
- **Nominated candidates**:

## Units
For each unit:
- **Identity / path**:
- **Responsibility**:
- **Inbound / outbound**:
- **Coupling notes**:
- **Proof it works**:
- **Verdict** (salvage / adapter / rewrite / discard):

## Graph
- Clusters and pinch points
- Cycles
- God objects / shared state
```

### `distill/DISTILL-PLAN.md`

```markdown
# Distill Plan: <prototype>

## Problem
- **Rebuild reason**:
- **Successor constraints**:

## Salvage set
- Modules to migrate intact (and why the implementation, not just the idea)

## Throw-away
- What will be rewritten or discarded (and why)

## Seams
For each salvage / adapter:
- **Interior**:
- **Host side**:
- **Seam kind**:
- **Cut contract** (API, inputs, outputs, resources, forbidden crossings):
- **Blockers**:
- **Tests that travel**:
- **Cleave order**:

## Out of scope
- Successor architecture
- Refactors that are not required to name a seam
```

Tell the user the plan is ready for `cleave-distill`. Do not start extracting, do not introduce interfaces “while you are here,” and do not begin the successor.
