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

When the user's request is clearly a **small, bounded fix** — typo, config tweak, one-liner bug, style change, dependency bump, or any change where the scope is self-evident and a full spec would be pure ceremony — you MUST offer the quick-fix bypass before routing to `zeus:brainstorming`.

**Criteria for quick-fix eligibility:**
- Scope is obvious and self-contained (≤ 3 files, no architectural decision)
- No new abstractions, no new dependencies, no API surface change
- The user's intent is unambiguous — no design choices to explore

**Flow:**
1. Tell the user: "这个任务看起来是小修复，可以跳过 7-gate 流程直接实施。/ This looks like a small fix — it can bypass the 7-gate cascade."
2. Ask via `AskUserQuestion`:
   - Question: "是否启用快速修复模式？(跳过 spec/plan 阶段，保留验证) / Enable quick-fix mode? (skips spec/plan, keeps verification)"
   - Header: "Quick-fix"
   - Options:
     - `Yes, bypass 7-gate` — proceed directly, skip brainstorming + planning
     - `No, full process` — route to `zeus:brainstorming` as normal
3. If user picks bypass:
   - Run: `echo "quick-fix" > .zeus/state/quick-fix-active`
   - Ask execution mode (see below)
   - Implement the fix directly — still run verification (tests, lint) before reporting done
   - On completion: `rm -f .zeus/state/quick-fix-active`
4. If user picks full process: route to `zeus:brainstorming` normally.

## Execution mode (always ask)

For ALL development tasks — whether full-process or quick-fix, regardless of task size — always ask the user via `AskUserQuestion`:
- Question: "选择执行模式 / Choose execution mode"
- Header: "Mode"
- Options:
  - `sequential` — execute in the current session directly
  - `subagent` — dispatch to a fresh subagent (with two-stage review if plan-based)

Never auto-select. The user always decides. Print a one-line hint about what you'd recommend and why, but present both options.

All zeus skills: `zeus:<skill-name>`. Full reference: invoke `zeus:using-zeus`.
