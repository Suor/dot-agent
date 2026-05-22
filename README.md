# dot-agent

Central source of truth for local agent skills.

## Usage

Install one or more skills:

```bash
./dot-agent install claude -s fix -s browser
./dot-agent install codex -s browser
./dot-agent install all -s fix

# Legacy wrapper:
./install claude -s fix -s browser
```

Install every skill:

```bash
./dot-agent install claude --all-skills
./dot-agent install codex --all-skills
```

Preview changes without touching files:

```bash
./dot-agent install claude -s fix --dry-run
./dot-agent extract claude -s plan-hygiene --dry-run
```

Show skill status across this repo, Claude, and Codex:

```bash
./dot-agent status
```

Extract a skill from an agent home into this repo, then replace the agent-home copy
with the normal installed symlink shape:

```bash
./dot-agent extract claude -s plan-hygiene
./dot-agent extract codex -s some-skill
./dot-agent extract claude -s fix --force
```

Install targets are explicit: `claude`, `codex`, or `all`. Extract targets are
explicit too, but only one agent home can be extracted from at a time.

If an install target already exists, install stops with an error instead of moving or
merging the existing path.

If an extracted skill already exists in `skills/`, extract compares the agent-home copy
with the repo copy first. If they match, it only replaces the agent-home copy with the
installed symlink shape. If they differ, it prints a file-level change summary and stops.
Pass `--force` to extract without that check. Overlay skills such as Claude `fix`
compare and update their mapped files while preserving installer metadata.

`status` prints an alphabetically sorted table. `HERE` is `source` when the skill exists
in this repo. Agent columns use `link` for a whole-directory symlink to this repo,
`install` for a special overlay install, `copy` for copied content identical to this
repo, `changed` for copied content that differs, `new` for an agent-home skill absent
from this repo, and `-` for absent.

Restart Codex after installing skills. Codex skills are not slash commands; installing
`fix` makes the skill available to Codex, but does not create a `/fix` command.

## Skills

Skills live under `skills/`. Most skills install as a symlink of the whole directory.

If a skill needs special handling, it can include `install.toml`. For example,
`skills/fix/install.toml` declares a Claude-specific `SKILL.md` symlink and a hook that
will be installed later when settings merge exists.

See `PLAN.md` for internal design notes and future work.
