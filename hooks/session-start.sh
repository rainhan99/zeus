#!/usr/bin/env bash
# Zeus SessionStart hook.
# 1. Clears stale brainstorming markers so every session starts fresh.
# 2. Reads hooks/bootstrap.md and emits it as additionalContext.
# Always exits 0 so a missing file never blocks a session.

set -u

# Clear stale markers — forces brainstorming on each new session
PROJECT="${CLAUDE_PROJECT_DIR:-.}"
rm -f "$PROJECT/.zeus/state/spec-approved" "$PROJECT/.zeus/state/brainstorming-active" 2>/dev/null

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BOOTSTRAP_FILE="$SCRIPT_DIR/bootstrap.md"

if [ ! -f "$BOOTSTRAP_FILE" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
  exit 0
fi

BOOTSTRAP_CONTENT="$(cat "$BOOTSTRAP_FILE")"

ADDITIONAL_CONTEXT="$(printf '%s' "$BOOTSTRAP_CONTENT" | jq -Rs .)"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$ADDITIONAL_CONTEXT"
exit 0
