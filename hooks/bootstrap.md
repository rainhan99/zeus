## Zeus plugin — skill routing

Zeus is active. When a user message matches an intent below, invoke the skill via the Skill tool before proceeding.

| User intent | Skill to invoke |
|---|---|
| New feature / "implement X" / "add Y" / "build Z" | `zeus:brainstorming` |
| Approved spec ready for planning | `zeus:writing-plans` |
| Bug / test failure / "this doesn't work" | `zeus:systematic-debugging` |
| Task completion / "ship it" / "we're done" | `zeus:verification-before-completion` |
| Session ending / context limit | `zeus:session-handoff` |

Note: Edit/Write tool calls are blocked by the zeus PreToolUse hook until a brainstorming spec is approved. If a write is denied, invoke `zeus:brainstorming` to unblock.

All zeus skills: `zeus:<skill-name>`. Full reference: invoke `zeus:using-zeus`.
