---
name: setup-promptchain
description: Create a prompts folder and ignore its contents in .cursorignore. Use when setting up promptchain, initializing prompts storage, or when the user invokes setup-promptchain.
disable-model-invocation: true
---

# Setup Promptchain

When this skill is invoked, create a `prompts` folder and make `.cursorignore` ignore everything inside it.

## Steps

1. Create `prompts/` at the repository root if it does not exist.
2. Ensure `.cursorignore` at the repository root contains a rule that ignores everything inside `prompts`.

If `.cursorignore` does not exist, create it. If it exists, append the ignore rule only when it is missing.

## Ignore rule

Use this exact rule:

```
prompts/**
```

Do not ignore the `prompts` directory itself. Only ignore everything inside it.
