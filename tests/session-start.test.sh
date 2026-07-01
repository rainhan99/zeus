#!/usr/bin/env bash
# Tests for hooks/session-start.sh — SC-5 (cwd-based PROJECT resolution) and
# SC-7 (stale quick-fix marker cleanup). Runs the hook with synthetic stdin.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
HOOK="$ROOT/hooks/session-start.sh"

pass=0; fail=0
check() { # <name> <condition-exit> ; reads $? via caller
  if [ "$1" -eq 0 ]; then printf 'PASS  %s\n' "$2"; pass=$((pass+1));
  else printf 'FAIL  %s\n' "$2"; fail=$((fail+1)); fi
}

FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/.zeus/state"
: > "$FIX/.zeus/state/quick-fix-active"      # plant a stale marker
: > "$FIX/.zeus/state/spec-approved"          # plant (should also be cleared)

# Run hook with cwd in stdin, CLAUDE_PROJECT_DIR unset. If the hook resolves
# PROJECT to "." (the bug), it cleans the wrong dir and the planted markers survive.
OUT="$(unset CLAUDE_PROJECT_DIR; printf '%s' "{\"cwd\":\"$FIX\"}" | bash "$HOOK" 2>/dev/null)"

# SC-7: stale quick-fix marker removed in the stdin-cwd dir
[ ! -e "$FIX/.zeus/state/quick-fix-active" ]; check $? "SC-7: stale quick-fix-active cleared in cwd dir"
# existing behavior: spec-approved also cleared
[ ! -e "$FIX/.zeus/state/spec-approved" ]; check $? "spec-approved cleared in cwd dir"
# hook still emits additionalContext JSON
printf '%s' "$OUT" | grep -q 'additionalContext'; check $? "additionalContext still emitted"
# SC-5: no '.' fallback in the script source
! grep -q 'CLAUDE_PROJECT_DIR:-\.' "$HOOK"; check $? "SC-5: no CLAUDE_PROJECT_DIR:-. fallback in source"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && { echo "ALL PASS"; exit 0; }
exit 1
