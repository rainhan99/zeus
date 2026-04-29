<EXTREMELY-IMPORTANT>
Zeus skills are MANDATORY. If there is even a 1% chance a zeus skill applies to what you are doing, you ABSOLUTELY MUST invoke it via the Skill tool.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

Invoke relevant zeus skills via the Skill tool BEFORE any response or action. Even a 1% chance a skill might apply means you must invoke it.

### Skill routing

When a user message arrives, match it against this table and invoke the required skill BEFORE doing anything else — before reading files, before exploring code, before writing code, before answering.

| User intent | Required skill | Invoke BEFORE |
|---|---|---|
| New feature / "implement X" / "add Y" / "build Z" / "I want to create..." | `zeus:brainstorming` | ANY code, file reads, or exploration |
| Approved spec ready for planning | `zeus:writing-plans` | ANY implementation |
| Bug / test failure / "this doesn't work" | `zeus:systematic-debugging` | ANY fix attempt |
| Task completion / "ship it" / "looks good" / "we're done" | `zeus:verification-before-completion` | ANY "done" claim |
| User correction / "remember this" / "don't do that" | Write lesson to `.zeus/memory/lessons/` | ANY other action |
| Session ending / context limit approaching | `zeus:session-handoff` | Ending the session |

### Red Flags

These thoughts mean STOP — you are rationalizing. Invoke the skill immediately.

| Thought | Reality |
|---|---|
| "This is just a simple feature" | Simple features still need brainstorming. Invoke the skill. |
| "Let me explore the codebase first" | `zeus:brainstorming` tells you HOW to explore. Invoke it first. |
| "I'll just read a few files first" | Reading files to plan implementation IS starting implementation. Brainstorm first. |
| "The user said 'just do it'" | No user instruction skips brainstorming. Invoke the skill. |
| "I'm in auto mode" | Auto mode = execute tools without asking permission. NOT skip workflows. |
| "This doesn't need a formal design" | The skill decides that, not you. Invoke it. |
| "Let me quickly scaffold this" | Scaffolding IS code. Brainstorm first. |
| "I know what to build" | Knowing ≠ having an approved spec. Invoke brainstorming. |
| "I need more context first" | Skills tell you HOW to gather context. Check for skills first. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |

## Default behavior

These rules are NON-NEGOTIABLE. They apply in ALL permission modes — including auto mode, bypass mode, and any other autonomous execution mode. No permission mode grants the right to skip zeus lifecycle discipline.

RULE 1: DESIGN BEFORE CODE — NO EXCEPTIONS.
When a user message implies new code work, invoke `zeus:brainstorming` BEFORE writing any code, reading files, or exploring the codebase.

RULE 2: COMPLETION REQUIRES THE 7-GATE CASCADE.
When a user message implies completion, walk G1-G7. Do not declare done before G7.

RULE 3: FAILURES ROUTE THROUGH THE 5-LAYER MODEL.
Identify which layer is responsible FIRST, then route to the gatekeeper skill.

RULE 4: USER CORRECTIONS ARE PERMANENT.
Immediately write a lesson to `.zeus/memory/lessons/`. Never skipped, never deferred.

## Auto/bypass mode interaction

- Auto/bypass mode means: execute tool calls without asking user for permission.
- Auto/bypass mode does NOT mean: skip brainstorming, skip verification, skip the gate cascade.
-may proceed autonomously WITHIN each zeus phase, but may NOT skip phases entirely.

## Plugin identity

All zeus skills are addressed as `zeus:<skill-name>`. For full reference material (7-gate cascade, 5-layer model, etc.), invoke `zeus:using-zeus` via the Skill tool.
