---
description: Initiate a 7-gate bypass for a genuine hotfix — the agent judges eligibility against a senior-architect rubric, then implements directly with verification still enforced.
argument-hint: <change description>
---

The user wants to fast-path a small change past the spec gate. Follow the **Quick-fix bypass** flow in `hooks/bootstrap.md` — do not invent your own criteria.

1. If `$ARGUMENTS` is empty, ask the user in one sentence what the change is before doing anything else.
2. Judge eligibility against the senior-architect **disqualifier rubric** in `hooks/bootstrap.md` (architecture/module boundaries, new abstraction/dependency, public API/contract/data-format change, state-ownership/concurrency change, security/auth, or a real multi-approach design decision — ANY one hit disqualifies). Apply it to `$ARGUMENTS` plus the relevant code, not just the description.
3. **Announce your verdict with reasoning** before acting.
   - **Eligible** → stamp the marker: `echo "quick-fix" > .zeus/state/quick-fix-active`, ask execution mode, implement the fix, run verification (tests + lint), then remove the marker on completion: `rm -f .zeus/state/quick-fix-active`. One `/quick-fix` authorizes one hotfix — never leave the marker on.
   - **Ineligible** → do NOT stamp the marker. Recommend `/brainstorm`, naming the disqualifier that tripped. Proceed only if the user explicitly overrides, and treat that confirmation as the recorded authorization.
4. If partway through you discover the change touches architecture, stop, `rm -f .zeus/state/quick-fix-active`, and route to `zeus:brainstorming`.
