#!/usr/bin/env bash
# Round-trip test harness for scripts/check-constraint-exemptions.sh.
# Runs the checker against tests/fixtures and against probes written at
# runtime, and asserts exit codes + key output.
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

# probe <name> <expected_code> <expected_substr> <region> [heading] [after]
# Writes a spec with printf %b (bytes exact, so no guard is needed): <heading>
# (default '### Constraint Exemptions'), <region>, <after>, then a closing
# section. Asserts on it like a fixture.
probe() {
  printf '# Probe\n\n## Architecture / Context dependencies\n\n%b\n\n%b\n\n%b## Environment requirements\n' \
    "${5:-### Constraint Exemptions}" "$4" "${6:-}" > "$PROBE/$1.md"
  assert "$1" "$2" "$3" "$PROBE/$1.md"
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
# The CRLF, tab, blank-run, and indented fixtures test something only while
# they hold those bytes; an editor or a line-ending conversion would make
# them vacuous.
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
for f in ex-spec-indented.md ex-spec-none-indented-malformed.md; do
  grep -q '^[[:blank:]]\{1,\}- \*\*EX-' "$FIX/$f" || { echo "FAIL  fixture bytes: $f lost its indentation"; exit 1; }
done
assert "crlf-none-ok"          0  "OK"        "$FIX/ex-spec-crlf-none.md"
assert "tab-none-ok"           0  "OK"        "$FIX/ex-spec-tab-none.md"
assert "tab-record-ok"         0  "OK: 1"     "$FIX/ex-spec-tab-record.md"
assert "none-bare-record"      1  "MALFORMED" "$FIX/ex-spec-none-bare-record.md"
assert "none-numbered-record"  1  "MALFORMED" "$FIX/ex-spec-none-numbered-record.md"
assert "none-bullet-malformed" 1  "MALFORMED" "$FIX/ex-spec-none-bullet-malformed.md"
assert "none-prose-bold-ok"    0  "OK"        "$FIX/ex-spec-none-prose-bold.md"
assert "none-index-word-ok"    0  "OK"        "$FIX/ex-spec-none-index-word.md"
assert "indented-ok"    0  "OK: 1"     "$FIX/ex-spec-indented.md"
assert "none-indented-malformed" 1 "MALFORMED" "$FIX/ex-spec-none-indented-malformed.md"
assert "none-star-record"      1  "MALFORMED" "$FIX/ex-spec-none-star-record.md"
assert "none-paren-number"     1  "MALFORMED" "$FIX/ex-spec-none-paren-number.md"
assert "blank-scope"           1  "MALFORMED" "$FIX/ex-spec-blank-scope.md"
assert "blank-reason"          1  "MALFORMED" "$FIX/ex-spec-blank-reason.md"
assert "blank-both"            1  "MALFORMED" "$FIX/ex-spec-blank-both.md"
assert "lead-blank-ok"         0  "OK: 1"     "$FIX/ex-spec-lead-blank.md"
assert "blank-scope-hint"      1  "non-blank" "$FIX/ex-spec-blank-scope.md"
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

# Probes: each pins one element of the checker that no fixture above
# exercises — usage checks, heading and region edges, the (none) line, record
# tokens, and record-shaped detection beside (none).
# The probe dir is made here, after the fixture asserts, so a read-only
# environment still runs those before failing loudly.
PROBE="$(mktemp -d)"
[ -n "$PROBE" ] && [ -d "$PROBE" ] || { echo "FAIL  probe setup: mktemp -d failed"; exit 1; }
trap 'rm -rf "$PROBE"' EXIT
R='- **EX-1** — exempts EC-1 — scope: a — reason: b'
assert "two-args"      64 "usage" "$FIX/ex-spec-none.md" "$FIX/ex-spec-none.md"
assert "directory-arg" 64 "usage" "$PROBE"
printf 'x\n' > "$PROBE/unreadable.md"; chmod 000 "$PROBE/unreadable.md"
if [ -r "$PROBE/unreadable.md" ]; then
  echo "SKIP  unreadable-arg (running as root: mode 000 stays readable)"
else
  assert "unreadable-arg" 64 "usage" "$PROBE/unreadable.md"
fi
probe "heading-extra-blanks"        0 "OK"           '(none)' '###  Constraint Exemptions'
probe "heading-trailing-blanks"     0 "OK"           '(none)' '### Constraint Exemptions   '
probe "heading-in-prose"            1 "MISSING"      '(none)' 'See ### Constraint Exemptions'
probe "heading-level-4"             1 "MISSING"      '(none)' '#### Constraint Exemptions'
probe "heading-trailing-text"       1 "MISSING"      '(none)' '### Constraint Exemptions (draft)'
probe "next-subsection-ends-region" 0 "OK: (none)"   '(none)' '' '### Notes\n\n- EX-9 withdrawn\n\n'
probe "hash-line-inside-region"     0 "OK: (none)"   '#tag\n(none)'
probe "none-trailing-blanks"        0 "OK: (none)"   '(none)   '
probe "none-ending-prose"           0 "OK: 1"        "$R"'\nPreviously (none)'
probe "none-then-text"              1 "MALFORMED"    '(none) for now'
probe "none-brackets"               1 "MALFORMED"    '[none]'
probe "two-digit-ex-id"             0 "OK: 1"        '- **EX-10** — exempts EC-1 — scope: a — reason: b'
probe "ec-out-of-range"             1 "MALFORMED: 2" '- **EX-1** — exempts EC-0 — scope: a — reason: b\n- **EX-2** — exempts EC-9 — scope: a — reason: b'
probe "record-after-prose"          1 "MALFORMED"    "Note: $R"
probe "missing-first-dash"          1 "MALFORMED"    '- **EX-1** exempts EC-1 — scope: a — reason: b'
probe "missing-second-dash"         1 "MALFORMED"    '- **EX-1** — exempts EC-1 scope: a — reason: b'
probe "no-exempts-word"             1 "MALFORMED"    '- **EX-1** — waives EC-1 — scope: a — reason: b'
probe "wrong-scope-label"           1 "MALFORMED"    '- **EX-1** — exempts EC-1 — files: a — reason: b'
probe "wrong-reason-label"          1 "MALFORMED"    '- **EX-1** — exempts EC-1 — scope: a — why: b'
probe "unbolded-ex-id"              1 "MALFORMED"    '- EX-1 — exempts EC-1 — scope: a — reason: b'
probe "none-indented-bold"          1 "MALFORMED"    '(none)\n  **EX-1** — exempts EC-1 — scope: a — reason: b'
probe "none-tab-after-marker"       1 "MALFORMED"    '(none)\n-\tEX-1 withdrawn during review'
probe "none-plus-bullet"            1 "MALFORMED"    '(none)\n+ **EX-1** — exempts EC-1 — scope: a — reason: b'
probe "none-two-digit-number"       1 "MALFORMED"    '(none)\n10. EX-1 withdrawn'
probe "none-list-ex-no-digit"       0 "OK: (none)"   '(none)\n- see EX-A'
probe "none-bold-ex-no-digit"       0 "OK: (none)"   '(none)\n**EX-A** note'
probe "none-prose-dash-ex"          0 "OK: (none)"   '(none)\nNote - EX-1 was withdrawn'
probe "none-indented-prose-ex"      0 "OK: (none)"   '(none)\n  EX-1 was withdrawn'
probe "none-message"                0 "OK: (none)"   '(none)'

printf '\n%s passed, %s failed\n' "$pass" "$fail"
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
exit 1
