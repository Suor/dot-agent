#!/bin/bash
# Напоминание о минимальности (шаг 2/4 «Going about a task») после правки кода без фразы-подтверждения.
# Окно = записи с последнего твоего запроса. Сказал фразу в окне → молчим; иначе одно напоминание на окно.
# Любая ошибка → exit 0: баг хука НИКОГДА не должен мешать правкам.
set -uo pipefail
PHRASE='Наименьшее изменение, которое это делает'

input=$(cat) || exit 0
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null) || exit 0
[[ -z "$session_id" ]] && exit 0
jsonl=$(find "$HOME/.claude/projects" -maxdepth 2 -name "${session_id}.jsonl" 2>/dev/null | head -1)
[[ -z "$jsonl" || ! -f "$jsonl" ]] && exit 0

# Из последнего окна: была ли фраза в видимом тексте + uuid начала окна.
read -r had_phrase win < <(
    jq -rn --arg ph "$PHRASE" '
      reduce inputs as $e ({phrase:false, win:""};
        if ($e.type=="user" and ($e.promptSource=="typed" or $e.promptSource=="queued"))
          then {phrase:false, win:($e.uuid // "")}
        elif $e.type=="assistant"
          then .phrase = (.phrase or ([($e.message.content // [])[]|select(.type=="text")|.text // ""|select(contains($ph))]|length > 0))
        else . end
      ) | "\(.phrase) \(.win)"
    ' "$jsonl" 2>/dev/null
) || exit 0

[[ -z "$win" ]] && exit 0
[[ "$had_phrase" == "true" ]] && exit 0

# Одно напоминание на окно (маркер от повтора на каждой правке).
marker="$HOME/.claude/hooks-state/least_code_${session_id}.win"
[[ -f "$marker" && "$(cat "$marker" 2>/dev/null)" == "$win" ]] && exit 0
mkdir -p "$HOME/.claude/hooks-state" 2>/dev/null
printf '%s' "$win" > "$marker" 2>/dev/null

read -r -d '' REMIND <<'EOF'
You're editing code without having confirmed minimality first (step 2/4 of "Going about a task").
The edit was applied but before continuing:
1. Revisit all your edits (not just the last hunk): is every change pulling its weight? Cut what isn't.
2. Re-check all new code and process against CLAUDE.md files.
EOF

jq -n --arg r "$REMIND" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$r}}'
exit 0
