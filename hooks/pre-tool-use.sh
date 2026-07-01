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

# Allow if brainstorming is active, spec is approved, or quick-fix mode is active
[ -f "$PROJECT/.zeus/state/brainstorming-active" ] && exit 0
[ -f "$PROJECT/.zeus/state/spec-approved" ] && exit 0
[ -f "$PROJECT/.zeus/state/quick-fix-active" ] && exit 0

# Block — stderr is shown to the model
echo "Zeus: code changes are gated until a spec is approved. Options:
  • Small hotfix? Run /quick-fix <description> — the agent judges eligibility
    against the senior-architect rubric and, once you confirm, stamps the bypass.
  • Larger change? Run /brainstorm to design it (produces an approved spec).
No marker found in .zeus/state/ (brainstorming-active | spec-approved | quick-fix-active)." >&2
exit 2
