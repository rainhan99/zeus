#!/usr/bin/env bash
# Zeus SessionStart hook.
# Reads using-zeus/SKILL.md and emits it as additionalContext for Claude Code's
# SessionStart event. Always exits 0 so a missing file never blocks a session.

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_FILE="$SCRIPT_DIR/../skills/using-zeus/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
  exit 0
fi

ADDITIONAL_CONTEXT="$(jq -Rs . < "$SKILL_FILE")"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$ADDITIONAL_CONTEXT"
exit 0
