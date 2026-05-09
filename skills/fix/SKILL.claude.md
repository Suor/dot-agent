---
name: fix
description: "Find and implement all FIX: and FIX0: comments in the codebase"
disable-model-invocation: true
allowed-tools: Bash(node */fix/render.js *), Bash(git add *), Bash(git commit *)
---

!`node ${CLAUDE_SKILL_DIR}/render.js ${CLAUDE_SKILL_DIR}/SKILL.tpl.md "$ARGUMENTS"`
