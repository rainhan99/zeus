# Reference: 5-Layer Defense Model

[TOC]

The 5-layer model is the failure taxonomy zeus uses to attribute every observed agent failure to a specific harness layer. Every skill in the plugin carries a `layer:` frontmatter integer pointing at the single layer it primarily defends.

Origin: lecture L01 of the harness-engineering series. The model is explicitly diagnostic — when an agent fails, find which layer was missing or broken and patch that layer, rather than blaming the model.

## The five layers

### Layer 1: Task specification

The agent does not have an unambiguous, written description of what success means. Symptoms: agent invents business rules, makes scope decisions without authority, confuses the user's stated request with their actual goal.

Defended by: `kickoff-definition-of-done`, `kickoff-feature-list`, `brainstorming`, `writing-plans`.

### Layer 2: Context supply

The agent does not have access to the project-specific knowledge a human teammate would have. Symptoms: uses wrong library version, ignores existing patterns, re-implements a utility that already exists.

Defended by: `kickoff-agents-md`, `session-init`, claude-mem detection adapter.

### Layer 3: Execution environment

The agent's runtime does not give it the tools and dependencies it needs to do the task. Symptoms: pip install failures, wrong Node version, missing CLI binary, sandbox missing network access. Token budget burned on environment debugging instead of work.

Defended by: `using-git-worktrees`, environment-prep guidance in `kickoff-agents-md`.

### Layer 4: Verification feedback

The agent has no objective signal that its work is correct. Symptoms: agent reads its own output, declares "looks good", and stops. The Verification Gap.

Defended by: `verification-before-completion`, `e2e-gate`, `test-driven-development`, `requesting-code-review`, `receiving-code-review`, `systematic-debugging`.

### Layer 5: State management

The agent loses or never had the state needed to continue work that spans multiple turns or sessions. Symptoms: redoing solved problems, forgetting decisions, abandoning long tasks before completion ("context anxiety"), inability to resume after a crash.

Defended by: `long-task-continuity`, `session-handoff`, `clean-state`, `observability`, claude-mem detection adapter.

## How a skill picks its layer

Pick the single layer whose failure mode the skill *primarily* prevents. Skills that span multiple layers should still pick one as primary; their other layers go in the body's `Integration` section, not in the frontmatter.

## Cross-references

- 12 lectures → `references/twelve-lectures.md`
- 7-gate completion cascade → `references/seven-gates.md`
- Skill writing convention → `references/skill-style.md`
