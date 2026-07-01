#!/usr/bin/env bash
# Zeus SessionStart hook.
# 1. Clears stale brainstorming markers so every session starts fresh.
# 2. Reads hooks/bootstrap.md and emits it as additionalContext.
# Always exits 0 so a missing file never blocks a session.

set -u

# Resolve project root the same way pre-tool-use.sh does: prefer stdin .cwd
# (what Claude reports as its working directory), then $CLAUDE_PROJECT_DIR,
# then $PWD. Never fall back to "." — a relative path against the hook
# subprocess's cwd is meaningless (would clear markers in the wrong dir).
INPUT="$(cat 2>/dev/null || echo '{}')"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
PROJECT="${CWD:-${CLAUDE_PROJECT_DIR:-$PWD}}"

# Clear stale markers — forces brainstorming on each new session, and prevents
# a leaked quick-fix marker from keeping the write gate open into a new session.
rm -f "$PROJECT/.zeus/state/spec-approved" \
      "$PROJECT/.zeus/state/brainstorming-active" \
      "$PROJECT/.zeus/state/quick-fix-active" 2>/dev/null

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
