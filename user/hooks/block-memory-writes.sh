#!/usr/bin/env bash
# PreToolUse hook: forbid Write/Edit to the auto-memory directory
# (~/.claude/projects/<project>/memory/) and redirect the fact into a
# CLAUDE.md / rules file instead, preferring the most targeted, least-visible
# location.
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')

case "$file_path" in
  */.claude*/projects/*/memory/*)
    reason='Writing to auto-memory is disabled here. Persist this fact in a CLAUDE.md / CLAUDE.local.md file instead. Private files (`CLAUDE.local.md`, out of git) you may create/update proactively without asking — that is the point of this redirect. Only git-shared `CLAUDE.md` and `~/.claude/CLAUDE.md` need explicit user intent, since teammates or other projects would see them. Pick the location by these rules, in order (narrowest scope first, then prefer what stays out of git):
1. Most specific scope: a `CLAUDE.md` / `CLAUDE.local.md` in the deepest subdirectory that contains the relevant files.
2. `.claude/rules/<topic>.md` with `paths:` frontmatter — ONLY when the relevant files are spread across and nested CLAUDE.*.md won''t do the job.
3. Project root: `./CLAUDE.local.md` (private) or `./CLAUDE.md` (shared) for project-wide facts.
4. `~/.claude/CLAUDE.md` — only for important cross-project facts, and only with explicit user intent; do not write here on your own.'
    jq -n --arg r "$reason" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $r
      }
    }'
    exit 0
    ;;
esac

exit 0
