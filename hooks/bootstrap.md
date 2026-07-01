## Zeus plugin — skill routing

Zeus is active. When a user message matches an intent below, invoke the skill via the Skill tool before proceeding.

| User intent | Skill to invoke |
|---|---|
| New feature / "implement X" / "add Y" / "build Z" | `zeus:brainstorming` |
| Approved spec ready for planning | `zeus:writing-plans` |
| Bug / test failure / "this doesn't work" | `zeus:systematic-debugging` |
| Task completion / "ship it" / "we're done" | `zeus:verification-before-completion` |
| Session ending / context limit | `zeus:session-handoff` |

Note: Edit/Write tool calls are blocked by the zeus PreToolUse hook until a brainstorming spec is approved OR quick-fix mode is active. If a write is denied, invoke `zeus:brainstorming` to unblock (or use the quick-fix bypass below).

## Quick-fix bypass (小修复直通)

The user can initiate this directly with **`/quick-fix <description>`**, or you offer it when a request is clearly a small, bounded fix. Either way, you judge eligibility from a **senior-architect lens** — the *nature* of the change, not a file count.

**Eligibility — disqualifier rubric (ANY one hit → route to full process, NOT quick-fix):**
- Touches architecture or module boundaries
- Introduces a new abstraction, or a new dependency
- Changes a public API, a contract, or a data format
- Alters state ownership or the concurrency model
- Touches security, authentication, or authorization
- Requires weighing multiple design approaches (a real design decision)

If none of the above are hit, it qualifies. Examples that qualify: a local logic
correction, copy/text change, unambiguous off-by-one, a null-guard, a config-value
tweak, a dependency version bump with no API change.

**Flow:**
1. **Judge and announce your verdict with reasoning.** Apply the rubric to the described change plus the relevant code. State the verdict out loud: eligible, or ineligible naming the exact disqualifier that tripped.
2. **If eligible:**
   - Confirm with the user (a plain confirmation, or the `/quick-fix` invocation itself is the consent).
   - Run: `echo "quick-fix" > .zeus/state/quick-fix-active`
   - Ask execution mode (see below).
   - Implement directly — still run verification (tests, lint) before reporting done.
   - On completion: `rm -f .zeus/state/quick-fix-active` (one authorization = one hotfix; never leave it on).
   - If mid-implementation you discover architectural depth, stop, `rm -f` the marker, and recommend the full process — a quick-fix that grew up is no longer a quick-fix.
3. **If ineligible:** do NOT stamp the marker. Softly recommend `/brainstorm`, stating which rubric item disqualified it. The user MAY override with explicit confirmation — that confirmation is the recorded authorization; only then stamp the marker and proceed.

## Execution mode (always ask)

For ALL development tasks — whether full-process or quick-fix, regardless of task size — always ask the user via `AskUserQuestion`:
- Question: "选择执行模式 / Choose execution mode"
- Header: "Mode"
- Options:
  - `sequential` — execute in the current session directly
  - `subagent` — dispatch to a fresh subagent (with two-stage review if plan-based)

Never auto-select. The user always decides. Print a one-line hint about what you'd recommend and why, but present both options.

All zeus skills: `zeus:<skill-name>`. Full reference: invoke `zeus:using-zeus`.
