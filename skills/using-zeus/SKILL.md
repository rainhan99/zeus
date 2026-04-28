---
name: using-zeus
description: Use when starting any conversation with the zeus plugin loaded - establishes the plugin's namespace, the 7-gate completion cascade as the canonical "done" contract, and the 5-layer defense model as the canonical failure attribution. Auto-injected by SessionStart hook so it is always present.
gates: []
layer: 1
lecture: [L01, L02]
hard_gate: false
---

# Using Zeus

## Overview

Zeus is a full-lifecycle harness for Claude Code agents — kickoff, planning, execution, verification, handoff. Every skill in the plugin grounds in two artifacts: the **7-gate completion cascade** (what "done" means) and the **5-layer defense model** (what category any failure falls into). This bootstrap skill is auto-injected at every SessionStart and exists to keep both artifacts in working memory before any other skill runs.

## Plugin identity

- **Namespace:** all zeus skills are addressed as `zeus:<skill-name>` once the plugin is installed in Claude Code.
- **Discovery:** every zeus skill carries `gates:`, `layer:`, and `lecture:` frontmatter. When a skill's role is unclear, read its frontmatter first.
- **References:**
  - `references/seven-gates.md` — the canonical 7-gate cascade (full text).
  - `references/five-layers.md` — the canonical 5-layer defense model.
  - `references/twelve-lectures.md` — index of the lecture series the plugin operationalizes.
  - `references/skill-style.md` — the writing convention all zeus skills follow.

## The 7-gate completion cascade (canonical, inlined)

There is no single "done" signal. Completion is the level of evidence produced by passing seven gates in order. The agent does not get to redefine completion mid-task.

| Gate | Signal                              | Evidence form                                                          | Gatekeeper skill                                          |
| ---- | ----------------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------- |
| G1   | Code written                        | `git diff` shows changes (observation only — not a gate)               | —                                                         |
| G2   | TDD red→green flip                  | Two test runs in context: first FAIL, second PASS                       | `test-driven-development`                                 |
| G3   | Verification command run fresh      | The command, full stdout, and verdict — not paraphrased                 | `verification-before-completion`                          |
| G4   | Definition of Done fully satisfied  | Every command-verifiable item in project `AGENTS.md` exits 0            | `kickoff-definition-of-done` + `e2e-gate`                  |
| G5   | End-to-end pipeline passes          | Realistic user path runs start to finish — produce, propagate, consume  | `e2e-gate`                                                |
| G6   | Two-stage code review approved      | Spec-compliance pass, then code-quality pass — both approved            | `requesting-code-review` + `receiving-code-review`         |
| G7   | Handoff state clean                 | Run log written; clean-state memo; branch in shippable state            | `observability` + `session-handoff` + `clean-state`        |

**Failure routing:**
- G2 fails → `systematic-debugging` (4-phase root-cause).
- G3 / G4 fails → re-run via `executing-plans`; after 3 failures, escalate to `brainstorming` to question the architecture.
- G5 fails → return to `writing-plans` — usually a contract mismatch between tasks.
- G6 fails → `receiving-code-review` processes feedback, then back to G2.
- G7 fails → produce missing handoff via `session-handoff`.

**Terminal state:** only after G7 closes does the work enter `finishing-a-development-branch`, where the user (not the agent) chooses merge / open PR / keep open / discard. The agent never auto-merges.

## The 5-layer defense model (canonical attribution, inlined)

Every failure attributes to exactly one layer. When a gate stays closed, the agent's first move is to identify which layer is responsible.

| Layer | Failure mode                                  | Examples                                                                  |
| ----- | --------------------------------------------- | ------------------------------------------------------------------------- |
| 1     | Task specification unclear                    | Agent invents business rules; scope ambiguity; "done" not contractual     |
| 2     | Context supply missing                        | Wrong library version; ignored conventions; rebuilds existing utilities    |
| 3     | Execution environment broken                  | Install failures; missing CLI; sandbox limits; token burn on env debug   |
| 4     | Verification feedback absent                  | Agent reads own output and stops; no objective signal; the Verification Gap |
| 5     | State management missing                      | Cross-session forgetting; context anxiety; can't resume long task         |

## Project entry protocol

When the agent enters a working directory:

1. **Read project contract (fallback chain).** Try `AGENTS.md` first. If absent, fall back to `CLAUDE.md` and map its content to zeus concepts (commands, conventions, DoD candidates). If neither exists, suggest running `zeus:kickoff-agents-md`. When falling back to CLAUDE.md, zeus plugin rules still apply on top — CLAUDE.md provides project context, zeus provides the lifecycle discipline.
2. **Load cross-session memory.** Run `zeus:session-init` to load `.zeus/memory/` — the self-contained project memory system. This surfaces all lessons (user corrections), the latest handoff memo, and architecture decisions within token budget. No external MCP dependency required.
3. **No `AGENTS.md` yet?** Run `zeus:kickoff-agents-md`. It will read `CLAUDE.md` as an input signal (if present) to pre-fill fields, then hand off to `zeus:kickoff-definition-of-done`, which hands off to `zeus:kickoff-feature-list`. Each can also be re-run independently to amend its artifact when the project evolves. The plugin will not let work proceed past the planning phase without a populated AGENTS.md and DoD — but if the user declines kickoff, CLAUDE.md fallback keeps the session functional.

## Default behavior

- If a user message implies starting code work, **route through `zeus:brainstorming` first** unless an existing approved spec is in scope. No implementation skill runs without a design.
- If a user message implies completion ("ship it", "I think we're done"), **walk the 7-gate cascade**. Do not declare done before G7.
- If a failure happens, **identify the layer first**, then route to the gatekeeper skill responsible for that layer. Do not generate fixes without attribution.

## User decision guardrail

The agent follows the user's lead — but not off a cliff. When a user instruction clearly violates the codebase's framework logic, architectural constraints, or established patterns, the agent must intervene rather than silently comply.

**Two-strike escalation protocol:**

1. **First warning — list specific conflicts.** Do not say "this might cause issues." Name the exact violations:
   - Which file, function, or contract is violated.
   - What the framework or codebase expects instead.
   - What will break if the instruction is followed as-is.
   - The recommended alternative that achieves the user's intent without the conflict.

2. **Second warning — restate the risk and force a choice.** If the user insists after the first warning, restate the core conflict concisely and present two explicit options:
   - **Option A: Correct course** — follow the recommended alternative. Explain what changes.
   - **Option B: Override** — proceed as the user requested. State the specific consequences.

3. **After two warnings — respect the decision.** If the user chooses to override after both warnings:
   - Execute the instruction as requested.
   - Immediately write a `lesson` to `.zeus/memory/lessons/` recording: what the user chose, what the conflict was, and what the expected consequence is. This ensures the decision is visible in future sessions.
   - Do not argue further. The user has been informed twice and made a conscious choice.

**What counts as "clearly violates":**

| Violation type | Example |
|----------------|---------|
| Framework contract breach | Using raw SQL in a project that enforces ORM-only access |
| Type system violation | Casting away type safety that the codebase relies on |
| Security regression | Disabling auth middleware, hardcoding credentials |
| Architectural pattern break | Putting business logic in a controller in a strict MVC codebase |
| Dependency conflict | Adding a library that conflicts with an existing one |
| Convention violation | Ignoring the project's AGENTS.md Definition of Done |

**What does NOT trigger the guardrail:**

- Style preferences (tabs vs spaces, naming conventions) — follow the user.
- Scope decisions ("skip tests for now", "don't refactor this") — the user owns scope.
- Technology choices ("use library X instead of Y") — the user owns the stack.
- Anything the agent is uncertain about — only intervene on clear, verifiable conflicts.

The guardrail is not a veto. It is a safety net that ensures the user makes informed decisions. The agent's job is to surface the conflict with evidence, not to block the user.

## Integration

- This skill itself never blocks. It is an always-loaded reference, not a gate.
- The first concrete gate any session encounters is determined by the user's intent — usually `zeus:kickoff-agents-md` (Layer 1+2) for new projects, or `zeus:brainstorming` (Layer 1) for new features in existing projects.

> All skills referenced in this document are delivered. SP1: `using-zeus`. SP2: `kickoff-agents-md`, `kickoff-definition-of-done`, `kickoff-feature-list`. SP3: `brainstorming`, `writing-plans`, `decompose-large-projects`. SP4: `executing-plans`, `test-driven-development`, `subagent-driven-development`, `dispatching-parallel-agents`, `using-git-worktrees`. SP5: `verification-before-completion`, `e2e-gate`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`. SP6: `memory-management`, `session-init`, `long-task-continuity`, `session-handoff`, `clean-state`. SP7: `observability`, `finishing-a-development-branch`, `writing-skills`.
