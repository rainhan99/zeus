---
name: brainstorming
description: Use when starting any creative design work in a zeus-managed project — new feature, refactor, architectural change, behavior modification. Reads AGENTS.md to anchor scope, offers the user a choice of brainstorming mode, explores the idea covering all 5 defense layers, produces a 6-section spec doc, and updates .zeus/features.md. Hard-gates against any implementation skill running before a spec is approved.
gates: [G4]
layer: 1
lecture: [L01, L07]
hard_gate: true
---

# Brainstorming

Turn ideas into fully formed designs through collaborative dialogue, anchored in the project's binding contract. L01's core argument: capable agents fail at execution because they invent context; brainstorming forces them to read the contract first.

## Phase banner (print first)

Before any other action in this skill, your **first user-facing output** MUST be the phase banner below, matched to the user's conversation language. Use ZH verbatim for Chinese, EN verbatim for English; for any other language, translate the EN template preserving the structure (header line, Goal, Not yet, Output). Print it as a fenced code block so the separators render cleanly.

**EN:**
```
━━━ Phase 1/3 · Discussion ━━━
Goal: lock in WHAT — scope, boundaries, decisions
Not yet: code, tasks, file paths
Output: spec → your approval → Phase 2 (Design)
```

**ZH:**
```
━━━ 阶段 1/3 · 方案讨论 ━━━
目标:锁定「做什么」— 范围、边界、决策点
此阶段不做:写代码、拆任务、定文件路径
产出:spec 文档 → 你批准 → 进入阶段 2(设计)
```

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have written a spec and the user has approved it. This applies to EVERY feature regardless of perceived simplicity.
</HARD-GATE>

## Iron Law

**No implementation skill runs until a brainstorming spec is written and user-approved. The spec always has the same 6 sections, regardless of which brainstorming mode was used.**

## Checklist

Complete these items in order. Scale depth to the task — a simple feature gets brief answers, a complex one gets thorough exploration.

1. **Activate brainstorming state.** Run: `mkdir -p .zeus/state && rm -f .zeus/state/spec-approved && echo "active" > .zeus/state/brainstorming-active`
2. **Read the project contract** per `references/project-contract.md`. If neither CLAUDE.md nor AGENTS.md exists, abort: "No project contract found. Run `zeus:kickoff-agents-md` first."
3. **Read `.zeus/features.md`** if present. Confirm F-NNN target — existing or new? If new, reserve the next ID.
4. **Show the 7-gate cascade.** Tell the user: "Completion is gated by 7 evidence levels: G1 code → G2 TDD red-green → G3 verification command → G4 DoD satisfied → G5 E2E pipeline → G6 two-stage review → G7 handoff state."
5. **Mode selection.** Ask the user:
   - **[1] Walk me through it** (default) — questions one at a time covering L1–L5.
   - **[2] Show me two options** — define "done" as commands first, then generate two complete alternative designs side by side with trade-offs. User picks or blends. Backfill remaining layers.
   - **[3] Both** — two options first, user picks, then walk through every layer on the chosen design.
6. **Run chosen mode.** Cover all 5 defense layers through the dialogue:
   - **L1 Scope** — what's in, what's out, who's the user, corner cases
   - **L2 Context** — existing patterns, adjacent systems, dependencies
   - **L3 Environment** — new deps, CI changes, runtime impact, version pins
   - **L4 Verification** — what does "done" look like as actual commands? DoD delta
   - **L5 State** — what state remains for the next session, observability needs
   - **Completeness rule:** each layer must have ≥ 1 captured note. Empty layer = unfinished brainstorm. For mode [2]/[3], two genuinely different designs must be generated; if only one viable appr, drop to mode [1].
7. **Write spec** to `.zeus/specs/<YYYY-MM-DD>-<topic>-design.md` with 6 fixed sections:
   - `## Goal / Scope` ← L1
   - `## Architecture / Context dependencies` ← L2
   - `## Environment requirements` ← L3
   - `## Definition of Done delta` ← L4 (will patch the project contract's `## Definition of Done`). Write `(none)` explicitly if empty.
   - `## Handoff state requirements` ← L5
   - `## 7-gate impact map` ← which gates get new constraints

   *Pre-relocation zeus projects wrote specs to `.zeus/specs/`. If your project still has that path, run `scripts/migrate-to-dotzeus.sh` once.*
8. **Update `.zeus/features.md`** — F-NNN status → `in-progress`, add spec link.
9. **Spec self-review** — placeholder scan, internal consistency, scope check, ambiguity. Fix inline.
10. **User reviews spec.** Wait for approval or change requests.
11. **On approval** — run: `echo "<spec-file-path>" > .zeus/state/spec-approved && rm -f .zeus/state/brainstorming-active` — then invoke `zeus:writing-plans`.

## Anti-rationalization rules

| Thought | Reality |
|---|---|
| "I'll skip Anchor, I know the project." | The project contract has version pins, conventions, DoD. Skipping it turns the spec into guesswork. |
| "User picked [2], I'll skip L5." | Mode [2] backfills all layers. Skipping any = unfinished spec. |
| "DoD delta is empty." | Every meaningful change touches G4. If truly nothing, write `(none)` explicitly. |
| "User said 'just make it work'." | That's a request to ship, not to skip thinking. Use mode [1]. |
| "Two drafts are essentially the same." | Then only one viable approach exists. Drop to mode [1]. |

## Stop conditions

- Project contract missing (neither CLAUDE.md nor AGENTS.md) → abort, redirect to `zeus:kickoff-agents-md`.
- Mode [2] cannot produce two genuinely different designs → drop to mode [1] with explanation.
- Spec self-review finds unresolvable contradictions after 2 iterations → surface to user and pause.

## Verification checklist

Before handing off, confirm: project contract was read; F-NNN target chosen; mode was selected; all 5 layers have ≥ 1 note; spec file exists with all 6 sections; .zeus/features.md updated; user explicitly approved.

## Integration

- **Predecessor:** `zeus:kickoff-feature-list` or direct user invocation.
- **Successor:** `zeus:writing-plans` (after spec approval). Do NOT invoke any other skill.
- **Gates addressed:** G4 — sets up DoD delta.
- **Defends layer:** 1 (task specification).
