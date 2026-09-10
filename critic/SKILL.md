---
name: critic
description: Explain why a TARGET_SKILL's wording produced a specific OUTCOME in this repo so the user can tweak the TARGET_SKILL.
disable-model-invocation: true
---

<terms>

TARGET_SKILL: the skill the user is trying to improve. The TARGET_SKILL will ALWYAS be
different from THIS skill that we're running.
OUTCOME: the result of the TARGET_SKILL being run

</terms>

Use when the user names critic, posts a TARGET_SKILL plus its OUTCOME, and asks why the TARGET_SKILL led to that OUTCOME.

# Critic

The user uses this skill to improve the OUTCOME of a TARGET_SKILL. the user will post the TARGET_SKILL, the OUTCOME of the TARGET_SKILL, and the ask a series of questions. YOUR JOB is to explain why, in the context of the repo, the wording of the TARGET_SKILL lead to the specific OUTCOME. The user will use this skill to tweak the TARGET_SKILL.

Do not re-run TARGET_SKILL. Do not rewrite TARGET_SKILL unless the user asks.

## Inputs

Require all three. If one is missing, ask for it and stop.

| Input | What it is |
|---|---|
| **TARGET_SKILL** | Path, paste, or `@` file. Always a different skill from this one. |
| **OUTCOME** | Paths, paste, or chat result of the TARGET_SKILL being run. |
| questions | The user's list. Answer these; do not invent a general review. |

## Method

1. Read TARGET_SKILL in full, including files it tells the agent to read.
2. Read the OUTCOME in the repo when paths are given. Do not trust a summary if the artifact exists.
3. For each question, name the **repo facts** that made this OUTCOME possible or likely (files, contracts, tests, host rules, existing artifacts).
4. Quote the TARGET_SKILL phrases that steered the agent toward that OUTCOME. Do not paraphrase the causal wording.
5. Say which bucket each cause is:

| Bucket | Meaning | Tweak |
|---|---|---|
| **TARGET_SKILL-forced** | The phrase required or strongly defaulted this OUTCOME | Change or delete that phrase |
| **TARGET_SKILL-silent** | TARGET_SKILL did not constrain this; the agent filled the gap | Add a constraint |
| **repo-forced** | Repo reality overrode or satisfied the TARGET_SKILL (AGENTS.md, contracts, code shape) | TARGET_SKILL must win the conflict, or accept the repo |

A claim that is only generic skill-writing advice is out of scope. Ground every answer in this checkout.

## Answer shape

For each user question:

```markdown
### Q: <question>

- **OUTCOME**: what the OUTCOME actually did
- **TARGET_SKILL wording**: quoted phrase(s) from TARGET_SKILL
- **Repo fact**: path or contract that made that wording land this way
- **Bucket**: TARGET_SKILL-forced | TARGET_SKILL-silent | repo-forced
- **Lever**: the smallest TARGET_SKILL wording change that would steer the next run
```

After the last question, list **Levers** — unique TARGET_SKILL phrases to edit, in the order they most affected the OUTCOME. No new TARGET_SKILL text unless asked.

## Do not

- Re-run TARGET_SKILL or "fix" the OUTCOME.
- Rewrite TARGET_SKILL unless asked.
- Answer questions the user did not ask.
- Blame the model in the abstract. If TARGET_SKILL was silent, say that.
- Critique OUTCOME quality except as it answers a question.
