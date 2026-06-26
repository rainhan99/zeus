#!/usr/bin/env bash
# Round-trip test harness for scripts/check-spec-coverage.sh.
# Runs the detector against tests/fixtures and asserts exit codes + key output.
# Prints "ALL PASS" and exits 0 only when every assertion holds; else exits 1.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
DETECTOR="$ROOT/scripts/check-spec-coverage.sh"
FIX="$HERE/fixtures"

pass=0
fail=0

# assert <name> <expected_code> <expected_substr> <spec> <plan>
assert() {
  name="$1"; exp_code="$2"; exp_sub="$3"; shift 3
  out="$(bash "$DETECTOR" "$@" 2>&1)"; code=$?
  if [ "$code" -eq "$exp_code" ] && printf '%s' "$out" | grep -qF "$exp_sub"; then
    printf 'PASS  %s (exit %s, matched "%s")\n' "$name" "$code" "$exp_sub"
    pass=$((pass + 1))
  else
    printf 'FAIL  %s — expected exit %s + "%s", got exit %s:\n%s\n' \
      "$name" "$exp_code" "$exp_sub" "$code" "$out"
    fail=$((fail + 1))
  fi
}

# assert_code <name> <expected_code> [args...]  (no substring check)
assert_code() {
  name="$1"; exp_code="$2"; shift 2
  out="$(bash "$DETECTOR" "$@" 2>&1)"; code=$?
  if [ "$code" -eq "$exp_code" ]; then
    printf 'PASS  %s (exit %s)\n' "$name" "$code"
    pass=$((pass + 1))
  else
    printf 'FAIL  %s — expected exit %s, got exit %s:\n%s\n' "$name" "$exp_code" "$code" "$out"
    fail=$((fail + 1))
  fi
}

assert "degraded" 2 "DEGRADED" "$FIX/sc-spec-legacy.md" "$FIX/sc-plan-full.md"
assert "full"     0 "OK"       "$FIX/sc-spec-full.md"   "$FIX/sc-plan-full.md"
assert "orphan"   1 "SC-2"     "$FIX/sc-spec-full.md"   "$FIX/sc-plan-orphan.md"
# Regression for C-1: an SC-N in a NON-matrix table must not mask a true orphan.
assert "decoy-scoping" 1 "SC-2" "$FIX/sc-spec-full.md" "$FIX/sc-plan-decoy.md"
# Regression for M-1: placeholder task cells (none/todo/...) are NOT coverage.
assert "placeholder"   1 "SC-1" "$FIX/sc-spec-full.md" "$FIX/sc-plan-placeholder.md"
# Regression for R-1: a 2nd task-header table OUTSIDE the Manifest section must
# not mask a true orphan dropped by the real matrix.
assert "stale-matrix"  1 "SC-2" "$FIX/sc-spec-full.md" "$FIX/sc-plan-stale-matrix.md"
assert_code "usage-noargs"  64
assert_code "usage-missing" 64 "$FIX/sc-spec-full.md" "$FIX/does-not-exist.md"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
exit 1
