---
name: commit
description: Split working changes into semantic commits with messages matching the repo's style
disable-model-invocation: true
allowed-tools: Bash(git status*), Bash(git diff*), Bash(git log*), Bash(git add*), Bash(git restore*), Bash(git commit*)
---

Commit the working changes:

1. Inspect with `git status` and `git diff` (and `git diff --staged`).
2. Group the changes into semantically independent parts — one concern per commit
   (e.g. a refactor separate from a behavior change). If it's all one concern, one commit.
3. Run `git log --oneline -20` and read a few full messages to infer the repo's
   convention: language, verbosity, and format. Match it. Do NOT impose
   `type: ...` prefixes unless the history already uses them.
4. Stage each part (`git add <files>`, or `git restore --staged` to separate) and commit
   it with a message in that style. Default to a subject line only; add a body just to
   explain non-obvious *why*, and keep it to 1-2 short sentences — not a paragraph
   (a bullet list is fine when the commit genuinely has several distinct parts).
5. When verifying an intermediate commit in isolation (tests on the staged tree alone),
   stash with `git stash push -u --keep-index` — without `-u` untracked files stay in the
   tree and the "isolated" run silently tests a mix.

Do not push. If `$ARGUMENTS` is given, treat it as scope/intent guidance.
