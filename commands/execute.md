---
description: Walk an approved plan task by task with TDD discipline and fresh verification per task. Hard-gates on the plan's footer signature.
argument-hint: "[plan file path — optional, the skill auto-discovers the most recently approved plan]"
---

Before invoking any skill, perform mode routing — `/zeus:execute` is the one zeus command that carries logic. Follow these steps in order:

1. **Resolve the plan file.** If `$ARGUMENTS` already names a plan path, use it; otherwise, list `.zeus/plans/*.md` and pick the most recently footer-signed file (`grep -l 'User-approved:' .zeus/plans/*.md | tail -1`). If none exists, refuse: "No footer-signed plan found. Run `/zeus:plan` first."

2. **Parse plan Section 4 (Tasks)** to extract two signals:
   - `tasks`: count task headings (`^### Task` lines), table rows (`^| Task`), or numbered bullets — whichever shape the plan uses.
   - `files_signal`: true iff **every** task block contains at least one line matching `^[Ff]iles:` with one or more comma-separated paths. Mixed (some present, some absent) counts as false.

3. **Ask the user which mode** via `AskUserQuestion`:
   - Question: "How should this plan execute?"
   - Header: "Execution mode"
   - Options (single-select):
     - `auto (Recommended)` — pick based on plan shape (task count + file independence).
     - `sequential` — one task at a time in the current session (`zeus:executing-plans`).
     - `subagent` — one fresh subagent per task with two-stage review (`zeus:subagent-driven-development`).

4. **If user picked `auto`, compute the recommendation:**
   ```
   if files_signal:
       overlap = any two tasks share a path in their Files: lines?
       recommend = "subagent" if (not overlap and tasks >= 3) else "sequential"
   else:
       recommend = "subagent" if tasks >= 4 else "sequential"
   ```
   Print one line stating the recommendation and why (e.g., "5 tasks, no Files signal → recommend subagent"). If `recommend == "subagent"`, ask a confirm via `AskUserQuestion` (single-select, two options: `proceed with subagent` / `fall back to sequential`); on fall-back, set the mode to `sequential`. If `recommend == "sequential"`, dispatch silently.

5. **Dispatch** by invoking the matching skill via the `Skill` tool, passing the original `$ARGUMENTS` (preserving any user-supplied plan path) with `mode-resolved=<mode>` appended (space-separated).

   Example: if the user invoked `/zeus:execute .zeus/plans/foo.md` and the resolved mode is `sequential`, the args passed to the skill are `.zeus/plans/foo.md mode-resolved=sequential`.

   - mode `sequential` → invoke `zeus:executing-plans`.
   - mode `subagent` → invoke `zeus:subagent-driven-development`.

The skills respect every iron law: real verification command output per task, no unauthorized simplification (Logic Completeness Manifest), and full DoD sweep (G4) before handoff.
