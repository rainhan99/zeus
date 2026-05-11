# Zeus — Harness Engineering Lifecycle for Claude Code

Zeus is a Claude Code plugin that turns a 12-lecture harness-engineering curriculum into 25 actionable skills covering the full agent lifecycle: kickoff, planning, execution, verification, handoff. Grounded in the 7-gate completion cascade and the 5-layer defense model.

## Concepts

- **7-gate completion cascade** (`references/seven-gates.md`) — the canonical answer to "what does done mean?". G1 (code written) → G7 (handoff state clean), each producing verifiable evidence.
- **5-layer defense model** (`references/five-layers.md`) — failure taxonomy: every agent failure attributes to one of five harness layers.
- **12 lectures** (`references/twelve-lectures.md`) — the source curriculum from harness-engineering.
- **Skill writing convention** (`references/skill-style.md`) — the contract every zeus skill follows.

## Install

```bash
# In a Claude Code session — add the marketplace source, then install:
/plugin marketplace add rainhan99/zeus
/plugin install zeus@zeus-marketplace
```

Or from a local clone:

```bash
git clone https://github.com/rainhan99/zeus.git
# In a Claude Code session:
/plugin marketplace add ./zeus
/plugin install zeus@zeus-marketplace
```

After install, every new conversation auto-loads `using-zeus` via the SessionStart hook, anchoring the 7-gate cascade and 5-layer model in working memory.

## Skills (25)

### SP1: Bootstrap
| Skill | Purpose |
|-------|---------|
| `using-zeus` | Auto-injected at session start. Anchors the 7-gate cascade, 5-layer model, project entry protocol, and user decision guardrail. |

### SP2: Kickoff
| Skill | Purpose |
|-------|---------|
| `kickoff-agents-md` | Generates AGENTS.md by scanning repo signals + interviewing the user. |
| `kickoff-definition-of-done` | Refines DoD into command-verifiable items. |
| `kickoff-feature-list` | Produces FEATURES.md — per-feature roadmap with stable IDs. |

### SP3: Discovery & Planning
| Skill | Purpose |
|-------|---------|
| `brainstorming` | Design-before-code. Explores options, produces a spec for user approval. |
| `writing-plans` | Converts approved specs into sequenced, testable task plans. |
| `decompose-large-projects` | Splits large projects into independent sub-projects. |

### SP4: Execution Engine
| Skill | Purpose |
|-------|---------|
| `executing-plans` | Sequential plan executor with 3-failure architectural escalation. |
| `test-opment` | G2 gatekeeper. TDD red→green→refactor with ecosystem-standard tooling. |
| `subagent-driven-development` | Subagent-per-task executor with two-stage review. |
| `dispatching-parallel-agents` | Multi-problem parallelizer with independence verification. |
| `using-git-worktrees` | Workspace isolation via git worktrees. |

### SP5: Verification & Quality
| Skill | Purpose |
|-------|---------|
| `verification-before-completion` | G3 gatekeeper. No completion claims without fresh verification evidence. |
| `e2e-gate` | G4+G5 gatekeeper. DoD sweep + end-to-end pipeline. |
| `systedebugging` | 4-phase root-cause debugging with senior-architect fix discipline. |
| `requesting-code-review` | G6 request side. Dispatches structured two-stage review. |
| `receiving-code-review` | G6 response side. Verify before implementing, push back when wrong. |

### SP6: Session Continuity
| Skill | Purpose |
|-------|---------|
| `memory-management` | Self-contained project memory in `.zeus/memory/` with LLMLingua-inspired tiered compression. |
| `session-init` | Session startup: loads memory, restores handoff, surfaces lessons. AGENTS.md → CLAUDE.md fallback chain. |
| `long-task-continuity` | Periodic checkpointing and re-anchoring fs. |
| `session-handoff` | G7 gatekeeper (write side). Produces handoff memo. |
| `clean-state` | G7 gatekeeper (clean side). Ensures branch is shippable. |

### SP7: Observability & Finish
| Skill | Purpose |
|-------|---------|
| `observability` | G7 gatekeeper (audit side). Structured run log with gate status and feature attribution. |
| `finishing-a-development-branch` | Terminal state after G7. Four options: merge / PR / keep / discard. Agent never auto-merges. |
| `writing-skills` | Meta-skill for creating new zeus skills. Skeleton template + validation. |

## Key behaviors

- **User decision guardrail** — when user instructions violate codebase logic, the agent warns twice with specific conflicts before proceeding. Override decisions are recorded as lessons.
- **Ecosystem-standard tooling** — ESLint, Ruff, cargo clippy, golangci-lint, etc. Never roll custom scripts when standard tools exist.
- **Senior-architect fix discipline** — root-cause analysis, best-practice research, codebase-wide pattern scan. Proactively ask user to fix all similar issues at once.
- **Instant lesson capture** — user corrections are immediately written to `.zeus/memory/lessons/`, never compressed, never evicted, loaded every sess## Repository layout

```text
zeus/
├── .claude-plugin/      # plugin and marketplace manifests
├── skills/              # 25 zeus skills
├── hooks/               # SessionStart bootstrap
├── references/          # canonical reference docs (7 gates, 5 layers, 12 lectures, skill style)
└── templates/           # boilerplate for kickoff-agents-md
```

## Upgrading from pre-relocation zeus

If you're upgrading from a zeus version that wrote artifacts under `docs/specs/`, `docs/plans/`, or kept `FEATURES.md` at the project root, run the one-shot migration once per project:

```bash
bash scripts/migrate-to-dotzeus.sh
git commit -m "chore: migrate zeus artifacts to .zeus/"
```

The script is idempotent — re-running it after the move is a no-op. It uses `git mv` to preserve history. After migration, all plugin-generated artifacts live under `.zeus/` (`.zeus/specs/`, `.zeus/plans/`, `.zeus/features.md`, `.zeus/memory/`, `.zeus/state/`). The only zeus-related files at the project root are your `CLAUDE.md` or `AGENTS.md` contract.

## License

MIT — see `LICENSE`.
