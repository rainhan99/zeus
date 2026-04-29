#!/usr/bin/env bash
# Zeus SessionStart hook.
# Reads hooks/bootstrap.md and emits it as additionalContext.
# Always exits 0 so a missing file never blocks a session.

set -u

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
