# Changelog

All notable changes to the zeus plugin are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); zeus adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Earlier versions (v0.11.0 and below) are documented only via their git tag
messages — this CHANGELOG starts at v0.11.1.

## [Unreleased]

## [0.11.5] — 2026-05-28

### Changed

- `/zeus:execute` mode selection simplified: removed `auto` option entirely.
  The user now always picks directly between `sequential` and `subagent` — no
  hidden heuristic. A one-line context hint (task count, file overlap) is
  printed before the question, but the decision is never made for the user.
- `zeus:executing-plans` step 2 now asks the execution mode question (with the
  same direct two-option format) when invoked without `mode-resolved=` in
  `$ARGUMENTS`, ensuring the subagent choice is always presented regardless of
  entry path.
- Bootstrap routing (`hooks/bootstrap.md`) adds a mandatory "Execution mode"
  section: ALL development tasks — full-process or quick-fix, any size — must
  ask the user `sequential` vs `subagent` before proceeding.

### Added

- **Quick-fix bypass (小修复直通)** — small, bounded fixes (≤ 3 files, no
  architectural decision, unambiguous intent) can now skip the 7-gate cascade
  (brainstorming + planning phases) with explicit user consent. The flow:
  1. Agent identifies the task as quick-fix eligible and tells the user.
  2. User confirms via `AskUserQuestion` (`Yes, bypass 7-gate` / `No, full
     process`).
  3. On bypass: `.zeus/state/quick-fix-active` is created, writes are unblocked,
     verification (tests/lint) still runs, state file is cleaned up on
     completion.
- `hooks/pre-tool-use.sh` now recognizes `.zeus/state/quick-fix-active` as a
  valid unblock condition alongside `spec-approved` and `brainstorming-active`.
- Block message updated to mention the quick-fix bypass option.

## [0.11.4] — 2026-05-26

### Fixed

- `hooks/pre-tool-use.sh` no longer false-blocks Edit/Write when `cwd` is
  absent from the hook's stdin payload. The previous fallback chain ended
  in `.`, which resolves against the hook subprocess's cwd — not the
  project root — and so missed `.zeus/state/spec-approved` even when the
  spec was approved. New behavior:
  1. Prefer stdin `.cwd`, then `$CLAUDE_PROJECT_DIR`, then `$PWD` (never
     bare `.`).
  2. If the resolved root has no `.zeus/` directory, exit 0 — the user
     isn't in a zeus project and the gate doesn't apply. This also makes
     stray invocations from unrelated directories safe.

  Symptom this fixes: in plugin-hook context Claude Code 2.1.150 sometimes
  omits `.cwd` from stdin and doesn't set `$CLAUDE_PROJECT_DIR`, causing
  writes to be blocked with "No approved brainstorming spec found" even
  when `.zeus/state/spec-approved` was present in the actual project root.

## [0.11.3] — 2026-05-19

### Added

- `/zeus:execute` is now a mode router. Before dispatching, it asks the user
  which execution mode to use — `auto` (recommended), `sequential`, or
  `subagent` — and routes to either `zeus:executing-plans` or
  `zeus:subagent-driven-development` accordingly. The `auto` mode picks based
  on plan shape (task count, plus optional `Files:` independence signal when
  every task in plan Section 4 declares one). When `auto` resolves to
  `subagent`, the command asks for an explicit confirm before dispatching;
  when it resolves to `sequential`, it dispatches silently.
- `zeus:executing-plans` step 2 honors a new `mode-resolved=` marker in
  `$ARGUMENTS`. When the marker is present, the in-skill "consider subagent"
  suggestion is skipped — the command layer has already routed. Direct
  invocation of the skill without the marker preserves the existing prompt.

### Changed

- Mode selection no longer happens mid-skill on step 2 of `executing-plans`;
  it happens at the command layer before any skill is invoked. The choice is
  now unmissable instead of buried in a single-line prompt.

## [0.11.2] — 2026-05-11

### Added

- Four thin slash command wrappers for the main lifecycle phases:
  - `/zeus:brainstorm <idea>` — invokes the `zeus:brainstorming` skill
  - `/zeus:plan [spec]` — invokes `zeus:writing-plans`
  - `/zeus:execute [plan]` — invokes `zeus:executing-plans`
  - `/zeus:ship` — invokes `zeus:finishing-a-development-branch`
- The wrappers are intentionally thin (each is a single-paragraph markdown
  file under `commands/`). Every iron law — spec approval, plan footer
  signature, TDD discipline, Logic Completeness Manifest, full DoD sweep,
  G7 close-out — is still enforced by the underlying skills. The natural
  language entry path (e.g., "I want to add X" → routing table → skill)
  continues to work unchanged.
- `README.md` now documents the slash command surface alongside the
  existing skill table.

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
