# dot-agent

Central source of truth for local agent skills.

## Usage

Install one or more skills:

```bash
./install claude -s fix -s browser
./install codex -s browser
./install all -s fix
```

Install every skill:

```bash
./install claude --all-skills
./install codex --all-skills
```

Preview changes without touching files:

```bash
./install claude -s fix --dry-run
```

Targets are explicit: `claude`, `codex`, or `all`.

If an install target already exists, install stops with an error instead of moving or
merging the existing path.

Restart Codex after installing skills. Codex skills are not slash commands; installing
`fix` makes the skill available to Codex, but does not create a `/fix` command.

## Skills

Skills live under `skills/`. Most skills install as a symlink of the whole directory.

If a skill needs special handling, it can include `install.toml`. For example,
`skills/fix/install.toml` declares a Claude-specific `SKILL.md` symlink and a hook that
will be installed later when settings merge exists.

See `PLAN.md` for internal design notes and future work.
