# Changelog

All notable changes to the zeus plugin are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); zeus adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Earlier versions (v0.11.0 and below) are documented only via their git tag
messages — this CHANGELOG starts at v0.11.1.

## [Unreleased]

## [0.11.1] — 2026-05-11

### Added

- **`references/project-contract.md`** — single-source-of-truth protocol that
  defines the precedence chain `CLAUDE.md → AGENTS.md → kickoff prompt` for
  resolving the project's binding contract. Documents the section-extraction
  convention (Tech Stack / Conventions / Commands / Definition of Done /
  Invariants) and ships a copy-paste bash helper `zeus_read_project_contract`.
- **`templates/CLAUDE.md.tmpl`** — optional skeleton for projects that pick
  `CLAUDE.md` as their contract during kickoff. Mirrors `AGENTS.md.tmpl`
  section-for-section.
- **`scripts/migrate-to-dotzeus.sh`** — idempotent, per-project migration
  script that relocates `docs/specs/`, `docs/plans/`, and `FEATURES.md` under
  `.zeus/`. BSD-sed safe on darwin (portable `sed` via tmpfile + cmp, no `-i`
  flag). Uses `git mv` when sources are tracked, falls back to plain `mv` when
  sources are gitignored. Refuses to run on a dirty tree or symlinked sources.
  Leaves changes staged; the user controls when to commit.
- **`references/karpathy-principles.md`** — reference doc capturing the
  Simplicity First and Surgical Changes principles. Linked from
  `writing-plans`, `executing-plans`, and `receiving-code-review`.

### Changed

- **CLAUDE.md is now a first-class project contract.** Fifteen skills delegate
  contract reading to `references/project-contract.md` instead of hard-coding
  `AGENTS.md`: `using-zeus`, `session-init`, `kickoff-agents-md`,
  `kickoff-definition-of-done`, `brainstorming`, `writing-plans`,
  `executing-plans`, `test-driven-development`, `clean-state`, `e2e-gate`,
  `using-git-worktrees`, `dispatching-parallel-agents`,
  `verification-before-completion`, `subagent-driven-development`, and
  `decompose-large-projects`. When both `CLAUDE.md` and `AGENTS.md` are
  present, `CLAUDE.md` wins per the precedence chain.
- **`kickoff-agents-md`** adds **CLAUDE.md-aware mode**: when `CLAUDE.md` is
  present at kickoff time, `AGENTS.md` is NOT generated. The interview fills
  gaps in `CLAUDE.md` (opt-in) or writes a separate `.zeus/dod.md` for
  out-of-tree DoD (the default when the contract is `CLAUDE.md`).
- **`kickoff-definition-of-done`** supports three DoD write targets:
  `AGENTS.md` (existing), `CLAUDE.md` (inline opt-in), and `.zeus/dod.md`
  (out-of-tree, default for the `CLAUDE.md` route).
- **All plugin-generated artifacts now live under `.zeus/`.** The previous
  three top-level entries (`docs/specs/`, `docs/plans/`, `FEATURES.md`) move
  to `.zeus/specs/`, `.zeus/plans/`, `.zeus/features.md`. Combined with the
  existing `.zeus/memory/` and `.zeus/state/`, every plugin-managed file now
  lives under one directory. The only zeus-related files at the project root
  are the user's chosen contract file (`CLAUDE.md` or `AGENTS.md`).
- **`hooks/pre-tool-use.sh`** drops the `docs/specs/` allowance; the
  pre-existing `.zeus/` blanket allowance covers all plugin artifacts.
- **`references/skill-style.md`** adds a MUST clause: every contract-reading
  skill MUST delegate to `references/project-contract.md` rather than
  hard-code a file name.
- **`README.md`** documents the upgrade path from pre-relocation zeus.

### Migration

Pre-relocation projects upgrade by running the migration script once per
project:

```bash
bash scripts/migrate-to-dotzeus.sh
git commit -m "chore: migrate zeus artifacts to .zeus/"
```

The script preserves git history via `git mv` for tracked sources, falls back
to plain `mv` for gitignored sources, and is idempotent — re-running on a
migrated repo is a no-op. Internal cross-references inside `skills/`,
`references/`, `templates/`, `.zeus/specs/`, and `.zeus/plans/` are rewritten
in the same pass so plans don't point at stale spec paths.

### Notes

This release also ships **five pre-relocation commits** that landed on `main`
between `v0.11.0` and SP-relocate but were never tagged:

- `references/karpathy-principles.md` added; `writing-plans`,
  `executing-plans`, and `receiving-code-review` link to it.
- `.zeus/` added to `.gitignore` so zeus's own dogfooding artifacts stay local
  to the maintainer's working tree.
