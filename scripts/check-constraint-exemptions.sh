#!/usr/bin/env bash
# check-constraint-exemptions.sh — verify a spec's Constraint Exemptions subsection.
#
# Usage: check-constraint-exemptions.sh <spec>
# Exit:  0  = well-formed ((none) XOR >=1 valid EX record)
#        1  = missing subsection, malformed EX record, mixed, or empty
#        64 = usage error (wrong args / unreadable file)
#
# Grammar (normative source: references/engineering-constraints.md):
#   - **EX-<n>** — exempts EC-<k> — scope: <text> — reason: <text>
# where scope and reason must each hold non-blank text.
# Judged ONLY inside the region between the '### Constraint Exemptions' heading
# and the next heading of any level — '(none)' or EX text elsewhere in the spec
# is prose, never a declaration (same scoping philosophy as check-spec-coverage.sh).
# A line is an EX-looking candidate when it looks like a record: a list item
# ('-'/'*'/'+' bullet or '1.'/'1)' number) naming a word-bounded EX-ID, or a line
# opening with a bold '**EX-<n>**'. Every candidate must be a well-formed record;
# other prose inside the subsection may mention EX-IDs freely.
# Tolerated: a leading '- ' before (none), leading spaces or tabs, trailing
# blanks, and CRLF line endings (region lines are read with the CR stripped).
# Known limits (documented, deliberately unhandled — see F-004 review):
#   - fenced code blocks are not tracked; a heading or record inside ``` fences
#     is treated as real. Meta-specs quoting the grammar should keep examples
#     outside the subsection.
#   - EX-ID uniqueness ("never reused") is normative prose, not checked here.
#   - the heading must be spelled exactly '### Constraint Exemptions' (blanks
#     after '###' and trailing blanks are tolerated).
#   - the parent section is not verified; the subsection belongs under
#     '## Architecture / Context dependencies' (references/engineering-constraints.md).
# NOTE: set -u (not set -e) — grep -c returning 1 on zero matches is a valid
# result here, not a fatal error.
set -u

PROG="$(basename "$0")"

usage() {
  printf 'usage: %s <spec>\n' "$PROG" >&2
  exit 64
}

[ "$#" -eq 1 ] || usage
spec="$1"
if [ ! -f "$spec" ] || [ ! -r "$spec" ]; then usage; fi

# Slice the subsection region (its own heading line excluded). awk exits 3 when
# the heading never appeared, so a missing region is distinguishable from an
# empty one. The spec is read on stdin, so a path shaped like an awk assignment
# (e.g. 'x=1.md') is never taken as one.
region="$(awk '
  /^###[ \t]+Constraint Exemptions[ \t\r]*$/ { inregion = 1; found = 1; next }
  inregion && /^#+[ \t]/ { inregion = 0 }
  inregion { sub(/\r$/, ""); print }
  END { exit found ? 0 : 3 }
' < "$spec")" || {
  printf 'MISSING: no "### Constraint Exemptions" subsection in %s\n' "$spec"
  exit 1
}

n_none="$(printf '%s\n' "$region" | grep -cE '^[[:blank:]]*(- )?\(none\)[[:blank:]]*$' || true)"
n_ex="$(printf '%s\n' "$region" | grep -cE '^[[:blank:]]*- \*\*EX-[0-9]+\*\* — exempts EC-[1-8] — scope: [[:blank:]]*[^[:blank:]].* — reason: [[:blank:]]*[^[:blank:]].*$' || true)"
n_exlike="$(printf '%s\n' "$region" | grep -cE '^[[:blank:]]*([-*+]|[0-9]+[.)])[[:blank:]](.*[^[:alnum:]])?EX-[0-9]|^[[:blank:]]*\*\*EX-[0-9]' || true)"

if [ "$n_exlike" -gt "$n_ex" ]; then
  printf 'MALFORMED: %s EX-looking line(s) fail the grammar in %s (need: - **EX-n** — exempts EC-k — scope: ... — reason: ...; scope and reason must be non-blank)\n' \
    "$((n_exlike - n_ex))" "$spec"
  exit 1
fi
if [ "$n_none" -gt 0 ] && [ "$n_ex" -gt 0 ]; then
  printf 'MIXED: both (none) and EX records present in %s — pick one\n' "$spec"
  exit 1
fi
if [ "$n_none" -eq 0 ] && [ "$n_ex" -eq 0 ]; then
  printf 'MALFORMED: subsection present but empty in %s — write (none) or EX records\n' "$spec"
  exit 1
fi
if [ "$n_ex" -gt 0 ]; then
  printf 'OK: %s exemption record(s) declared\n' "$n_ex"
else
  printf 'OK: (none) — no exemptions declared\n'
fi
exit 0
