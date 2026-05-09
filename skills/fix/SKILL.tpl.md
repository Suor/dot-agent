# Fix All FIX: Comments

Find and implement all `FIX:` and `FIX0:` comments in the codebase, then fix them one by one.

## Step 1: Find All FIX Comments

Use Grep to search for `\bFIX\d*:` across ALL files (any type — code, markdown, config, etc.). Collect every match with its file path, line number, and the full comment text. Include multi-line FIX comments (read surrounding lines for context).

## Step 2: Sort Them

Sort the collected FIX comments:
1. **FIX0** comments go first (they are highest priority)
2. Among remaining FIX comments, sort from **easiest to hardest** to implement based on your assessment of scope and complexity

## Step 3: Create Todo Items

Create a todo item for each FIX comment using the TaskCreate tool. This gives visibility into progress.

## Step 4: Implement Fixes One by One

For each FIX comment, **sequentially** (never in parallel):

#. Mark the todo item as in_progress
{-a/--agents?agents:no-agents}
{-c/--commits?commits}
#. Mark the todo item as completed

## Important Rules

- **NEVER remove a FIX comment unless the issue it describes is actually fixed**
- If a fix cannot be fully implemented, add a `RES:` comment below the FIX comment explaining what was tried, what blocked it, and what alternatives were considered — but try hard before resorting to this. Do NOT remove FIX comment in this case
- Process fixes strictly one at a time
- If a FIX comment references other FIX comments or depends on them, handle dependencies in order

{$rest -a/--agents -c/--commits}

--- parts

agents:
#. Launch a **separate agent** using the Agent tool (`subagent_type: "general-purpose"`) to implement the fix:
   - Give the agent the full FIX comment text, file path, line number, and surrounding context
   - The agent prompt MUST include these instructions:
     - Read the file and understand the FIX comment
     - Implement the fix properly — give it a real effort
     - Run relevant tests/linting to verify the fix doesn't break anything
     - Only AFTER tests pass, remove the FIX comment. Never remove it before confirming the fix works
   - Do NOT insert presuppositions about the solution — let agent explore for itself
   - **Do NOT** tell the agent to give up easily — agents should try hard to implement the fix
#. Wait for the agent to complete before moving to the next fix

no-agents:
#. Implement the fix directly:
   - Read the file and understand the FIX comment
   - Implement the fix properly — give it a real effort
   - Run relevant tests/linting to verify the fix doesn't break anything
   - Only AFTER tests pass, remove the FIX comment. Never remove it before confirming the fix works

commits:
#. After the fix is complete, commit the changes with a descriptive message: `git add <files...> && git commit -m "<message>"`. Stage only the files changed for that fix.
