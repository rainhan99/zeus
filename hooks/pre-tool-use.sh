#!/usr/bin/env bash
# Zeus PreToolUse hook — hard enforcement via exit code 2.
# Fires before Edit, Write, and NotebookEdit.
#
# Logic:
#   1. Writes to .zeus/ → always allow
#   2. .zeus/state/brainstorming-active exists → allow (skill is running)
#   3. .zeus/state/spec-approved exists → allow (spec approved)
#   4. Otherwise → exit 2 (block, stderr shown to model)

set -u

INPUT="$(cat 2>/dev/null || echo '{}')"

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)"
PROJECT="${CWD:-${CLAUDE_PROJECT_DIR:-.}}"

# Always allow writes to .zeus/ and docs/specs/
case "$FILE_PATH" in
  */.zeus/*|*.zeus/*) exit 0 ;;
  */docs/specs/*) exit 0 ;;
esac

# Allow if brainstorming is active or spec is approved
[ -f "$PROJECT/.zeus/state/brainstorming-active" ] && exit 0
[ -f "$PROJECT/.zeus/state/spec-approved" ] && exit 0

# Block — stderr is shown to the model
echo "Zeus: code changes blocked. No approved brainstorming spec found. Invoke the Skill tool with zeus:brainstorming to start the design process and unblock writes." >&2
exit 2
