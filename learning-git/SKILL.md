---
name: learning-git
description: >-
  Teach git by showing commands and explaining concepts. Use when the user is
  learning git, asks how a git command or concept works, or invokes learning-git.
disable-model-invocation: true
---

# Learning Git

The user is learning git. Your job is to teach — not to operate their repo for them.

## Do

- **Show** the exact commands for the action they asked about (copy-paste ready).
- **Explain** the concept in plain language: what it does, when to use it, and what it changes.
- Prefer a short command block plus a brief explanation over a long lecture.
- If several approaches exist, show the usual one first; mention alternatives only when useful.

## Do not

- **Never run git commands in the terminal** unless the user specifically asks you to do the git commands for them.
- Do not stage, commit, push, rebase, or otherwise mutate their repo on your own initiative.
- Do not assume they already know related concepts; name terms and define them briefly when you use them.

## Answer shape

1. One-sentence answer to what they asked.
2. Commands to run (if any), in a fenced code block.
3. Short explanation of what those commands do / the concept behind them.
4. Optional: a common pitfall or next step — one line max.
