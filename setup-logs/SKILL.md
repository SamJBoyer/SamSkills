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

Wire the target app so each run writes into that run folder and updates CURRENT.txt.

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
2. Create `log/` at TARGET_REPO root if it does not exist.
3. Ensure `log/` is gitignored (`.gitignore` entry `log/`). Do not commit `log/`.

To create a run folder without launching the app (probe the layout, or wrap a one-off launch):

1. Make a new RUN_DIR using the stamp above. If that name already exists, suffix `-2`, `-3`, ….
2. Default LOG_FILE basename is `app.log` unless the app already has a log name.
3. Write CURRENT as one line: the TARGET_REPO-relative path of that log file, forward slashes.

## Wire the app

Each launch of the target app must:

1. Create a new RUN_DIR (same naming as Init; if the stamp exists, suffix `-2`, `-3`, …).
2. Write this run's logs into that folder.
3. Write CURRENT to the TARGET_REPO-relative path of the newest log file. If the run writes more than one file, CURRENT tracks the most recently written one.

Prefer wrapping the existing start path (npm script, Makefile, compose command, launcher) over replacing the logging stack. If the app already has a log-directory setting, point it at RUN_DIR and still keep CURRENT in sync.

Do not depend on this skill's path at app runtime. Put the contract in the target (a few lines in the start path, or the app's own logger).

Do not start a long-lived app just to prove wiring. After wiring, create one sample RUN_DIR and CURRENT if needed, and show the start-path change.

## Read

When looking at logs, read CURRENT first and open that path. Do not pick a file by mtime unless CURRENT is missing.

## Do not

- Invent a second log root (`logs/`, `tmp/logs/`, etc.).
- Put CURRENT at the repo root; it lives at `log/CURRENT.txt`.
- Use colons in RUN_DIR names.
- Commit `log/`.
- Depend on the skill directory from the shipped app.
