#!/usr/bin/env bash
# Zeus PreToolUse hook — hard enforcement via exit code 2.
# Fires before Edit, Write, and NotebookEdit.
#
# Logic:
#   1. Writes to .zeus/ → always allow
#   2. Not in a zeus project (no .zeus/ dir) → always allow
#   3. .zeus/state/brainstorming-active exists → allow (skill is running)
#   4. .zeus/state/spec-approved exists → allow (spec approved)
#   5. Otherwise → exit 2 (block, stderr shown to model)
#
# Project root resolution prefers stdin .cwd (what Claude reports as its
# working directory), then $CLAUDE_PROJECT_DIR (env var; not always set in
# plugin-hook context), then $PWD. We never fall back to "." — a relative
# path against the hook subprocess's cwd is meaningless.

set -u

INPUT="$(cat 2>/dev/null || echo '{}')"

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
PROJECT="${CWD:-${CLAUDE_PROJECT_DIR:-$PWD}}"

# Always allow writes to .zeus/ — the plugin's artifact directory.
case "$FILE_PATH" in
  */.zeus/*|*.zeus/*) exit 0 ;;
esac

# Not a zeus project → don't gate. Avoids false blocks when project root
# resolution missed and the user isn't actually using zeus here.
[ -d "$PROJECT/.zeus" ] || exit 0

# Allow if brainstorming is active or spec is approved
[ -f "$PROJECT/.zeus/state/brainstorming-active" ] && exit 0
[ -f "$PROJECT/.zeus/state/spec-approved" ] && exit 0

# Block — stderr is shown to the model
echo "Zeus: code changes blocked. No approved brainstorming spec found. Invoke the Skill tool with zeus:brainstorming to start the design process and unblock writes." >&2
exit 2
