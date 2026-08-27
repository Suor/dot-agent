---
name: forge-plan
description: |
  Build/refine planning artifacts by separating provenance into files.
  TRIGGER: non-trivial plans; integrating review feedback.
  SKIP: READMEs; one-off notes; code comments.
---

# Forging plans

## Core Ideas

**Separate by provenance:**

- `user-requests.md` — user words verbatim, but only actual asks and decision-bearing quotes (initial prompt + later adjustments). NOT a transcript: clarifying questions and discussion replies resolve in place and land in Decisions instead. Append-only; fix only typos.
- `facts.md` — extracted or deduced from code/benches/evidence/docs/web, each claim with `path:line` or URL. Distilled facts and per-case recipes stay in the plan doc (an appendix section is fine); side files are ONLY for raw bulky sources the plan cites — verbatim agent reports, survey dumps (`plan-<topic>-survey.md`). Append; mark stale, don't rewrite.
- `plan.md` — Goals, Decisions (each resolved discussion compressed to a few lines), Stages (each with a concrete check), Open questions (`Q1, Q2, ...`). Rewritable; complies with the above.

Small efforts: one file with these as sections.
Bigger plans: add `plan-<component>.md` self-contained component designs. `plan.md` refers component only, not back.

**Parallel AI Help and Review:**

Can run subagent and also CLI agents in parallel - `claude -p`, `gemini -p`, `codex exec`. With the same prompt, then consolidate and apply.

## Before finalizing

**Cut to the ask.** The plan contains only what the user's verbatim requests cover. Before declaring it done, re-read `user-requests.md` and delete anything not grounded there — your own "while we're at it" additions, reviewer suggestions the user didn't pick, machinery for distinctions the user never introduced. When the user trims ("throw out what I didn't say"), that's a signal you've been over-adding; default narrower next time.

**Compress, don't accumulate — and never drop.** Each update folds resolved threads into Decisions and cuts the prose they replace — a plan that only grows is a transcript, not a plan. But folding compresses wording, not content: everything established as a fact or decided keeps a written home in the plan doc; cutting a paragraph is legal only when its substance already lives elsewhere in the doc. An open question is open only while the user still has to decide: de-facto-decided ones (the user's later asks already build on an answer) move to Decisions; verify-during-implementation items move into a stage's check.

**Reconcile on divergence.** When implementation is directed to contradict the plan (a goal reversed, a stage dropped, an open question mooted), update the plan doc in the same turn and call out the divergence — don't leave `plan.md` describing an abandoned decision, and don't wait to be asked.

**Principle vs implementation.** A principled / schema-level plan states *what* and *why*, not *how*. No line numbers, API names, file paths, severity tiers, or step-by-step mechanics unless the user asked for that altitude. Tempted to add them "for completeness"? That's bloat — it makes the plan unreadable and pre-commits decisions that aren't the plan's to make.
