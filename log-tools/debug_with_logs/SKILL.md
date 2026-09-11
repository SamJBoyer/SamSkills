---
name: debug_with_logs
description: >-
  Debug by reading the repo-root log/ tree from setup-logs (CURRENT.txt →
  newest log file, one folder per run). Use when iterating on a running or
  recently run app: launch, read logs, diagnose, change, re-run. Companion
  to setup-logs. Triggers on debug with logs, check the logs, CURRENT.txt,
  or a project that already has log/.
---

# Debug with Logs

Companion to **setup-logs**. That skill creates `log/` and wires the app.
This skill uses that tree to debug: run → read logs → change → re-run.

If `log/` or `log/CURRENT.txt` is missing, stop and apply **setup-logs**
first (or ask). Do not invent a second log root.

**TARGET_REPO**: git top-level of the workspace this skill was invoked in.
**LOG_ROOT**: `log/` at TARGET_REPO root.
**CURRENT**: `log/CURRENT.txt` — one line, TARGET_REPO-relative path with
forward slashes, pointing at the newest log file (e.g.
`log/run-2026-09-10T211500Z/app.log`).
**RUN_DIR**: the folder that contains that file.

## Locate the live run

1. Read CURRENT. Open that path. That file is the live log.
2. If the diagnosis needs more than one file, read other files in the same
   RUN_DIR. CURRENT names the newest file, not the only file.
3. Prefer those files over chat memory, guesses, or an older `log/run-*`
   folder.

Do not pick a log by mtime unless CURRENT is missing. If CURRENT is missing
or the path is stale, say so and fall back to the newest RUN_DIR only after
that.

## Workflow

1. Read CURRENT → open the live log (and sibling files in RUN_DIR if needed).
2. Ground the diagnosis in what those files show (errors, stack traces,
   start/exit lines, unexpected values).
3. Change code or config from that evidence.
4. After a re-run, read CURRENT again (a new RUN_DIR may have been created)
   and the new files before declaring success.

## Do not

- Skip logs and debug from assumptions alone.
- Use a non-current RUN_DIR when CURRENT points elsewhere.
- Declare a fix without re-reading CURRENT after the re-run.
- Write logs somewhere other than LOG_ROOT (that is setup-logs' job).
