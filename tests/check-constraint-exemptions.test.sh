#!/usr/bin/env bash
# Round-trip test harness for scripts/check-constraint-exemptions.sh.
# Runs the checker against tests/fixtures and asserts exit codes + key output.
# Prints "ALL PASS" and exits 0 only when every assertion holds; else exits 1.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
CHECKER="$ROOT/scripts/check-constraint-exemptions.sh"
FIX="$HERE/fixtures"

pass=0
fail=0

# assert <name> <expected_code> <expected_substr> [args...]
assert() {
  name="$1"; exp_code="$2"; exp_sub="$3"; shift 3
  out="$(bash "$CHECKER" "$@" 2>&1)"; code=$?
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
  out="$(bash "$CHECKER" "$@" 2>&1)"; code=$?
  if [ "$code" -eq "$exp_code" ]; then
    printf 'PASS  %s (exit %s)\n' "$name" "$code"
    pass=$((pass + 1))
  else
    printf 'FAIL  %s — expected exit %s, got exit %s:\n%s\n' "$name" "$exp_code" "$code" "$out"
    fail=$((fail + 1))
  fi
}

assert "none-ok"   0  "OK"        "$FIX/ex-spec-none.md"
assert "ex-ok"     0  "OK: 2"     "$FIX/ex-spec-ex.md"
assert "missing"   1  "MISSING"   "$FIX/ex-spec-missing.md"
assert "decoy"     1  "MISSING"   "$FIX/ex-spec-decoy.md"
assert "mixed"     1  "MIXED"     "$FIX/ex-spec-mixed.md"
assert "malformed" 1  "MALFORMED" "$FIX/ex-spec-malformed.md"
assert "empty"     1  "MALFORMED" "$FIX/ex-spec-empty.md"
assert "prose-ok"       0  "OK: 1"     "$FIX/ex-spec-prose.md"
assert "none-bullet-ok" 0  "OK"        "$FIX/ex-spec-none-bullet.md"
assert "indented-ok"    0  "OK: 1"     "$FIX/ex-spec-indented.md"
assert_code "usage-noargs"  64
assert_code "usage-missing" 64 "$FIX/does-not-exist.md"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
exit 1
