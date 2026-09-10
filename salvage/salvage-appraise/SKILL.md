---
name: salvage-appraise
description: >-
  Maps a TARGET_REPO into FUNCTIONAL_MODULEs and named SEAMs. Writes
  .SALVAGE/modular-inventory.md describing each modular part, its purpose,
  and how the project is structured with seams marked. Use when the user
  names salvage-appraise, modular inventory, functional modules, or wants
  to find separable parts of a repo.
disable-model-invocation: true
---

# Salvage Appraise

Take TARGET_REPO and find the modular functional components that already exist. Write a document that explains what those parts are, what each is for, and how they are structured — with every SEAM marked.

Do not change product code. Do not extract or refactor. Explore, then write the inventory.

## Terms

- **TARGET_REPO**: the codebase this skill is invoked in (`git rev-parse --show-toplevel`).
- **FUNCTIONAL_MODULE**: a cluster of behavior with a recognizable responsibility and a boundary you can point at (package, assembly, types, API, data model, process). A folder name is not a module.
- **SEAM**: a named boundary between FUNCTIONAL_MODULEs, or between a module and the rest of the host.
- **SEAM_SHAPE**: how that boundary is built — what information crosses it, and how separable it is. Treat each FUNCTIONAL_MODULE as if it were a service; the SEAM_SHAPE is its API layer.

## Explore

Resolve TARGET_REPO. Survey the code and docs. Map FUNCTIONAL_MODULEs the way behavior actually clusters, not only how folders are named.

For each FUNCTIONAL_MODULE record:

- Path / identity
- Responsibility (one sentence)
- Inbound deps (who uses it)
- Outbound deps (what it uses)
- Coupling: imports, inheritance, shared mutable state, globals/singletons, events, config, I/O, host lifecycle
- SEAMs it participates in, each with a SEAM_SHAPE: construction of the boundary, what crosses it, how separable it is
- Proof it works: tests, fixtures, golden files, or none

Typical SEAM_SHAPE kinds (pick the one that matches the code): interface / protocol, facade, data, event / message, process / service, package / assembly.

### Coupling to hunt

Hidden coupling is what later cuts have to see:

- Static/global state, singletons, service locators
- Inheritance from host base classes
- Shared mutable models passed everywhere
- Config keys, file paths, resource IDs, magic strings
- Event buses and implicit message shapes
- Database schemas or stores owned by the host
- Framework lifecycle hooks (engine ticks, HTTP middleware, job runners)
- Cyclic imports between modules

If a cluster has few edges to the rest of the graph, that pinch point is a candidate SEAM. If everything talks to one object, that object is not a SEAM; it is a blocker.

## Deliverable

Create `.SALVAGE/` if needed. Write `.SALVAGE/modular-inventory.md`.

```markdown
# Modular Inventory: <TARGET_REPO name>

## Modules

For each FUNCTIONAL_MODULE:

- **Identity / path**:
- **Responsibility**:
- **Inbound / outbound**:
- **Coupling notes**:
- **Seams** (name each SEAM and its SEAM_SHAPE):
- **Proof it works**:

## Structure

- How the modules sit relative to each other
- Named SEAMs (the marked boundaries)
- Pinch points, cycles, god objects / shared state
```

Tell the user the inventory is at `.SALVAGE/modular-inventory.md`. Do not start extracting.

## Do not

- Run the test suite.
- Change the codebase except writing the inventory.
- Extract, refactor, or introduce interfaces "while you are here."
- Treat a directory as a FUNCTIONAL_MODULE unless the code actually clusters there.
- Invent modules or seams that are not in the current implementation.
