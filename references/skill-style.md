# Reference: Skill Writing Convention

[TOC]

This document is the contract every skill in the zeus plugin follows. Reviews check both the skill itself and its compliance with this contract. Drift from the contract makes the plugin fragment; coherence is the user-visible value.

## Frontmatter schema

Every `SKILL.md` begins with YAML frontmatter containing exactly these fields:

```yaml
---
name: <skill-name>             # kebab-case, matches directory name
description: <triggering text> # imperative, slightly pushy; mentions concrete user phrases
gates: [G3, G4]                # subset of [G1..G7] from references/seven-gates.md
layer: 4                       # one of [1..5] from references/five-layers.md
lecture: [L09, L10]            # subset of [L01..L12] from references/twelve-lectures.md
hard_gate: true                # whether this skill blocks downstream until passing
---
```

`name` matches the directory name. `description` is what Claude Code's plugin harness uses to decide whether to surface the skill — write it as if a user is searching for the skill's purpose using the words a real user would use, not the words you wish they would use.

## Body section order

Sections appear in this order. Omit any section that doesn't apply, but never reorder.

1. **Overview** — 1–3 sentences. Cite the lecture the skill operationalizes by paraphrasing the argument in plain English. Lecture URLs in `references/twelve-lectures.md` are the canonical pointer if a reader wants the original Chinese wording.
2. **Iron Law** — present only when `hard_gate: true`. Short, absolute, boxed. Models superpowers' pattern. Examples: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE", "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST".
3. **Process flow** — a numbered list of steps (each step is one action of 2–5 minutes), followed by a GraphViz `dot` block visualizing the same flow. The list and the diagram must agree.
4. **Anti-rationalization table** — two-column "Thought" → "Reality". Captures the specific excuses an agent generates to skip this skill. Skip the table when the skill has no plausible bypasses.
5. **Red flags / Stop conditions** — bullet list of signals that mean the agent should pause and escalate to the user or to another skill.
6. **Verification checklist** — items the agent or reviewer can confirm objectively. Prefer command-runnable checks (`pytest`, `mypy --strict`, `jq . file.json`). Use subjective items only when no objective check exists.
7. **Integration** — explicit predecessor and successor skills, and which gates this skill opens or closes. Skills that hand off to a specific successor must name it.

## Tone rules

- Imperative voice ("Run the verification command", not "you should run").
- Lead with *why* before *what*. Cite the lecture's argument. Do not preserve the original Chinese in the skill body — paraphrase into English. The lecture URL in `references/twelve-lectures.md` is the canonical link back to the original.
- Reserve ALL-CAPS MUSTs for catastrophic-failure sections (Iron Laws). For everything else, explain the reasoning so the model can judge edge cases at runtime rather than memorizing rules.
- Skill body language is English only. No mixed-language content anywhere — frontmatter, body, tables, integration.

## Examples and patterns

Each skill should include at least one concrete example showing the skill being applied. Examples live inside the relevant body section (typically Process flow or Verification checklist), not in a separate "Examples" section. Inline examples teach faster than abstract descriptions.

## Contract-reading rule

Every skill that reads the project's binding contract MUST follow `references/project-contract.md`. Do not hard-code `AGENTS.md` or `CLAUDE.md` paths in skill checklists, prose, bash snippets, or dot diagrams — delegate to the protocol. The protocol defines the precedence chain (CLAUDE.md → AGENTS.md → kickoff prompt), the section-extraction conventions, and a copy-paste bash helper. Skills that hard-code a single file name will drift away from the contract and break for projects that picked the other convention.

## Cross-references

- 12 lectures → `references/twelve-lectures.md`
- 5-layer defense taxonomy → `references/five-layers.md`
- 7-gate completion cascade → `references/seven-gates.md`
- Project contract precedence → `references/project-contract.md`
