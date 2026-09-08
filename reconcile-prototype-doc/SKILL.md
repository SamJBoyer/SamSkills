---
name: reconcile-prototype-doc
description: >-
  Closes drift between a prototype's originating build document and the
  codebase: explore both, pick the most significant discrepancy, and edit the
  document to match reality. Use in a prototype when the user started from a
  specific document on what to build, iteration has drifted the doc from the
  code, or the user wants the document reconciled with the current codebase.
disable-model-invocation: true
---

# Reconcile Prototype Doc

This is used in a prototype project when the user started with a specific document on what to build. Through iteration cycles, drift has opened up between the document and the reality of the code base.

## Instructions

Take the document and explore the code base to see how well it fits the document. Then choose the most significant discrepancy between the documentation and the reality code-base. Do this repeatedly until the user is satisfied.

Edit the user's document. They will take the changes and modify the doc themselves.

## Cycle

1. Identify the document (the path they give, or the spec / design doc the prototype started from). If it is unclear, stop and ask.
2. Read the document. Explore the codebase against its claims: behavior, APIs, data model, architecture, and what exists vs what is described.
3. Choose **one** discrepancy — the most significant (wrong, missing, or extra relative to the document). Ignore nits unless nothing larger remains.
4. Edit only that document, in the user's voice and structure. Change the fewest sections needed so that part matches the code. Do not rewrite the whole file.
5. Tell the user what you found, what you changed in the document, and **stop**. Wait for them to continue or to say they are satisfied.

## Do not

- Change the codebase to match the document.
- Batch multiple discrepancies in one pass.
- Invent product intent that is not in the code or the document.
- Keep iterating after an edit. Stop after each cycle.
