# Plan

This repository is the source of truth for local agent skills and, later, reusable
configuration fragments.

## Current Scope

The first implemented scope is skill installation for Claude Code and Codex.

Settings are intentionally out of scope for now. Later, installation should manage
individual setting fragments, such as allowed command lists or hook entries, rather than
owning full settings files.

## Skill Layout

Most skills are plain directories under `skills/`:

```text
skills/<name>/SKILL.md
```

The default installation behavior for such skills is a symlink of the whole directory:

```text
~/.claude/skills/<name> -> <repo>/skills/<name>
~/.codex/skills/<name>  -> <repo>/skills/<name>
```

If a skill needs special handling, it may include `install.toml`. The installer reads
that file and applies declared additions while keeping the normal symlink behavior where
possible. If `script` is declared, the installer runs that script in the skill before
installing it.

## Special Cases

`skills/fix` is currently the only expected special case.

The copied `SKILL.md` is the current Claude Code skill. A separate `SKILL.claude.md`
copy is present so the installer can point Claude at that file if `SKILL.md` becomes a
simpler portable/Codex default.

For agents that need a different `SKILL.md`, the installer creates a real target
directory and symlinks individual files:

```text
~/.claude/skills/fix/SKILL.md     -> <repo>/skills/fix/SKILL.claude.md
~/.claude/skills/fix/render.js    -> <repo>/skills/fix/render.js
~/.claude/skills/fix/SKILL.tpl.md -> <repo>/skills/fix/SKILL.tpl.md
~/.claude/skills/fix/guard_fix.sh -> <repo>/skills/fix/guard_fix.sh
```

The same overlay mechanism is used for Codex:

```text
~/.codex/skills/fix -> <repo>/skills/fix
```

For `fix`, `install.sh` currently prepares the generated `SKILL.md` by copying
`SKILL.claude.md`. The generated `SKILL.md` is ignored by git.

Hooks are declared by the skill but installed by the agent-specific installer. The skill
does not know how Claude or Codex store hook settings.

Multiple hooks in TOML use repeated array-of-table blocks:

```toml
[[hooks]]
type = "PreToolUse"
command = "guard_fix.sh"

[[hooks]]
type = "PermissionRequest"
command = "read_allow.sh"
```

Agent-specific hooks may be added later with nested tables:

```toml
[[claude.hooks]]
type = "PreToolUse"
command = "guard_fix.sh"
```

## Install Contract

Installer behavior:

1. Discover `skills/*`.
2. If `install.toml` is absent, symlink the whole skill directory.
3. If `install.toml` has `script`, run that script before installing.
4. If `install.toml` is present, apply its agent-specific overrides.
5. Do not overwrite existing user files or directories. Stop with a clear message.
6. Do not manage complete agent settings files; only merge targeted fragments.


## Future CLI

Keep the current root `./install` script for now. If the tool grows, a later CLI may
become:

```bash
dot-agent install codex -s fix
dot-agent extract claude -s new-skill
dot-agent check claude
```

Future commands:

- `install`: install from repo into agent home.
- `extract`: copy from agent home into repo, without regenerating. If a skill already
  exists, require `--force` or print a diff/report.
- `check`: read-only verification. Show what is installed correctly, what exists in repo
  but is not installed, what exists in the agent but is unknown to repo, wrong targets,
  real dirs where symlinks are expected, broken symlinks, and special-case warnings.

No implicit `all`: installing to every supported agent should remain explicit.
