# /fix — Claude Code Skill

A Claude Code skill that finds all `FIX:` and `FIX0:` comments scattered across your codebase and implements them one by one.

## Purpose

Makes code and functionality review asynchronous — neither the human reviewer nor the coding agent needs to wait for each other.

A human reviews code (or an agent's output) at their own pace, dropping `FIX:` comments directly in the code wherever something needs changing. Later, user runs `/fix` and agent resolves all comments — no back-and-forth, no blocking.

Besides being async, `FIX:` comments have several advantages over chatting with coding agent:
- review in your favorite editor or IDE,
- store right there with related code, add to version control if you wish,
- won't be lost in longer contexts.

## Install

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/Suor/fix-skill.git ~/.claude/skills/fix
```

### Guard Hook (recommended)

The included `guard_fix.sh` hook prevents the agent from removing `FIX:` comments before verifying the changes or removing neighnoring `FIX:` comments that got into way. Add this to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [{
        "hooks": [
          {"type": "command",
           "command": "bash ~/.claude/skills/fix/guard_fix.sh"}
        ]
    }]
  }
}
```

## Usage

```
/fix              # implement fixes directly, no commits
/fix -c           # commit after each fix
/fix -a           # delegate each fix to a sub-agent
/fix -ac          # agents + commits
```

### Flags

| Flag | Long | Effect |
|------|------|--------|
| `-a` | `--agents` | Launch a separate agent for each fix instead. Useful if your fixes are unrelated or if you are running out of context window, somewhat wasteful otherwise  |
| `-c` | `--commits` | Auto-commit after each fix with a descriptive message. May squash it later, but protects from later passes destroying work |


### Comment Format

- **`FIX:`** — standard fix comment, processed from easiest to hardest
- **`FIX0:`** — high-priority fix, always processed first

Multi-line comments are supported.

### Example

```python
def get_user(id):
    # FIX: add input validation and return 404 instead of 500 on missing user
    return db.query(User).filter_by(id=id).one()
```

After running `/fix`, Claude will read the comment, implement the requested change, verify it with lints and tests, and remove the comment.


### Escape hatch

If agent is unable to fix the issue it adds a `RES:` comment right after it with an explanation. This prevents unhandled `FIX:` comments from being lost.
