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

- `user-requests.md` — user words verbatim (initial prompt + later adjustments). Append-only; fix only typos.
- `facts.md` — extracted or deduced from code/benches/evidence/docs/web, each claim with `path:line` or URL. Append; mark stale, don't rewrite.
- `plan.md` — Goals, Stages (each with a concrete check), Open questions (`Q1, Q2, ...`). Rewritable; complies with the above.

Small efforts: one file with these as sections.
Bigger plans: add `plan-<component>.md` self-contained component designs. `plan.md` refers component only, not back.

**Parallel AI Help and Review:**

Can run subagent and also CLI agents in parallel - `claude -p`, `gemini -p`, `codex exec`. With the same prompt, then consolidate and apply.
