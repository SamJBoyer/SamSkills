---
name: salvage-operation
description: >-
  Moves FUNCTIONAL_MODULEs from SOURCE_REPO to TARGET_REPO using the
  salvage-manifest. The model chooses which modules are worth taking, how
  valuable each is, and how much of each module to take. Use when the user
  names salvage-operation, SOURCE_REPO and TARGET_REPO, or wants to salvage
  modules into another repo.
disable-model-invocation: true
---

# Salvage Operation

Guide the moving of FUNCTIONAL_MODULEs from SOURCE_REPO to TARGET_REPO.

You have widespread discretion: which modules are worth taking, how valuable each FUNCTIONAL_MODULE is, and how much of the module to take. Read TARGET_REPO as well as the salvage-manifest before you cut. Do not migrate by inventory order on autopilot.

## Terms

- **SOURCE_REPO**: the reviewed codebase. It already has a salvage-manifest.
- **TARGET_REPO**: the destination codebase. Chosen slices land here.
- **SALVAGE_MANIFEST**: `.SALVAGE/salvage-manifest.md` at SOURCE_REPO root, written by `salvage-explore` and corrected by `salvage-review`.
- **FUNCTIONAL_MODULE**, **SEAM**, **SEAM_SHAPE**: as in the salvage-manifest. A folder name is not a module.

## Resolve

Need both repo roots as absolute paths. They must be different git tops.

1. User named both → use those.
2. User named one path:
   - Workspace has a salvage-manifest → workspace is SOURCE_REPO, named path is TARGET_REPO.
   - Named path has a salvage-manifest → that is SOURCE_REPO, workspace is TARGET_REPO.
3. Otherwise stop and ask.

Resolve with `git rev-parse --show-toplevel` (and `git -C <path> rev-parse --show-toplevel` for the other). Stay in the invoking window. Read and write the other repo by absolute path.

If `.SALVAGE/salvage-manifest.md` is missing, stop. Tell the user to run `salvage-explore` then `salvage-review` on SOURCE_REPO first.

## Judge

Read the salvage-manifest. Survey TARGET_REPO enough to know what it already has and what would actually help it.

For each FUNCTIONAL_MODULE, decide **take**, **slice**, or **skip**, and say how valuable it is (high / medium / low) in one sentence. Use the manifest's SEAMs and coupling as evidence, not as a mandatory packing list.

- User named modules → those are in scope. Discretion is how much of each to take, not whether to ignore the request.
- User named none → you choose which are worth taking.
- Already recorded as transferred → skip.
- A module that cannot land without rewriting TARGET or SOURCE into a new product → skip and say why.

**How much to take** is your call: the valuable core, tests/fixtures, a thinner API, or almost the whole cluster. Leave behind host-only glue, sibling modules, and anything TARGET already does better. Prefer a clean SEAM cut when the slice you want already has one.

Verify paths still exist; if a path is gone, skip and report.

## Move

For each module you are taking, in an order that makes the landings make sense:

1. **Bound the slice.** The files and types you chose, plus proof worth keeping. Do not take the salvage plane or the rest of SOURCE.
2. **Land in TARGET_REPO.** If TARGET already has a matching home (package, assembly, tree), put it there. If TARGET is empty or has no home, keep SOURCE-relative paths. Refuse to overwrite existing TARGET files; stop on that module and say so.
3. **Fit the SEAM.** In TARGET, keep the slice's interior. Replace host/sibling imports with the thinnest adapter that matches the named SEAM_SHAPE, or leave a clear hole at that SEAM if TARGET has no host yet. Restyle or rename only as the land requires (package/namespace/import paths). You may drop or rewrite files that are not worth bringing.
4. **Remove from SOURCE_REPO what you took.** Do not leave a copy of the moved files. Leave what you skipped. Do not patch SOURCE to keep compiling unless the user asks.

Move means the taken implementation lives in TARGET_REPO only.

## Record

Append `.SALVAGE/transfers.md` on SOURCE_REPO (create if needed):

```markdown
# Transfers

- **<module identity>** → `<TARGET_REPO name>` `<landed path>`
  - **Decision**: take | slice | skip
  - **Value**: high | medium | low — <one sentence>
  - **Slice**: what moved, what was left
  - **SEAMs**: <names cut, or none>
```

Do not commit in either repo unless asked. Report: decisions, modules moved, landed paths, skipped modules, SOURCE deletions, TARGET status.

## Do not

- Re-run `salvage-explore` or rewrite the salvage-manifest.
- Copy instead of move.
- Move the salvage plane, the whole SOURCE tree, or a directory that is not the chosen slice.
- Open the other repo in a second window.
- Overwrite files that already exist in TARGET_REPO.
- Keep SOURCE compiling after a cut unless the user asks.
- Run the test suite.
- Commit.
