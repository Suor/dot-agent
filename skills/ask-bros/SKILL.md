---
name: ask-bros
description: Ask Gemini, Codex, GLM and Kimi CLIs the same question in parallel and summarize their answers. Use when the user wants second/third opinions on a design call, recommends "ask the bros", or you want independent perspectives on a non-trivial decision.
---

# Ask Gemini, Codex, GLM and Kimi for advice

The user wants independent opinions from Gemini, Codex, GLM and Kimi (the latter two via opencode CLI) on the question in `$ARGUMENTS`.

## Steps

1. **Frame the question.** If `$ARGUMENTS` is a fully-formed question, use it verbatim. If it's terse or context-dependent (e.g. "ask the bros about this approach"), draft a self-contained prompt that includes:
   - What the user is trying to decide.
   - Constraints and context the bros need (relevant code, behavior, environment).
   - Reference repo files by path ("read docs/X.md") instead of inlining their content — all CLIs run in the project dir and read files themselves; they can also inspect history with read-only git (`git log`, `git diff`, `git show`).
   - **No options, no leanings.** Never list candidate solutions, your own recommendation, or which way
     you lean — that anchors every bro to your framing and defeats the point of asking. Give the problem,
     the constraints and the facts, and let each reach its own approach. An approach already rejected goes
     in as a constraint with its reason, not as one item of a menu.
   - Explicit request for a recommendation + short rationale.
   - "Answer in bullet points, no preamble" to keep responses tight.

   Show the drafted prompt to the user only if it's ambiguous or you're unsure about scope — otherwise proceed.

2. **Write the prompt** to `ask_bros_question.txt` in your scratchpad directory (the session-specific path from your system prompt) via the Write tool. Below `$QFILE` stands for that full path.

3. **Launch all CLIs in parallel** with `run_in_background: true`. Send all Bash calls in a single message so they run concurrently:

   - Gemini: `gemini --skip-trust --allowed-tools "run_shell_command(git log)" "run_shell_command(git diff)" "run_shell_command(git show)" "run_shell_command(git blame)" -p "$(cat $QFILE)"` (without the allowlist every shell call needs confirmation, which non-interactive mode auto-denies)
   - Codex: `codex exec --sandbox read-only --skip-git-repo-check "$(cat $QFILE)" < /dev/null` (the flag is needed outside git repos; the stdin redirect stops it from waiting on piped input)
   // NOTE: GLM, and Kimi disabled temporarily, skip them
   - GLM: `opencode run -m opencode-go/glm-5.2 --agent plan "$(cat $QFILE)"`
   - Kimi: `opencode run -m opencode-go/kimi-k2.7-code --agent plan "$(cat $QFILE)"`

4. **Wait for all task-notifications.** Do NOT poll the output files — the harness re-invokes when each finishes.

5. **Read the output files** (the paths come from the task-notification messages).

   Strip the CLI noise:
   - Gemini: drop the deprecation warnings (including the `--allowed-tools` one) and "Ripgrep is not available" line at the top.
   - Codex: skip everything up to and including the echoed question; take the answer between the `codex` marker and `tokens used`.
   - opencode (GLM/Kimi): drop the `> plan · <model>` header and the `→ <Tool> ...` tool-call lines (the agent may read files first); the answer is the prose after them.

6. **Summarize for the user.** Keep it under ~400 words:
   - Each bro's recommendation and one-line rationale.
   - One or two sentences on where they agree, where they diverge.
   - Optionally: an extra opinion of yours if the bros' suggestions raise something they missed.

## Notes

- If some of the CLIs are missing on the host (`which gemini` / `which codex` / `which opencode` fails) — say so, run the available ones, and skip the rest.
- If gemini fails with a "trusted directory" error, the `--skip-trust` flag should already cover it; if not, fall back to `GEMINI_CLI_TRUST_WORKSPACE=true gemini -p ...`.
- Gemini's `--allowed-tools` is deprecated (removal in 1.0); when it goes, move the same git allowlist to a Policy Engine rule. Codex (`--sandbox read-only`) and opencode's `plan` agent already permit read-only shell without extra flags.
- Don't pipe the prompt as a shell argument directly — write to the temp file first. Shell quoting on long multi-line prompts is fragile.
