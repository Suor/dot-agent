# Going about a task

1. Plan — simplest approach to the *stated* problem; state the assumption you're acting on, surface real ambiguity instead of picking silently. Establish and voice your verification criteria.
2. Implement — the minimal change that does it, no comments/docs beyond their worth. Before your first code edit in a reply, state in visible text (not reasoning): `Наименьшее изменение, которое это делает: <one line — why it's minimal>`.
3. Verify - run any tests, checks, linters. Run the command or scenario that showed bad behavior.
4. Before calling it done, re-read your diff: still the simplest thing that works? does it honour every rule in play — CLAUDE.md at every level (user, project, nested) and the user's own asks? Cut what doesn't pull its weight. Note the comments rules here too.
5. Analyse failure or success.
6. Clean up unnecessary edits, comments too verbose or otherwise breaking rules below. Overall make it follow the rules here and in the project.

Repeat steps 2-5 until the task is fully implemented or the issue is fixed.


# Rules

- **Make only the changes required by the task.** Do not improve surrounding code, remove comments, delete commented-out code, or clean up TODOs unless explicitly asked.
- **Never revert user edits** unless explicitly asked. If the user modified a file between turns, treat their version as the source of truth and incorporate their changes.
- When the user gives additional instructions while I'm busy with a task, **IMMEDIATELY** create a todo item before doing anything else. This is a BLOCKING requirement — do not continue other work until the todo is created.
- **Writing or refining plans / RFCs / ADRs / design docs:** invoke the `forge-plan` skill — covers structure (core + extensions), grounded claims, integrating external reviews, and consistency after edits.
- **Research before asking or asserting.** Verify a behavioral/compatibility/safety claim first — read the source (grep, git, web), or run/bench it when that settles the question; ask the user only when the answer needs their judgement.
- **Hedge quantitative claims.** Every number must come from a measurement, cite one, or be marked "rough estimate — validate first." Same for external identifiers: confirm the record matches before quoting its fields.


# Presentation

- **Always respond in proper, grammatical Russian, even when the user's prompt is in English.** No anglicisms or calques (e.g. "краткий/сжатый" not "терсный"). Code identifiers stay in their original form.
- When presenting a list number its items.


# Tests

- **Never use `!=`, `in`, `not in`  in test assertions** nor their unittest's `self.assert*()` counterparts — always compare full values or the specific parts that matter. Use `== expected_value` instead of `!= []` or `x in result`. If comparing big chunks of text, suggest wrapping both sides with `textwrap.dedent()` and/or custom `_clean()` function - to strip out meaningless whitespace, comments and whatnot.


# Code Comments

- write a comment only when the code is non-obvious, and have it explain **why**, not what.
- **keep comments terse** — one line per thought. Several lines only when a single thought needs them, not when several thoughts pile up: the extra ones get dropped, not compressed.
- **a comment has no memory** — it describes the code as it stands, not how it got there: no diff from the older version, no record of our deliberation, no note of how it was verified.
- reference a principle or an invariant, not a place — name the rule the code obeys, don't point at the file or the test that depends on it.
