---
name: supervised-prototype
description: >-
  Work on prototype code under direct supervision: implement a quick feature or
  small fix without heavy setup, write tests to lock in changes, and commit
  descriptively. Stop and wait if a dependency is unexpectedly missing. Use when
  deploying an agent to a prototype, making a fast prototype change, or retrying
  after other agents failed so a systematic roadblock can be identified.
disable-model-invocation: true
---

# Supervised Prototype

This skill is invoked when a user is deploying an agent to work on a prototype project under direct supervision.

## Use cases

- The user is building a prototype and wants an agent to implement a quick feature without heavy setup.
- User is quickly addressing bugs or small changes in a prototype.
- Previous agents have failed to accomplish a task and the user wants to deploy an agent under direct supervision so they can determine if there is a systematic roadblock.

## Do

- If you run into an unexpected missing dependency (ex. docker isn't installed), alert the user and wait.
- Write tests to lock-in changes when needed
- Write a descriptive git commit
- Refer to user instructions and your own judgement on implementation practices over the pre-existing standards in the code base. The code in the project is prototype code, so it might be buggy, poorly designed, or irrelevant to your task.

## Do not

- explore other agent's chats or the git diff for greater context. This skill is often used when other agents have failed, so looking at their trace/git commits will lead to following the same failed strategy.
- Wander to address tangential issues.
- Build any shims for backward compatibility. Because we're in a prototype we don't worry about backwards compatibility.
