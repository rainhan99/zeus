# Reference: Engineering Constraints (zeus defaults)

[TOC]

## Why this exists

Zeus-managed projects follow eight default engineering constraints, carried by the
plugin itself: installing zeus on any machine activates them in every session via the
SessionStart bootstrap digest (`hooks/bootstrap.md`). They are defaults, not dogma —
the developer can exempt any of them, but only through an explicit, recorded
declaration (see Override protocol). An undeclared deviation is a defect: review
treats it as a finding.

## The constraints

EC-IDs are stable and never reused; a new constraint takes the next free number.

### EC-1 — No backward compatibility

Delete obsolete code outright. No compatibility layers, no migration shims, no
fallback paths kept "just in case". When something is superseded, remove it in the
same change that supersedes it.

A migration is forbidden when it keeps the old shape usable: dual reads or writes,
compatibility shims, rollback paths. A one-way migration that moves existing data
to the new shape and deletes the old path in the same change needs no exemption:
it is how the old thing gets deleted.

### EC-2 — Simplest implementation that meets current needs

No preventive abstraction, no configuration layer for hypothetical needs.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.

Test: would a senior engineer call this overcomplicated? If yes, simplify before
shipping.

### EC-3 — Grow the system in layers

Get a minimal end-to-end version running first, then build on top of it. Never
dismantle working code for the sake of unfinished complexity.

### EC-4 — Modular components, separated concerns

One module, one concern. Boundaries stay explicit; no reaching across layers.

### EC-5 — Prefer mature, maintained libraries

Do not hand-roll what a maintained library already does, unless there is an explicit,
recorded reason.

### EC-6 — Check existing dependencies first

Before adding a package or writing custom code, check what the project's existing
dependencies already provide. Never assume a capability is missing.

### EC-7 — Architecture decisions are long-term

No "temporary for now, replace later" designs. If the long-term shape is known, build
that shape now. (Tension with EC-2 — see below.)

### EC-8 — Proven patterns first

Study how mature products solve the same problem; adopt the validated pattern instead
of inventing from scratch.

## EC-2 vs EC-7 — resolution

EC-7 governs decision durability (never choose a design you already plan to replace);
EC-2 governs implementation scope (build no more than the need). They compose:
**build the simplest thing you will not have to architecturally overturn.**

## Override protocol

Three declaration levels; a deviation without one is a review finding.

| Level | Where it lives | Scope |
|---|---|---|
| 1. Project standing exemption | project contract (CLAUDE.md / AGENTS.md) `## Engineering Constraints` section | whole project, until removed |
| 2. Feature exemption | spec's `### Constraint Exemptions` subsection (inside `## Architecture / Context dependencies`) | one feature |
| 3. Conversational declaration | the developer says it in-session | counts ONLY once transcribed as level 2 — the agent must write it into the spec |

Precedence: project contract > spec EX record > default.

### EX record grammar (normative)

The spec subsection contains either the literal `(none)` or one or more records:

    - **EX-<n>** — exempts EC-<k> — scope: <files or feature area> — reason: <why>

EX-IDs are stable within a spec and never reused; scope and reason must each hold
non-blank text. `(none)` and EX records are
mutually exclusive. `scripts/check-constraint-exemptions.sh <spec>` mechanically
enforces this grammar (exit 0 well-formed / 1 missing-malformed-mixed / 64 usage).

The subsection heading must be spelled exactly `### Constraint Exemptions`
(level-3, exact casing, no trailing decoration) — the checker matches its words
literally, and tolerates one or more blanks after `###` and trailing blanks. A
leading `- ` before `(none)`, leading spaces or tabs, trailing blanks,
and CRLF line endings are tolerated. A line that looks like a record — a list item
(bullet or number) naming an EX-ID, or a line opening with a bold `**EX-<n>**` —
must be a fully well-formed record; other prose inside the subsection may mention
EX-IDs freely.

## Diff discipline (Surgical Changes)

Touch only the lines the request requires. Clean up only what your own change
orphaned.

- Do not "improve" adjacent code, comments, or formatting.
- Do not refactor things that are not broken.
- Match the existing style even when you would write it differently.
- If you notice unrelated dead code, mention it — do not delete it.
- Remove imports / variables / functions that *your* change made unused. Leave
  pre-existing dead code alone unless asked.

Test: every changed line traces directly to the request. If it does not, it does not
belong in this diff.

## Covered elsewhere in zeus

| Principle | Operationalized by |
|---|---|
| Think Before Coding | `zeus:brainstorming` (spec phase), `zeus:writing-plans` (plan phase) |
| Goal-Driven Execution | `zeus:test-driven-development` (G2), `zeus:verification-before-completion` (G3) |

## Cross-references

- Session digest: `hooks/bootstrap.md` → `## Engineering Constraints (zeus defaults)`.
- Spec field mandate: `skills/brainstorming/SKILL.md` (spec section 2 subsection).
- Mechanical check: `scripts/check-constraint-exemptions.sh` + `tests/check-constraint-exemptions.test.sh`.
- Plan carry-forward + architect audit: `skills/writing-plans/SKILL.md`.
- Review audit: `skills/requesting-code-review/code-reviewer-prompt.md`.
- Standing-exemption anchor for projects: `templates/AGENTS.md.tmpl`, `templates/CLAUDE.md.tmpl`.
