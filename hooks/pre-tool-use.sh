#!/usr/bin/env bash
# Zeus PreToolUse hook.
# Fires before Edit, Write, and NotebookEdit tool calls.
#
# Enforcement logic:
#   1. Writes to .zeus/ directory → always allow (specs, state, memory)
#   2. .zeus/state/spec-approved exists → allow (brainstorming done)
#   3. Otherwise → deny with reason (forces brainstorming first)
#
# Uses permissionDecision:"deny" for hard enforcement that auto mode
# cannot override. The model sees permissionDecisionReason and is
# forced to invoke zeus:brainstorming before writing any code.

set -u

TOOL_INPUT="$(cat /dev/stdin 2>/dev/null || echo '{}')"

FILE_PATH="$(printf '%s' "$TOOL_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)"

if printf '%s' "$FILE_PATH" | grep -q '\.zeus/' 2>/dev/null; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}\n'
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MARKER="$PROJECT_DIR/.zeus/state/spec-approved"

if [ -f "$MARKER" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}\n'
  exit 0
fi

REASON="Zeus enforcement: no approved brainstorming spec found. Code changes are blocked until a spec is approved. To unblock, invoke the Skill tool with skill name zeus:brainstorming — this will walk through the design process and produce an approved spec. After approval, code changes will be allowed. This applies in all modes including auto mode."

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$REASON"
exit 0
