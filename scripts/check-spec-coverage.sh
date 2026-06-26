#!/usr/bin/env bash
# check-spec-coverage.sh — verify every spec SC-N maps to a task in the plan matrix.
#
# Usage: check-spec-coverage.sh <spec> <plan>
# Exit:  0  = full coverage (every spec SC-N has a non-empty task in the matrix)
#        1  = orphan SC-IDs (listed; reconcile against Manifest authorized-cuts)
#        2  = degraded (spec has no SC-N IDs — route to manual/LLM audit)
#        64 = usage error (wrong args / unreadable file)
#
# Raw-orphan detection only: reconciliation against authorized cuts (the
# Manifest 4-field block) is the writing-plans skill layer's responsibility,
# not this script's. NOTE: set -u (not set -e) — grep returning 1 on no-match
# is a valid result here (e.g. an all-orphan plan), not a fatal error.
set -u

PROG="$(basename "$0")"

usage() {
  printf 'usage: %s <spec> <plan>\n' "$PROG" >&2
  exit 64
}

[ "$#" -eq 2 ] || usage
spec="$1"
plan="$2"
if [ ! -f "$spec" ] || [ ! -r "$spec" ]; then usage; fi
if [ ! -f "$plan" ] || [ ! -r "$plan" ]; then usage; fi

# Spec SC-IDs: line-anchored checklist items only ("- **SC-N** ...").
# Inline mentions in prose / 7-gate maps never start this pattern.
spec_ids="$(grep -oE '^- \*\*SC-[0-9]+\*\*' "$spec" 2>/dev/null | grep -oE 'SC-[0-9]+' | sort -u || true)"

if [ -z "$spec_ids" ]; then
  printf 'DEGRADED: no SC-N IDs found in %s — route to manual/LLM audit\n' "$spec"
  exit 2
fi

# Covered SC-IDs from the "### Spec Coverage Matrix" (canonical 4 columns:
# SC-ID | Capability | Implementing task(s) | Verification command). A row is a
# table row (starts with "|") whose first cell carries an SC-N token (the cell
# may also hold descriptive text). The SC-N is covered iff the 3rd content
# column — "Implementing task(s)", awk field $4 — is non-empty and not a
# placeholder. Robust to extra text in the SC-ID cell; column order is fixed by
# the format that writing-plans mandates.
covered_ids="$(awk -F'|' '
    /^[ \t]*\|/ && $2 ~ /SC-[0-9]+/ {
      t = $4; gsub(/^[ \t]+|[ \t]+$/, "", t); lt = tolower(t);
      if (t != "" && t != "-" && t != "—" && lt != "(none)" && lt != "tbd" && lt != "n/a") print $2
    }' "$plan" 2>/dev/null \
  | grep -oE 'SC-[0-9]+' | sort -u || true)"

# Orphans = spec IDs with no covered counterpart (both inputs pre-sorted).
orphans="$(comm -23 <(printf '%s\n' "$spec_ids") <(printf '%s\n' "$covered_ids"))"

if [ -z "$orphans" ]; then
  total="$(printf '%s\n' "$spec_ids" | grep -c .)"
  printf 'OK: all %s SC-IDs covered\n' "$total"
  exit 0
fi

# One or more spec SC-IDs have no task in the matrix.
while IFS= read -r id; do
  [ -n "$id" ] || continue
  printf 'ORPHAN: %s has no task in %s (reconcile vs Manifest authorized-cuts if intentional)\n' "$id" "$plan"
done <<< "$orphans"
exit 1
