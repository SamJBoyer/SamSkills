---
name: salvage-explore
description: >-
  Discovers FUNCTIONAL_MODULEs and named SEAMs in SOURCE_REPO. Writes
  .SALVAGE/salvage-manifest.md. Use when the user names salvage-explore,
  salvage-manifest, functional modules, seams, or wants a map of separable
  parts before salvage-review or salvage-operation.
disable-model-invocation: true
---

# Salvage Explore

Discover the FUNCTIONAL_MODULEs and SEAMs that already exist in SOURCE_REPO. Write the salvage-manifest. That file is the map `salvage-review` checks and `salvage-operation` consumes.

Do not change product code. Do not extract, move, or refactor. Explore, then write the manifest.

## Terms

- **SOURCE_REPO**: the codebase being salvaged. Default: git top of the workspace this skill was invoked in (`git rev-parse --show-toplevel`). If the user names a different repo, that path is SOURCE_REPO.
- **FUNCTIONAL_MODULE**: a cluster of behavior with a recognizable responsibility and a boundary you can point at (package, assembly, types, API, data model, process). A folder name is not a module.
- **SEAM**: a named boundary between FUNCTIONAL_MODULEs, or between a module and the rest of the host.
- **SEAM_SHAPE**: how that boundary is built — what information crosses it, and how separable it is. Treat each FUNCTIONAL_MODULE as if it were a service; the SEAM_SHAPE is its API layer.
- **SALVAGE_MANIFEST**: `.SALVAGE/salvage-manifest.md` at SOURCE_REPO root.

## Discover

Resolve SOURCE_REPO. Survey the code and docs. Map FUNCTIONAL_MODULEs the way behavior actually clusters, not only how folders are named.

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

Create `.SALVAGE/` if needed. Write `.SALVAGE/salvage-manifest.md`.

```markdown
# Salvage Manifest: <SOURCE_REPO name>

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

Tell the user the salvage-manifest is at `.SALVAGE/salvage-manifest.md` and is ready for `salvage-review`. Do not start reviewing or moving.

## Do not

- Run the test suite.
- Change the codebase except writing the salvage-manifest.
- Extract, refactor, or introduce interfaces "while you are here."
- Treat a directory as a FUNCTIONAL_MODULE unless the code actually clusters there.
- Invent modules or seams that are not in the current implementation.
- Dispatch subagents (that is `salvage-review`).
- Move code (that is `salvage-operation`).
