---
name: shunt-idea
description: Creates a junction or symlink (the slide) from the current repo to a path on this computer and copies files across it into that target. Use when the user names shunt, shunt idea, a target path to another repo, or when this repo makes us think of things that belong in a separate repo and we don't want to manually move stuff around.
---

# Shunt Idea

Accepts a path on this computer. This creates a junction or symlink — the **slide** — from the repo the skill was invoked in to the target. Then writes `INSTRUCTIONS.md` at the invoking repo root explaining how to slide files. We use this skill when a repo makes us think of things that belong in a seperate repo and we don't want to manually move stuff around. Sliding means copying a file across the slide into TARGET without changing windows.

**INVOKING_REPO**: git top-level of the workspace this skill was invoked in.
**TARGET**: absolute directory on this computer (another repo or folder).
**SLIDE**: the junction/symlink at `shunt/<target-folder-name>/` inside INVOKING_REPO. Writes there land in TARGET.

## When

- User gives a TARGET path, or says shunt / shunt idea → **open or reuse a slide**.
- A slide already exists and the current idea belongs in TARGET → **slide it**. Do not switch windows or open TARGET as the workspace.

If there is no slide yet and no TARGET path, ask for the path and stop.

## Open a slide

1. Resolve INVOKING_REPO (`git rev-parse --show-toplevel`) and TARGET to absolute paths. TARGET must be a directory. Create it if it is missing. Refuse if TARGET is inside INVOKING_REPO.
2. Run the matching script from this skill directory (execute; do not rewrite it):

Windows (from this skill's root directory):

```powershell
powershell -NoProfile -File scripts/create-shunt.ps1 -RepoRoot <INVOKING_REPO> -TargetPath <TARGET>
```

Unix (from this skill's root directory):

```bash
bash scripts/create-shunt.sh <INVOKING_REPO> <TARGET>
```

3. Confirm `shunt/` is gitignored in INVOKING_REPO (the script appends it if missing).
4. Confirm `INSTRUCTIONS.md` exists at the INVOKING_REPO root. Report the SLIDE path and the real TARGET. Do not commit.

Re-invoking with the same TARGET reuses the existing slide. A different TARGET adds another named slide under `shunt/`.

## Slide an idea

1. Pick the SLIDE whose TARGET owns the idea. If several slides fit, ask which one.
2. Copy the files across the SLIDE into `shunt/<name>/...` using TARGET's layout. Sliding means taking those files and copying them across the symlink — do not treat the slide as a move.
3. Leave the INVOKING_REPO copies in place. Clean up (delete the originals) only if the user specifically requests it.
4. Stay in this window. Verify with `git -C <TARGET> status` (and list the SLIDE paths). Do not `git add` slide files in INVOKING_REPO. Do not commit in TARGET unless asked.

## Do not

- Follow the slide when searching or editing INVOKING_REPO's own tree.
- Commit `shunt/` or TARGET files into INVOKING_REPO.
- Open TARGET in another window to move the files.
- Delete INVOKING_REPO copies unless the user asked for cleanup.
- Rewrite the create-shunt script instead of running it.
