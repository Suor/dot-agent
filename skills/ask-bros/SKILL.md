---
name: ask-bros
description: Ask Gemini and Codex CLIs the same question in parallel and summarize their answers. Use when the user wants second/third opinions on a design call, recommends "ask the bros", or you want independent perspectives on a non-trivial decision.
---

# Ask Gemini and Codex for advice

The user wants independent opinions from Gemini and Codex CLIs on the question in `$ARGUMENTS`.

## Steps

1. **Frame the question.** If `$ARGUMENTS` is a fully-formed question, use it verbatim. If it's terse or context-dependent (e.g. "ask the bros about this approach"), draft a self-contained prompt that includes:
   - What the user is trying to decide.
   - Constraints and context the bros need (relevant code, behavior, environment).
   - Options the user already considered with brief pros/cons.
   - Explicit request for a recommendation + short rationale.
   - "Answer in bullet points, no preamble" to keep responses tight.

   Show the drafted prompt to the user only if it's ambiguous or you're unsure about scope — otherwise proceed.

2. **Write the prompt** to `/tmp/ask_bros_question.txt` via the Write tool.

3. **Launch both CLIs in parallel** with `run_in_background: true`. Send both Bash calls in a single message so they run concurrently:

   - Gemini: `gemini --skip-trust -p "$(cat /tmp/ask_bros_question.txt)"`
   - Codex: `codex exec --sandbox read-only "$(cat /tmp/ask_bros_question.txt)"`

4. **Wait for both task-notifications.** Do NOT poll the output files — the harness re-invokes when each finishes.

5. **Read both output files** (the paths come from the task-notification messages).

   Strip the CLI noise:
   - Gemini: drop the deprecation warnings and "Ripgrep is not available" line at the top.
   - Codex: skip everything up to and including the echoed question; take the answer between the `codex` marker and `tokens used`.

6. **Summarize for the user.** Keep it under ~300 words:
   - Codex's recommendation and one-line rationale.
   - Gemini's recommendation and one-line rationale.
   - One sentence on where they agree, where they diverge.
   - Optionally: a 3rd-line opinion of yours if the bros' suggestions raise something they missed.

## Notes

- If one of the CLIs is missing on the host (`which gemini` / `which codex` fails) — say so, run the available one, and skip the other.
- If gemini fails with a "trusted directory" error, the `--skip-trust` flag should already cover it; if not, fall back to `GEMINI_CLI_TRUST_WORKSPACE=true gemini -p ...`.
- Don't pipe the prompt as a shell argument directly — write to the temp file first. Shell quoting on long multi-line prompts is fragile.
