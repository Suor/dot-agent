---
name: pr
description: |
  Open a pull request with a title and a one-line body, in the target repo's own conventions.
  TRIGGER when: creating a PR, upstreaming a local patch, or drafting PR text for review.
  SKIP: local commits (use `commit`), issues, code review comments.
---

A PR is a title plus one line saying what it enables. Nothing else, unless the repo asks.

1. Read the repo's rules before writing: `CONTRIBUTING*`, `.github/PULL_REQUEST_TEMPLATE.md`,
   recent merged PRs (`gh pr list --state merged --limit 10`), and the last few commit messages.
   Do whatever they require — release-note files, `sem-ver:`/changelog trailers, style checks.
2. Branch from the upstream default branch, not from your working state. One logical change per PR.
3. Title: imperative, names the change, ~50 chars. Not the reasoning, not the symptom.
4. Body: one line — what it now allows or fixes. Two if the change has a second consequence.
5. Cut before publishing: no headings, no "The bug / The fix / Testing" sections, no diff quoted
   back, no code walkthrough, no restating what the diff says, no listing the existing code your
   change is consistent with. Keep that reasoning for a maintainer's question.
6. Claims about verification: only what you actually ran, in the body's one line or not at all.
   Never write "tested for weeks", a version you did not check, or a result you inferred from
   reading code. If it matters and you have not run it, say plainly that you have not.
7. Show the draft to the user before publishing, in the same shape it will be published.

Good:

```
Run the quick-open command in the active tab dir

Allows command to work for relative paths, including partial ones.
```

Bad: the same change with `### The bug` / `### Why the tab's directory is the right one` /
`### Verification` sections, the diff pasted in, and two sentences naming other functions that
already behave that way.
