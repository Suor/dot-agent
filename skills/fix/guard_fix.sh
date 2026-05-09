#!/bin/bash
# PreToolUse hook: block removal of FIX:/FIX0: comments when bundled with code changes.
# Pure FIX-comment-removal edits (after tests pass) are allowed.

set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ]; then
    exit 0
fi

old_string=$(echo "$input" | jq -r '.tool_input.old_string // empty')
new_string=$(echo "$input" | jq -r '.tool_input.new_string // empty')

# Count FIX comments in old vs new
old_count=$(echo "$old_string" | grep -cP '\bFIX\d*:' || true)
new_count=$(echo "$new_string" | grep -cP '\bFIX\d*:' || true)

# No FIX comments removed — nothing to guard
if [ "$old_count" -le "$new_count" ]; then
    exit 0
fi

# FIX comment(s) are being removed. Check if new_string introduces any lines
# not present in old_string. If it does — code was changed alongside removal — block.
# If not — it's a pure deletion of comment lines — allow.
has_new_content=false
while IFS= read -r line; do
    [ -z "$line" ] && continue
    if ! grep -qFx -- "$line" <<< "$old_string"; then
        has_new_content=true
        break
    fi
done <<< "$new_string"

if [ "$has_new_content" = true ]; then
    echo '{"decision": "block", "reason": "BLOCKED: You are removing a FIX comment AND changing code in the same Edit. This must be three separate steps: (1) implement the fix keeping the FIX comment, (2) verify with tests/lints/self review, (3) only then remove the FIX comment (or add RES: if the fix failed) in a separate edit."}'
    exit 0
fi

# Pure FIX comment removal (no other changes) — allowed
exit 0
