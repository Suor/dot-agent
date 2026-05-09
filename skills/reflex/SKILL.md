---
name: reflex
description: Evaluate the current session — check if goals were achieved, side-effects introduced, verifications applied, code quality is good, AND surface durable process lessons (where Claude went wrong before user corrected)
allowed-tools: Bash(git diff *), Bash(git log *)
---

# Session Reflection

Launch a subagent to critically evaluate this session — both the **product** (final code/files: correctness, side-effects, quality) and the **process** (where the user had to course-correct, where Claude assumed without measuring).

## Step 1: Gather Context and Launch Evaluation Agent

**The subagent starts cold — it does NOT see this conversation.** Whatever you don't put in the prompt, it cannot reason about. Be detailed where it matters.

Summarize this session from your own context — you have the full conversation history. Collect:
- The user's goals (initial request and any adjustments made along the way)
- What actions were taken, what files were changed
- What verification steps were run (and when — before or after last code change)
- **Concrete user corrections** — not a one-liner summary, a list of distinct moments. For each: (a) what approach Claude took initially, (b) what the user said, (c) what was changed. These are the evidence for question 5 below; without them the agent has nothing to analyze.
- **Cases where Claude claimed something (a performance ranking, a "this is faster", a design recommendation) without measurement, and was wrong** — also evidence for question 5.

If the session involved code changes, collect the diff (git diff, reading changed files, etc.).

Launch a **single agent** (`subagent_type: "general-purpose"`) with the summary and diffs.

The agent must go through each question below in order. For each question, use the session history as evidence — don't summarize the history, answer the question. Only report findings where there is an actual problem; stay silent on questions with no issues. Don't say "need to check X" — check it first, then report. If everything is fine across all questions, say so briefly.

### 1. Goal Achievement
- Was the user's goal fully achieved? Were any parts missed or only partially done?

### 2. Side Effects
- Were any existing behaviors broken?
- Were any files changed that didn't need to be?
- Were any unrelated changes introduced?

### 3. Verification
- Were relevant verification steps applied (tests, lints, type checks, manual review, or any custom checks from CLAUDE.md)?
- **Critically**: were verifications run AFTER the last code change, or only before?
- If no verification was done at all, flag this prominently

### 4. Code Quality
- Does the new/changed code look correct and complete?
- Are edge cases handled?
- If the change warrants tests — were they added?
- If the change warrants docs — were they updated?
- Will this code cause issues in the future (fragility, missing error handling at boundaries, etc.)?

### 5. Process / Lessons Learned
- For each user-correction moment in the brief: was the underlying mistake a one-off slip, or does it reflect a habit / class of error worth flagging?
- For each "claimed without measuring" moment: same — habit or one-off?
- Group recurring patterns into 2–6 durable rules ("don't write self-made wrappers if a project class exists", "don't claim a perf ranking without microbench", etc.) — generalize beyond the specific topic so the lesson is reusable.
- Skip lessons that are already documented in the codebase (CLAUDE.md, PLAN.md, etc.) — focus on lessons that would apply across **other** projects/sessions.
- If the brief contains no concrete corrections — say so; don't fabricate.

## Step 3: Present Results

Show the agent's report to the user as-is. Do not editorialize or soften the findings.

Additional user instructions (if any): $ARGUMENTS
