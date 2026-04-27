# Zeus — Harness Engineering Lifecycle for Claude Code

Zeus is a Claude Code plugin that operationalizes a 12-lecture harness-engineering curriculum into a coherent set of skills covering the full project lifecycle: kickoff, planning, execution, verification, handoff.

## Status

**SP1 of 7 — skeleton only.** This sub-project ships the plugin manifest, the SessionStart bootstrap, and the four canonical reference docs (7 gates, 5 layers, 12 lectures, skill style). No process skills are delivered yet; SP2–SP7 add them incrementally. See `docs/specs/` for the per-sub-project specs.

## Concepts

- **7-gate completion cascade** (`references/seven-gates.md`) — the canonical answer to "what does done mean?". G1 → G7, each producing verifiable evidence.
- **5-layer defense model** (`references/five-layers.md`) — the failure taxonomy used to attribute every observed failure to a specific harness layer.
- **12 lectures** (`references/twelve-lectures.md`) — the source curriculum.
- **Skill writing convention** (`references/skill-style.md`) — the contract every zeus skill follows.

## Install (local development)

```text
# In a Claude Code session:
/plugin marketplace add /Users/soar/zeus
/plugin install zeus
```

After install, every new Claude Code conversation auto-loads `using-zeus` via the SessionStart hook, anchoring the 7-gate cascade and 5-layer model in working memory.

## Repository layout

```text
zeus/
├── .claude-plugin/      # plugin and marketplace manifests
├── skills/              # zeus skills (SP1 ships only using-zeus)
├── hooks/               # SessionStart bootstrap
├── references/          # canonical reference docs
├── templates/           # boilerplate consumed by SP2 kickoff-agents-md
├── docs/specs/          # one spec per sub-project
├── docs/plans/          # one implementation plan per sub-project
└── AGENTS.md            # zeus's own dev contract (dogfooding)
```

## Sub-project roadmap

| #   | Sub-project                                    | Status      |
| --- | ---------------------------------------------- | ----------- |
| SP1 | Skeleton & writing convention                  | in progress |
| SP2 | Kickoff (AGENTS.md / DoD / feature list)       | pending     |
| SP3 | Discovery & Planning                           | pending     |
| SP4 | Execution Engine                               | pending     |
| SP5 | Verification & Quality                         | pending     |
| SP6 | Session Continuity                             | pending     |
| SP7 | Observability & Finish                         | pending     |

## License

MIT — see `LICENSE`.
