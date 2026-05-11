---
description: Turn an approved brainstorming spec into a bite-sized implementation plan with per-task TDD steps and a footer-signed approval gate.
argument-hint: "[spec file path or topic — optional, the skill auto-discovers from .zeus/state/spec-approved if omitted]"
---

Invoke the `zeus:writing-plans` skill via the Skill tool. Pass these arguments to the skill: $ARGUMENTS

If `$ARGUMENTS` is empty, the skill will look up the most recently approved spec from `.zeus/state/spec-approved`. If no approved spec exists, the skill will refuse to run and redirect to `zeus:brainstorming` (or `/zeus:brainstorm`).
