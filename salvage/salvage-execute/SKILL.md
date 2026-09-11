---
name: salvage-execute
description: >-
  Moves FUNCTIONAL_MODULEs from a SOURCE_REPO salvage plane into a TARGET_REPO.
  Reads .SALVAGE/modular-inventory.md, cuts at named SEAMs, and relocates
  module implementations. Use when the user names salvage-execute, salvage
  plane, SOURCE_REPO and TARGET_REPO, or wants to move appraised modules
  into another repo.
disable-model-invocation: true
---

# Salvage Execute

We will run this skill with a TARGET_REPO and a SOURCE_REPO. The SOURCE_REPO has a salvage plane, and its modules will be moved from the SOURCE_REPO to the TARGET_REPO.

Migrate intact. Change only what a SEAM cut requires. Do not re-appraise and do not rebuild the successor around the parts.

## Terms

- **SOURCE_REPO**: the appraised codebase. It already has a salvage plane.
- **TARGET_REPO**: the destination codebase. Modules land here.
- **SALVAGE_PLANE**: `.SALVAGE/` at SOURCE_REPO root, written by `salvage-appraise`. Required file: `.SALVAGE/modular-inventory.md`.
- **FUNCTIONAL_MODULE**, **SEAM**, **SEAM_SHAPE**: as in the inventory. A folder name is not a module. Cut on named SEAMs, not on directory borders.

TARGET_REPO here is the destination, not the appraisal subject (`salvage-appraise` uses TARGET_REPO for the subject; that repo is SOURCE_REPO in this skill).

## Resolve

Need both repo roots as absolute paths. They must be different git tops.

1. User named both → use those.
2. User named one path:
   - Workspace has a salvage plane → workspace is SOURCE_REPO, named path is TARGET_REPO.
   - Named path has a salvage plane → that is SOURCE_REPO, workspace is TARGET_REPO.
3. Otherwise stop and ask.

Resolve with `git rev-parse --show-toplevel` (and `git -C <path> rev-parse --show-toplevel` for the other). Stay in the invoking window. Read and write the other repo by absolute path.

If `.SALVAGE/modular-inventory.md` is missing, stop. Tell the user to run `salvage-appraise` on SOURCE_REPO first.

## When

- User names this skill / salvage plane / SOURCE_REPO and TARGET_REPO → **move** the named FUNCTIONAL_MODULEs (every module in the inventory if they name none).
- A module is already recorded as transferred → skip it.
- Inventory lists a blocker (god object, inseparable coupling) for a module → skip that module, say why. Do not invent a rewrite to force the cut.

## Move

Read the salvage plane. Treat the inventory as the list of modules and SEAMs. Verify paths still exist; if a path is gone, skip and report.

For each FUNCTIONAL_MODULE, in inventory order unless the user gave an order:

1. **Bound the cut.** Files and types that are the module, plus tests/fixtures the inventory marks as its proof. Do not take host code, sibling modules, or the salvage plane.
2. **Land in TARGET_REPO.** If TARGET already has a matching home (package, assembly, tree), put it there. If TARGET is empty or has no home, keep the SOURCE-relative paths. Refuse to overwrite existing TARGET files; stop on that module and say so.
3. **Cut the SEAM.** In TARGET, keep the module's interior. Replace host/sibling imports with the thinnest adapter that matches the named SEAM_SHAPE, or leave a clear hole at that SEAM if TARGET has no host yet. Do not restyle or rename except as the cut requires (package/namespace/import paths).
4. **Remove from SOURCE_REPO.** Delete the moved files. Do not leave a copy. Do not patch SOURCE to keep compiling unless the user asks.

Move means the implementation lives in TARGET_REPO only.

## Record

Append `.SALVAGE/transfers.md` on the salvage plane (create if needed):

```markdown
# Transfers

- **<module identity>** → `<TARGET_REPO name>` `<landed path>` (SEAMs cut: <names>)
```

Do not commit in either repo unless asked. Report: modules moved, landed paths, skipped modules, SOURCE deletions, TARGET status.

## Do not

- Run `salvage-appraise` as part of this skill, or rewrite the inventory.
- Copy instead of move.
- Move the salvage plane, the whole SOURCE tree, or a directory that is not the module.
- Open the other repo in a second window.
- Overwrite files that already exist in TARGET_REPO.
- Keep SOURCE compiling after a cut unless the user asks.
- Run the test suite.
- Commit.
