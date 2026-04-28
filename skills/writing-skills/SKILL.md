---
name: writing-skills
description: Use when creating or modifying a zeus skill — the meta-skill that enforces skill-style.md conventions, provides a skeleton template, and validates frontmatter and section order. Ensures every new skill is consistent with the plugin's writing contract.
gates: []
layer: 1
lecture: [L04]
hard_gate: false
---

# Writing Skills

## Overview

L04 argued that one giant instruction file fails because it mixes concerns, grows without structure, and becomes unreadable. Zeus solves this by splitting instructions into focused skills, each with a consistent structure defined in `references/skill-style.md`. This meta-skill guides the creation of new skills — enforcing the frontmatter schema, section order, tone rules, and integration conventions so the plugin stays coherent as it grows.

## Process flow

1. **NAME** — Choose a kebab-case name that matches the directory name. The name should describe what the skill does, not when it runs. Good: `systematic-debugging`. Bad: `when-tests-fail`.

2. **WRITE FRONTMATTER** — Fill in all six required fields:

   ```yaml
   ---
   name: <kebab-case, matches directory>
   description: <triggering text — imperative, slightly pushy, mentions user phrases>
   gates: [G3, G4]    # which gates this skill opens/closes, [] if none
   layer: 4            # primary defense layer (1-5)
   lecture: [L09]      # which lectures this skill operationalizes, [] if none
   hard_gate: true     # does this skill block downstream until passing?
   ---
   ```

   Field guidance:
   - `description` is what Claude Code uses to decide whether to surface the skill. Write it as if a user is searching — use their words, not yours.
   - `layer` is the single layer whose failure mode this skill primarily prevents. Pick one even if the skill spans multiple layers.
   - `hard_gate: true` means the skill has an Iron Law and blocks progress until satisfied.

3. **WRITE BODY SECTIONS** — Follow this exact order. Omit sections that do not apply, but never reorder:

   | # | Section | Required | Notes |
   |---|---------|----------|-------|
   | 1 | Overview | yes | 1-3 sentences. Cite the lecture by paraphrasing in English. |
   | 2 | Iron Law | only if hard_gate: true | Short, absolute, ALL-CAPS. |
   | 3 | Process flow | yes | Numbered steps (each 2-5 min) + GraphViz `dot` diagram. List and diagram must agree. |
   | 4 | Anti-rationalization table | recommended | "Thought" → "Reality" two-column table. |
   | 5 | Red flags / Stop conditions | recommended | Bullet list of pause-and-escalate signals. |
   | 6 | Verification checklist | yes | Prefer command-runnable checks. Use `- [ ]` format. |
   | 7 | Integration | yes | Predecessor, successor, gates addressed, layer defended. |

4. **APPLY TONE RULES** — Check against these constraints:
   - Imperative voice ("Run the command", not "you should run").
   - Lead with why before what. Cite the lecture's argument.
   - English only in the skill body — no mixed-language content.
   - ALL-CAPS only for Iron Laws. Everywhere else, explaing.
   - At least one concrete example in Process flow or Verification checklist.

5. **VALIDATE** — Run through the validation checklist before committing.

6. **COMMIT** — One skill per commit. Commit message format: `feat(<sprint>): add <skill-name> skill`.

```dot
digraph writing_skills {
  name [label="1. NAME\nkebab-case", shape=box];
  frontmatter [label="2. FRONTMATTER\n6 required fields", shape=box];
  body [label="3. BODY SECTIONS\n7 sections in order", shape=box];
  tone [label="4. TONE RULES\nimperative, English,\nwhy before what", shape=box];
  validate [label="5. VALIDATE\nch shape=box];
  commit [label="6. COMMIT", shape=doublecircle];

  name -> frontmatter -> body -> tone -> validate -> commit;
}
```

## Skeleton template

Use this as a starting point for any new skill:

```markdown
---
name: <skill-name>
description: <Use when ... — triggering text>
gates: []
layer: <1-5>
lecture: []
hard_gate: false
---

# <Skill Name>

## Overview

<1-3 sentences. Cite the lecture argument in English.>

## Process flow

1. **STEP ONE** — <action>.
2. **STEP TWO** — <action>.
3. **STEP THREE** — <action>.

\`\`\`dot
digraph <skill_name> {
  step1 [label="1. STEP ONE", shape=box];
  step2 [label="2. STEP TWO", shape=box];
  step3 [label="3. STEP THREE", shape=doublecircle];

  step1 -> step2 -> step3;
}
\`\`\`

## Anti-rationalization table

| Thought | Reality |
|---------|---------|
| "<excuse>" | <why the excuse is wrong> |

## Red flags / Stop conditions

- <signal that means pause and escalate>

## Verification checklist

- [ ] <objective check>
- [ ] <objective check>

## Integration

- **Predecessor:** <skill or trigger>.
- **Successor:** <skill or none>.
- **Gates addressed:** <G1-G7 or none>.
- **Defends layer:** <1-5>.
```

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Description uses internal jargon | Rewrite using words a user would search for |
| Multiple layers in frontmatter | Pick one primary layer. Mention others in Integration. |
| Iron Law on a non-hard-gate skill | Either add `hard_gate: true` or remove the Iron Law |
| Process flow without dot diagram | Add the diagram. List and diagram must agree. |
| Dot diagram without process flow | Add the numbered list. Both are required. |
| Chinese text in skill body | Paraphrase into English. Link to lecture URL for original. |
| Sections out of order | Reorder to match the canonical sequence. |
| No concrete example and at least one in Process flow or Verification. |
| Verification items are subjective | Replace with command-runnable checks where possible. |

## Anti-rationalization table

| Thought | Reality |
|---------|---------|
| "This skill is simple, I don't need the full template." | Consistency is the value. Use the template. |
| "The section order doesn't matter." | Readers expect a consistent structure. Follow the order. |
| "I'll add the dot diagram later." | Later never comes. Write it with the process flow. |
| "The description is fine, users will figure it out." | The description is the skill's discoverability. Write it for the user, not yourself. |
| "I know the conventions by heart." | Conventions evolve. Read `skill-style.md` before writing. |

## Red flags / Stop conditions

- Writing a skill without reading `references/skill-style.md` first → stop, read it.
- Skill body contains non-English text → stop, paraphrase into English.
- Frontmatter missing any of the 6 required fields → stop, add them.
- Sections out of canonical order → stop, reorder.
- No verification checklist → stop, every skill needs objective checks.

## Verification checklist

- [ ] Skill directory name matches frontmatter `name` field.
- [ ] All 6 frontmatter fields present and valid.
- [ ] `description` uses user-facing language, not internal jargon.
- [ ] Body sections in canonical order (Overview → Iron Law → Process → Anti-rat → Red flags → Verification → Integration).
- [ ] Iron Law present if and only if `hard_gate: true`.
- [ ] Process flow has both numbered list and dot diagram, and they agree.
- [ ] At least one concrete example in the skill.
- [ ] English only — no mixed-language content.
- [ ] Imperative voice throughout.

## Integration

- **Called when:** creating a new zeus skill or modifying an existing one.
- **References:** `references/skill-style.md` (the canonical writing contract).
- **Pessor:** design decision to add a new skill (usually from `zeus:brainstorming`).
- **Successor:** the new skill is committed and integrated into the plugin.
- **Gates addressed:** none — this is a meta-skill, not a gate.
- **Defends layer:** 1 (task specification — ensures skills are well-specified and consistent).
