#!/usr/bin/env bash
# Zeus SessionStart hook.
# Reads hooks/bootstrap.md (NOT skills/using-zeus/SKILL.md) and emits it as
# additionalContext. bootstrap.md is a short enforcement-only file (< 5K chars)
# that stays well under Claude Code's 10K additionalContext limit.
#
# The full using-zeus/SKILL.md (with 7-gate cascade, 5-layer model, etc.) is
# loaded on demand when the agent invokes zeus:using-zeus via the Skill tool.
#
# Always exits 0 so a missing file never blocks a session.

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BOOTSTRAP_FILE="$SCRIPT_DIR/bootstrap.md"

if [ ! -f "$BOOTSTRAP_FILE" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
  exit 0
fi

BOOTSTRAP_CONTENT="$(cat "$BOOTSTRAP_FILE")"

WRAPPED="<EXTREMELY_IMPORTANT>
You have zeus installed — a full-lifecycle harness for Claude Code agents.

**Below is the zeus bootstrap. For all skills, use the Skill tool with zeus:<skill-name>:**

---
${BOOTSTRAP_CONTENT}
</EXTREMELY_IMPORTANT>"

ADDITIONAL_CONTEXT="$(printf '%s' "$WRAPPED" | jq -Rs .)"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$ADDITIONAL_CONTEXT"
exit 0
