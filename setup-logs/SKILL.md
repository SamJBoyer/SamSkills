---
name: setup-logs
description: >-
  Stands up a repo-root log/ tree (one folder per target-app run, CURRENT.txt
  pointing at the newest log file) and wires the app so each run writes there.
  Use when the user names setup logs, CURRENT.txt, a log folder for runs, or
  wants the target app to record per-run logs.
disable-model-invocation: true
---

# Setup Logs

Takes a TARGET_REPO and gives it this shape: a **log folder at the repo root**. In the log folder, there is a folder for the logs for a single run of the target app. Then, there is a file called CURRENT.txt that points to the most recent log file.

Wire the target app so each run writes into that run folder and updates CURRENT.txt. Execute the scripts in this skill; do not rewrite them.

**TARGET_REPO**: git top-level of the workspace this skill was invoked in.
**LOG_ROOT**: `log/` at TARGET_REPO root.
**RUN_DIR**: `log/run-<UTC>/` — one folder for one run. UTC stamp is `yyyy-MM-ddTHHmmssZ` with no colons (`run-2026-09-10T211500Z`).
**LOG_FILE**: a file inside RUN_DIR. Default name `app.log` unless the app already has a log name.
**CURRENT**: `log/CURRENT.txt` — one line, TARGET_REPO-relative path with forward slashes, e.g. `log/run-2026-09-10T211500Z/app.log`.

## When

- User names setup logs / this skill → **init LOG_ROOT**, then **wire the app**.
- App already has a different log tree → migrate to this shape. Do not leave a second log root.

If TARGET_REPO cannot be resolved, stop and ask.

## Init

1. Resolve TARGET_REPO (`git rev-parse --show-toplevel`).
2. Run the matching script from this skill directory (execute; do not rewrite it):

Windows (from this skill's root directory):

```powershell
powershell -NoProfile -File scripts/setup-logs.ps1 -RepoRoot <TARGET_REPO>
```

Unix (from this skill's root directory):

```bash
bash scripts/setup-logs.sh <TARGET_REPO>
```

3. Confirm `log/` exists and `log/` is gitignored. Do not commit.

To create a run folder without launching the app (probe the layout, or wrap a one-off launch):

```powershell
powershell -NoProfile -File scripts/setup-logs.ps1 -RepoRoot <TARGET_REPO> -NewRun
```

```bash
bash scripts/setup-logs.sh <TARGET_REPO> --new-run
```

Optional `-LogName` / third argument sets the file basename (default `app.log`). Parse `RUN_DIR=`, `LOG_FILE=`, and `CURRENT=` from the output.

## Wire the app

Each launch of the target app must:

1. Create a new RUN_DIR (same naming as the script; if the stamp exists, suffix `-2`, `-3`, …).
2. Write this run's logs into that folder.
3. Write CURRENT to the TARGET_REPO-relative path of the newest log file. If the run writes more than one file, CURRENT tracks the most recently written one.

Prefer wrapping the existing start path (npm script, Makefile, compose command, launcher) over replacing the logging stack. If the app already has a log-directory setting, point it at RUN_DIR and still keep CURRENT in sync.

Do not depend on this skill's path at app runtime. Put the contract in the target (a few lines in the start path, or the app's own logger). The script is the reference implementation, not a runtime dependency.

Do not start a long-lived app just to prove wiring. After wiring, run `-NewRun` once if you need a sample CURRENT, and show the start-path change.

## Read

When looking at logs, read CURRENT first and open that path. Do not pick a file by mtime unless CURRENT is missing.

## Do not

- Invent a second log root (`logs/`, `tmp/logs/`, etc.).
- Put CURRENT at the repo root; it lives at `log/CURRENT.txt`.
- Use colons in RUN_DIR names.
- Rewrite the setup-logs script instead of running it.
- Commit `log/`.
- Depend on the skill directory from the shipped app.
