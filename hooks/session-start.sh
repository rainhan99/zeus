#!/usr/bin/env bash
# Zeus SessionStart hook.
# Reads using-zeus/SKILL.md, wraps it in <EXTREMELY_IMPORTANT> tags, and emits
# it as additionalContext for Claude Code's SessionStart event.
# Always exits 0 so a missing file never blocks a session.

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_FILE="$SCRIPT_DIR/../skills/using-zeus/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
  exit 0
fi

SKILL_CONTENT="$(cat "$SKILL_FILE")"

WRAPPED_CONTENT="<EXTREMELY_IMPORTANT>
You have zeus installed — a full-lifecycle harness for Claude Code agents.

**Below is the full content of your 'zeus:using-zeus' skill — your introduction to using zeus skills. For all other skills, use the Skill tool:**

---
${SKILL_CONTENT}
</EXTREMELY_IMPORTANT>"

ADDITIONAL_CONTEXT="$(printf '%s' "$WRAPPED_CONTENT" | jq -Rs .)"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$ADDITIONAL_CONTEXT"
exit 0
