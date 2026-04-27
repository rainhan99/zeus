# Reference: 7-Gate Completion Cascade

[TOC]

The 7-gate cascade is zeus's canonical answer to the question "what does it mean for an agent to be done?" There is no single "done" signal. Completion is a level of evidence, produced by passing seven gates in order. Skipping any gate means the work is not done — the agent does not get to redefine completion.

Origin: synthesized from lectures L09 (declaring victory too early), L10 (end-to-end testing changes results), L11 (observability), and L12 (clean handoff state), and from the verification discipline of the upstream `superpowers` plugin.

## The cascade

### G1 — Code written

- **Signal:** the file diff exists on disk.
- **Evidence form:** `git diff` shows changes; the agent has touched the right files.
- **Gatekeeper:** none — this is observation only, not a gate.
- **Defense layer:** —
- **Lecture:** —

G1 is the lowest signal. The agent crossing G1 does not justify any claim of progress; it only confirms that *some* work happened. All real gates begin at G2.

### G2 — TDD red→green flip completed

- **Signal:** a test that previously failed now passes, in that order.
- **Evidence form:** terminal output of two test runs — first showing FAIL, second showing PASS — both pasted back into context, not paraphrased.
- **Gatekeeper skill:** `test-driven-development`.
- **Defense layer:** 4 (verification feedback).
- **Lecture:** L10.

If a test only ever showed PASS, the test does not prove the implementation works — it might pass for unrelated reasons. The red→green flip is the proof.

### G3 — Verification command run fresh

- **Signal:** the command stated in the agent's claim of completion has actually been executed and its output read.
- **Evidence form:** the command, the full output, and the verdict in context. Not "I think it's working" — actual stdout.
- **Gatekeeper skill:** `verification-before-completion`.
- **Iron law:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
- **Defense layer:** 4 (verification feedback).
- **Lecture:** L09.

This gate exists because L09 showed agents will declare success based on internal reasoning rather than running the actual check. The gate forces the actual run.

### G4 — Definition of Done fully satisfied

- **Signal:** every command-verifiable item in the project's `AGENTS.md` `## Definition of Done` section returns success.
- **Evidence form:** each DoD command run, exit code 0, output captured.
- **Gatekeeper skills:** `kickoff-definition-of-done` (sets the contract during kickoff) + `e2e-gate` (enforces the contract at completion).
- **Defense layer:** 1 + 4.
- **Lecture:** L09.

DoD is locked in during the kickoff phase; the agent is not allowed to rewrite or add exceptions to DoD during execution. If a DoD item cannot be satisfied, the gate stays closed and the work returns to debugging or to a brainstorming-level scope renegotiation.

### G5 — End-to-end pipeline passes

- **Signal:** the realistic user-facing path runs from start to finish — produce, propagate, consume, assert.
- **Evidence form:** an E2E test or scripted run that touches the same surfaces a real user would.
- **Gatekeeper skill:** `e2e-gate`.
- **Defense layer:** 4 (verification feedback).
- **Lecture:** L10.

Unit tests and DoD commands can pass while the actual integrated path is broken. L10's argument: until the whole pipeline runs, you do not know whether the unit-level passes mean anything in the integrated context.

### G6 — Two-stage code review approved

- **Signal:** an independent reviewer has assessed the work in two distinct passes — first for spec compliance, then for code quality — and approved both.
- **Evidence form:** review verdicts captured; any Critical or Important issues raised must be either resolved or explicitly accepted by the user.
- **Gatekeeper skills:** `requesting-code-review` + `receiving-code-review`.
- **Defense layer:** 1 + 4.
- **Lecture:** —

Spec compliance and code quality are different concerns and conflating them lets one mask the other. Two-stage review keeps each in scope.

### G7 — Handoff state clean

- **Signal:** the session leaves the project in a state another session (human or agent) can pick up without archaeology.
- **Evidence form:** observable run log written; clean-state memo written summarizing what changed, what remains, and any non-obvious context; branch in a shippable state.
- **Gatekeeper skills:** `observability` + `session-handoff` + `clean-state`.
- **Defense layer:** 5 (state management).
- **Lecture:** L11 + L12.

This gate exists because L05 and L12 showed long projects lose more time to context loss than to coding. The handoff is part of the work; without it, the cost of the next session compounds.

## Failure routing — when a gate stays closed

| Gate that fails | Returns to                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------------- |
| G2              | `systematic-debugging` (4-phase root-cause)                                                          |
| G3 / G4         | `executing-plans` to re-run; after 3 failures, escalate to `brainstorming` to question architecture |
| G5              | `writing-plans` — typically the failure is a contract mismatch between tasks, not a bug at the task level |
| G6              | `receiving-code-review` to process feedback, then back to G2                                         |
| G7              | usually a missing handoff document — produce it via `session-handoff`                                |

## Terminal state

Only after G7 closes does the work enter `finishing-a-development-branch`, where the user (not the agent) chooses one of: merge / open PR / keep open / discard. The agent never auto-merges to a default branch.

## Cross-references

- 12 lectures → `references/twelve-lectures.md`
- 5-layer defense taxonomy → `references/five-layers.md`
- Skill writing convention → `references/skill-style.md`
