# Karpathy principles (coding discipline)

[TOC]

> Source: https://github.com/forrestchang/andrej-karpathy-skills (CLAUDE.md)
>
> Two of Karpathy's four principles fill gaps zeus does not otherwise enforce. The other two are already operationalized by existing zeus skills and are linked at the bottom of this file.

## Simplicity First

Write the minimum code that solves the stated problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.

Test: would a senior engineer call this overcomplicated? If yes, simplify before shipping.

## Surgical Changes

Touch only the lines the request requires. Clean up only what your own change orphaned.

- Do not "improve" adjacent code, comments, or formatting.
- Do not refactor things that are not broken.
- Match the existing style even when you would write it differently.
- If you notice unrelated dead code, mention it — do not delete it.
- Remove imports / variables / functions that *your* change made unused. Leave pre-existing dead code alone unless asked.

Test: every changed line traces directly to the user's request. If it does not, it does not belong in this diff.

## Already covered elsewhere

| Karpathy principle | zeus skill that operationalizes it |
|---|---|
| #1 Think Before Coding | `zeus:brainstorming` (spec phase) and `zeus:writing-plans` (plan phase) |
| #4 Goal-Driven Execution | `zeus:test-driven-development` (G2) and `zeus:verification-before-completion` (G3) |

When this reference is cited from a skill, both new principles (#2 and #3) apply. The skills above already enforce #1 and #4.
