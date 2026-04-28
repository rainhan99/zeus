---
name: memory-management
description: Use when writing, reading, compressing, or evicting project memory — the self-contained long-term memory system that lives in .zeus/memory/ with no external dependencies. Handles user corrections (lessons), architecture decisions, task checkpoints, and session handoffs with LLMLingua-inspired tiered compression.
gates: []
layer: 5
lecture: [L05]
hard_gate: false
---

# Memory Management

## Overview

L05 showed that long-running tasks lose more time to context loss than to coding. This skill implements zeus's self-contained memory system — no external MCP, no cloud service, just files in `.zeus/memory/` that the agent reads and writes. The system borrows three ideas from LLMLingua's prompt compression research: budget-controlled loading, component-specific compression ratios, and iterative summarization. The result is a memory layer that fits inside a token budget while preserving the highest-value information at full fidelity.

## Storage layout

```
.zeus/memory/
├── index.md              # memory index — loaded every session-init
├── lessons/              # user corrections — hot, never compressed, never evicted
├── decisions/            # architecture/design decisions — warm
├── checkpoints/          # task progress snapshots — compress aggressively
├── handoffs/             # session handoff memos — time-decay compression
└── compressed/           # second-pass archive (compression_level: 2)
```

All paths are relative to the project root. The agent creates `.zeus/memory/` and subdirectories on first write. Add `.zeus/` to `.gitignore` if the user prefers memory to stay local; leave it tracked if the user wants memory to travel with the repo.

## Memory file format

Every memory file uses YAML frontmatter followed by the content body:

```yaml
---
type: lesson | decision | checkpoint | handoff
temperature: hot | warm | cold
created: 2026-04-28
last_accessed: 2026-04-28
compression_level: 0 | 1 | 2
tags: [tag1, tag2]
---

Content body here.
```

- `type` determines compression strategy.
- `temperature` determines loading priority.
- `compression_level` tracks how many summarization passes have been applied.
- `tags` enable relevance matching when loading under budget pressure.

## Three-tier temperature model

Adapted from LLMLingua's budget controller — allocate token budget asymmetrically by information value.

| Tier | Temperature | Compression | Content | Budget share |
|------|-------------|-------------|---------|-------------|
| Hot | high | none | lessons (user corrections), active handoff, current sprint decisions | 60% |
| Warm | medium | moderate | project architecture decisions, completed sprint summaries, patterns | 30% |
| Cold | low | aggressive | old session logs, resolved bugs, archived handoffs | 10% |

Budget reallocation rule: if Hot tier exceeds 60%, Warm and Cold shrink proportionally. Lessons never yield budget — they are the highest-priority memory class.

## Memory types and compression strategy

Adapted from LLMLingua's component-specific handling — different content types tolerate different compression ratios.

| Type | Compression ratio | Strategy | Rationale |
|------|-------------------|----------|-----------|
| `lesson` | near-zero (~τ=0.85) | Keep full text. Never auto-compress. Never auto-evict. | Prevents repeated mistakes — highest ROI per token |
| `decision` | moderate (~τ=0.5) | Keep conclusion + reasoning. Drop deliberation process. | The "what" and "why" matter; the "how we got there" does not |
| `checkpoint` | aggressive (~τ=0.2) | Keep only current position + next step. Drop history. | Like LLMLingua's demonstration compression — redundant detail adds no value |
| `handoff` | time-decay | Latest: uncompressed. Previous: first-pass. Older: second-pass. | Most recent handoff is most actionable |

## Progressive summarization

Adapted from LLMLinguaative token-level compression — each pass reduces tokens while preserving semantic core.

```
compression_level: 0 (raw)
  Full content as originally written.

compression_level: 1 (first pass, ~50% tokens)
  Remove redundant descriptions, filler, examples.
  Keep: key facts, conclusions, action items, code references.

compression_level: 2 (second pass, ~15% tokens)
  One-line summary + tags only.
  Move original to compressed/ directory.
```

Compression triggers:
- `checkpoint`: compress to level 1 when the task completes. Compress to level 2 after the sprint closes.
- `handoff`: compress to level 1 when a newer handoff exists. Compress to level 2 after two newer handoffs.
- `decision`: compress to level 1 when the decision is older than 3 sprints and has not been accessed.
- `lesson`: never auto-compress.

## Process flow

1. **DETECT** — Check if `.zeus/memory/` exists. If not, create the directory tree.

2. **CLASSIFY** — Determine the memory type (lesson / decision / checkpoint / handoff) from context.

3. **WRITE** — Write the memory file with frontmatter. Assign temperature based on type and recency.

4. **INDEX** — Append a one-line entry to `index.md`: `- [title](relative-path) — one-line summary | tags: [t1, t2] | temp: hot`

5. **BUDGET CHECK** — Count total tokens across all memory files. If over budget, trigger compression on the lowest-priority items first (Cold → Warm, checkpoints → handoffs → decisions).

6. **COMPRESS** — Apply progressive summarization. Move originals to `compressed/` when reaching level 2.

7. **LOAD** (called by session-init) — Read `index.md`, load files by temperature tier within budget. Hot first, then Warm, then Cold index-only.

```dot
digraph memory_flow {
  detect [label="1. DETECT\n.zeus/memory/ exists?", shape=diamond];
  create [label="Create directory tree", shape=box];
  classify [label="2. CLASSIFY\nlesson/decision/\ncheckpoint/handoff", shape=box];
  write [la"3. WRITE\nfile + frontmatter", shape=box];
  index [label="4. INDEX\nappend to index.md", shape=box];
  budget [label="5. BUDGET CHECK\nover limit?", shape=diamond];
  compress [label="6. COMPRESS\nprogressive summarization", shape=box];
  done [label="Memory written", shape=doublecircle];

  detect -> create [label="no"];
  detect -> classify [label="yes"];
  create -> classify;
  classify -> write -> index -> budget;
  budget -> compress [label="over budget"];
  budget -> done [label="within budget"];
  comprene;
}
```

## User correction instant-capture

When the user points out a mistake,s behavior, or says "remember this":

1. **Immediately** write to `lessons/` — do not wait for a natural checkpoint.
2. Set `temperature: hot`, `compression_level: 0`.
3. Include: what was wrong, what the correct behavior is, and why (if the user explained).
4. Update `index.md`.
5. This lesson is loaded in every future session-init before any other memory.

Lessons are never auto-compressed and never auto-evicted. Only the user can delete a lesson.

Example lesson file:
```yaml
---
type: lesson
temperature: hot
created: 2026-04-28
last_accessed: 2026-04-28
compression_level: 0
tags: [tooling, lint, ecosystem]
---

Do not write custom validation scripts when ecosystem-standard tools exist.
Use ESLint for JS/TS, Ruff for Python, cargo clippy for Rust, golangci-lint for Go.
Why: custom scripts diverge from community standards and miss edge cases that mature tools handle.
```

## Token budget defaults

| Parameter | Default | Adjustable |
|-----------|---------|------------|
| Total budget | 2000 tokens | via `.zeus/memory/config.yaml` if present |
| Hot share | 60% (1200 tokens) | yes |
| Warm share | 30% 00 tokens) | yes |
| Cold share | 10% (200 tokens) | yes |
| Lesson priority | always loaded first | no — lessons never yield |

## Anti-rationalization table

| Thought | Reality |
|---------|---------|
| "I'll remember this without writing it down." | You won't. Next session starts with zero context. Write it. |
| "This correction is too small to record." | Small corrections compound. A lesson costs 2 lines. Write it. |
| "Memory is getting large, skip the write." | That is what compression is for. Write first, compress later. |
| "I'll compress lessons to save tokens." | Lessons are never compressed. They are the highest-value memory. Compress something else. |
| "Loading memory takes too many tokens." | Budget control exists for this. Load within budget, not without memory. |
| "The user will remind me if it matters." | The user should not have to repeat themselves. That is the entire point of lessons. |

## Red flags / Stop conditions

- About to skip writing a user correction → stop, write the lesson immediately.
- About to auto-compress or delete a lesson → stop, lessons are immutable except by user.
- Memory budget exceeded and no compression candidates remain → stop, ask user which memories to archive.
- About to write memory without frontmatter → stop, every file needs the metadata for the system to work.
- Loading memory without checking budget → stop, always load within budget.

## Verification checklist

- [ ] `.zeus/memory/` directory tree exists (or is created on first write).
- [ ] Every memory file has valid frontmatter (type, temperature, created, compression_level, tags).
- [ ] `index.md` has a one-line entry for every memory file.
- [ ] User corrections are written to `lessons/` immediately, with `temperature: hot`.
- [ ] Lessons are never auto-compressed or auto-evicted.
- [ ] Token budget is respected when loading memory in session-init.
- [ ] Hot tier loads before Warm, Warm before Cold.
- [ ] Compression triggers fire at the right lifecycle points.

## Integration

- **Called by:** all SP6 skills (`session-init`, `long-task-continuity`, `session-handoff`, `clean-state`) for memory read/write.
- **Called by:** any skill that receives user corrections (the instant-capture flow).
- **Predecessor:** none — this is the foundation skill for SP6.
- **Successor:** `session-init` (loads memory), `session-handoff` (writes handoff memory).
- **Gatesessed:** supports G7 indirectly by providing the storage layer for handoff memos.
- **Defends layer:** 5 (state management).
