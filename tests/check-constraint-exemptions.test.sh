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
# The CRLF, tab, and blank-run fixtures test something only while they hold
# those bytes; an editor or a line-ending conversion would make them vacuous.
LC_ALL=C grep -q "$(printf '\r')" "$FIX/ex-spec-crlf-none.md" || { echo "FAIL  fixture bytes: ex-spec-crlf-none.md holds no CR"; exit 1; }
for f in ex-spec-tab-none.md ex-spec-tab-record.md; do
  grep -q "$(printf '\t')" "$FIX/$f" || { echo "FAIL  fixture bytes: $f holds no tab"; exit 1; }
done
for f in ex-spec-blank-reason.md ex-spec-blank-both.md; do
  grep -q 'reason:[[:blank:]]\{2,\}$' "$FIX/$f" || { echo "FAIL  fixture bytes: $f lost its trailing blanks"; exit 1; }
done
for f in ex-spec-blank-scope.md ex-spec-blank-both.md; do
  grep -q 'scope:[[:blank:]]\{3,\}—' "$FIX/$f" || { echo "FAIL  fixture bytes: $f lost its scope blanks"; exit 1; }
done
grep -q 'scope:[[:blank:]]\{2,\}[^[:blank:]].*reason:[[:blank:]]\{2,\}[^[:blank:]]' "$FIX/ex-spec-lead-blank.md" || { echo "FAIL  fixture bytes: ex-spec-lead-blank.md lost its leading blanks"; exit 1; }
assert "crlf-none-ok"          0  "OK"        "$FIX/ex-spec-crlf-none.md"
assert "tab-none-ok"           0  "OK"        "$FIX/ex-spec-tab-none.md"
assert "tab-record-ok"         0  "OK: 1"     "$FIX/ex-spec-tab-record.md"
assert "none-bare-record"      1  "MALFORMED" "$FIX/ex-spec-none-bare-record.md"
assert "none-numbered-record"  1  "MALFORMED" "$FIX/ex-spec-none-numbered-record.md"
assert "none-bullet-malformed" 1  "MALFORMED" "$FIX/ex-spec-none-bullet-malformed.md"
assert "none-prose-bold-ok"    0  "OK"        "$FIX/ex-spec-none-prose-bold.md"
assert "none-index-word-ok"    0  "OK"        "$FIX/ex-spec-none-index-word.md"
assert "none-indented-malformed" 1 "MALFORMED" "$FIX/ex-spec-none-indented-malformed.md"
assert "none-star-record"      1  "MALFORMED" "$FIX/ex-spec-none-star-record.md"
assert "none-paren-number"     1  "MALFORMED" "$FIX/ex-spec-none-paren-number.md"
assert "blank-scope"           1  "MALFORMED" "$FIX/ex-spec-blank-scope.md"
assert "blank-reason"          1  "MALFORMED" "$FIX/ex-spec-blank-reason.md"
assert "blank-both"            1  "MALFORMED" "$FIX/ex-spec-blank-both.md"
assert "lead-blank-ok"         0  "OK: 1"     "$FIX/ex-spec-lead-blank.md"
# awk must read the spec on stdin: a relative path shaped like an awk
# assignment (identifier=value) would otherwise be taken as one.
out="$(cd "$FIX" && bash "$CHECKER" 'awkvar=spec.md' </dev/null 2>&1)"; code=$?
if [ "$code" -eq 0 ] && printf '%s' "$out" | grep -qF "OK"; then
  printf 'PASS  %s (exit %s)\n' "awk-assignment-path" "$code"
  pass=$((pass + 1))
else
  printf 'FAIL  %s — expected exit 0 + "OK", got exit %s:\n%s\n' "awk-assignment-path" "$code" "$out"
  fail=$((fail + 1))
fi
assert_code "usage-noargs"  64
assert_code "usage-missing" 64 "$FIX/does-not-exist.md"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
exit 1
