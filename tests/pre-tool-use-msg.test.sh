#!/usr/bin/env bash
# Tests for hooks/pre-tool-use.sh — SC-6 (actionable block message) plus a
# regression that existing unblock conditions still allow writes.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
HOOK="$ROOT/hooks/pre-tool-use.sh"

pass=0; fail=0
check() { if [ "$1" -eq 0 ]; then printf 'PASS  %s\n' "$2"; pass=$((pass+1)); else printf 'FAIL  %s\n' "$2"; fail=$((fail+1)); fi; }

FIX="$(mktemp -d)"; trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/.zeus/state"
payload() { printf '{"cwd":"%s","tool_input":{"file_path":"%s/foo.ts"}}' "$FIX" "$FIX"; }

# 1. No markers → blocked (exit 2) with actionable /quick-fix message on stderr.
ERR="$(payload | bash "$HOOK" 2>&1 >/dev/null)"; code=$?
[ "$code" -eq 2 ]; check $? "blocked with exit 2 when no marker"
printf '%s' "$ERR" | grep -q '/quick-fix'; check $? "SC-6: block message mentions /quick-fix"

# 2. Regression: each existing unblock marker allows the write (exit 0).
for m in brainstorming-active spec-approved quick-fix-active; do
  : > "$FIX/.zeus/state/$m"
  payload | bash "$HOOK" >/dev/null 2>&1; c=$?
  [ "$c" -eq 0 ]; check $? "unblock via $m (exit 0)"
  rm -f "$FIX/.zeus/state/$m"
done

# 3. Regression: writes to .zeus/ always allowed even with no marker.
if printf '{"cwd":"%s","tool_input":{"file_path":"%s/.zeus/x"}}' "$FIX" "$FIX" | bash "$HOOK" >/dev/null 2>&1; then
  check 0 ".zeus/ write always allowed"
else
  check 1 ".zeus/ write always allowed"
fi

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && { echo "ALL PASS"; exit 0; }
exit 1
