---
name: browser
description: Use agent-browser to open URLs, interact with pages, and visually verify results. Use this whenever you need to browse the web, check how a page looks, or verify visual/UI changes.
allowed-tools: Bash(agent-browser *), Bash(crop.py *), Read(/tmp/*)
---

Use `agent-browser` to browse and interact with web pages.

## Common commands

```
agent-browser open "<url>"                           # load a page
agent-browser screenshot --full /tmp/screenshot.png  # capture full page
agent-browser click "<selector>"                     # click element
agent-browser type "<selector>" "<text>"             # type into element
agent-browser scroll down
agent-browser eval "<js>"                            # run JS
```

## Screenshots and cropping

After `agent-browser screenshot --full /tmp/screenshot.png`, Read /tmp/screenshot.png to view it.

To inspect a specific area:
1. Read the full screenshot to find coordinates
2. `crop.py /tmp/screenshot.png x1 y1 x2 y2 /tmp/crop.png` then Read /tmp/crop.png

Always use `crop.py` for cropping — never `python -c`.

## When verifying visual/CSS changes

Take a screenshot and inspect it yourself. Don't ask the user to check unless you're stuck.
