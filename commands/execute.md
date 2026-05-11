---
description: Walk an approved plan task by task with TDD discipline and fresh verification per task. Hard-gates on the plan's footer signature.
argument-hint: "[plan file path — optional, the skill auto-discovers the most recently approved plan]"
---

Invoke the `zeus:executing-plans` skill via the Skill tool. Pass these arguments to the skill: $ARGUMENTS

If `$ARGUMENTS` is empty, the skill will look up the most recently footer-signed plan under `.zeus/plans/`. If no signed plan exists, the skill will refuse to run and redirect to `zeus:writing-plans` (or `/zeus:plan`).

The skill respects every iron law: real verification command output per task, no unauthorized simplification (Logic Completeness Manifest), and full DoD sweep (G4) before handoff.
