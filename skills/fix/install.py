#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
PLACEHOLDER_RE = re.compile(
    r'^!`node \$\{CLAUDE_SKILL_DIR\}/render\.js '
    r'\$\{CLAUDE_SKILL_DIR\}/SKILL\.tpl\.md "\$ARGUMENTS"`$',
    re.MULTILINE,
)


source = (HERE / "SKILL.claude.md").read_text()
replacement = subprocess.check_output(
    ["node", "./render.js", "./SKILL.tpl.md"],
    cwd=HERE,
    text=True,
)

rendered, count = PLACEHOLDER_RE.subn(lambda _: replacement, source, count=1)
if count != 1:
    raise SystemExit("placeholder not found in SKILL.claude.md")

(HERE / "SKILL.md").write_text(rendered)
