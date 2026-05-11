# Reference: Project Contract — Precedence Chain

[TOC]

## Why this exists

Zeus skills used to hard-code `AGENTS.md` as the project's binding contract. Projects that already adopted `CLAUDE.md` (the Claude Code convention) were forced to maintain a duplicate. This reference defines the single precedence chain every zeus skill follows when reading the project contract, so contract reading is the same protocol everywhere — no skill invents its own fallback logic, no project maintains two parallel contracts.

The contract carries five sections that zeus relies on: `## Tech Stack`, `## Conventions`, `## Commands`, `## Definition of Done`, `## Invariants`. Both `CLAUDE.md` and `AGENTS.md` use the same section headings and parse identically. Picking one file is a project-level choice; reading sections out of it is a uniform protocol.

## Precedence chain

When a skill needs the project contract, resolve the source in this order:

1. **`$PROJECT/CLAUDE.md`** — if present, this is the contract. Use it. Do not generate or prompt for `AGENTS.md`.
2. **`$PROJECT/AGENTS.md`** — if `CLAUDE.md` is absent and this is present, this is the contract.
3. **Neither present** — caller decides whether to abort with a kickoff redirect or proceed without a contract per skill-specific degradation rules.

When both files are present, **CLAUDE.md wins**. The skill SHOULD also write a one-line `lesson` to `.zeus/memory/lessons/` noting "project has both CLAUDE.md and AGENTS.md; zeus is using CLAUDE.md per precedence chain" so future sessions know the choice was deliberate.

The user-global `~/.claude/CLAUDE.md` is OUT OF SCOPE — zeus only reads project-root `CLAUDE.md` (i.e., `$PROJECT/CLAUDE.md`).

## Section-extraction protocol

After selecting the contract file, extract these sections by markdown heading. Heading text is identical across both file formats:

| Section | Used by |
|---|---|
| `## Tech Stack` | `writing-plans` (per-stack architect analysis), `executing-plans` |
| `## Conventions` | every skill that respects naming/commit/file-size conventions |
| `## Commands` | `test-driven-development`, `e2e-gate`, `dispatching-parallel-agents`, `using-git-worktrees`, `clean-state` |
| `## Definition of Done` | `e2e-gate` (G4), `kickoff-definition-of-done`, `executing-plans` |
| `## Invariants` | `executing-plans`, `receiving-code-review`, `requesting-code-review` |

If a section is missing from the selected contract file, the skill follows its own degradation rules — typically: prompt the user to run the relevant `kickoff-*` skill, or proceed with documented assumptions.

## Bash snippet for skills

Skills that need to resolve the contract file from a shell context can paste this helper:

```bash
zeus_read_project_contract() {
  local project="${1:-.}"
  if [ -f "$project/CLAUDE.md" ]; then
    printf 'CLAUDE.md'
    return 0
  fi
  if [ -f "$project/AGENTS.md" ]; then
    printf 'AGENTS.md'
    return 0
  fi
  return 1
}

# Usage:
#   contract="$(zeus_read_project_contract "$PWD")" || {
#     echo "No contract — run zeus:kickoff-agents-md" >&2; exit 1; }
#   cat "$contract"
```

The function prints the file name (relative to the project root) on stdout and returns 0 on success. On miss it returns 1 and prints nothing. Callers decide whether a miss is fatal.

## Edge cases

| Situation | Behavior |
|---|---|
| Both `CLAUDE.md` and `AGENTS.md` present | CLAUDE.md wins. Skill writes a one-line lesson recording the project has both. |
| Only `CLAUDE.md` present | Used as contract. No prompt to create AGENTS.md. |
| Only `AGENTS.md` present | Used as contract. No CLAUDE.md prompt. |
| Neither present | Skill-specific. `using-zeus` and `session-init` proceed with zeus plugin rules only and log a lesson; planning skills (`brainstorming`, `writing-plans`, `executing-plans`) refuse and redirect to `zeus:kickoff-agents-md`. |
| Contract file present but a required section is missing | Skill prompts user to run the matching kickoff skill (e.g., empty `## Definition of Done` → `zeus:kickoff-definition-of-done`). Skill does NOT silently invent defaults. |
| Contract file is a symlink | Resolve and read — supported. `kickoff-*` skills must NOT migrate symlinked contracts. |
| `~/.claude/CLAUDE.md` (user-global) | Ignored by zeus. Only project-root CLAUDE.md counts. |
| Contract file empty (zero bytes) | Treat as "present but every section is missing" — kickoff path. |

## Cross-references

- Skill writing contract → `references/skill-style.md` (mandates that skills delegate to this protocol).
- Kickoff entry point → `skills/kickoff-agents-md/SKILL.md` (CLAUDE.md-aware mode).
- DoD source choice → `skills/kickoff-definition-of-done/SKILL.md`.
- Artifact layout under `.zeus/` → `skills/memory-management/SKILL.md` and the spec at `docs/specs/2026-05-11-claude-md-compat-and-dotzeus-relocation-design.md`.
