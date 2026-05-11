#!/usr/bin/env bash
# migrate-to-dotzeus.sh
#
# Per-project one-shot migration of zeus-generated artifacts to the .zeus/ layout.
#
# Moves:
#   docs/specs/  -> .zeus/specs/
#   docs/plans/  -> .zeus/plans/
#   FEATURES.md  -> .zeus/features.md
#
# Rewrites internal cross-references in markdown under skills/, references/, templates/.
#
# Idempotent: safe to re-run. Leaves changes STAGED but not committed — the user
# decides when to commit so the move can be packaged with related changes.
#
# Spec: docs/specs/2026-05-11-claude-md-compat-and-dotzeus-relocation-design.md
# Plan: docs/plans/2026-05-11-claude-md-compat-and-dotzeus-relocation.md
#
# Requirements: bash, git, find, sed, mktemp, cmp. No GNU-specific flags (BSD/darwin safe).

set -euo pipefail

# ---------- Preflight ----------

# 1. Must be inside a git worktree.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git worktree." >&2
  exit 1
fi

# 2. Refuse symlinked source dirs (security: avoid following symlinks out of repo).
for d in docs/specs docs/plans; do
  if [ -L "$d" ]; then
    echo "ERROR: $d is a symlink — refusing to migrate." >&2
    exit 1
  fi
done

# 3. Decide which sources still exist. If none, we're already migrated — exit cleanly.
SOURCES_THAT_EXIST=()
[ -d docs/specs ] && [ -n "$(ls -A docs/specs 2>/dev/null)" ] && SOURCES_THAT_EXIST+=("docs/specs")
[ -d docs/plans ] && [ -n "$(ls -A docs/plans 2>/dev/null)" ] && SOURCES_THAT_EXIST+=("docs/plans")
[ -f FEATURES.md ] && SOURCES_THAT_EXIST+=("FEATURES.md")

if [ "${#SOURCES_THAT_EXIST[@]}" -eq 0 ]; then
  echo "Nothing to migrate — repo is already at the .zeus/ layout."
  # Still fall through to the sed pass: cross-references may need rewriting
  # even if file moves were already committed by a previous run.
else
  # Only the surviving sources must be clean (renames from a previous staged run are OK).
  DIRTY="$(git status --porcelain -- "${SOURCES_THAT_EXIST[@]}" 2>/dev/null | grep -v '^R ' || true)"
  if [ -n "$DIRTY" ]; then
    echo "ERROR: uncommitted changes in source paths. Commit or stash first." >&2
    echo "$DIRTY" >&2
    exit 1
  fi
fi

# ---------- Migration ----------

mkdir -p .zeus/specs .zeus/plans

# Move helper: uses `git mv` when source is tracked (preserves history),
# falls back to plain `mv` when source is untracked or gitignored. This
# lets projects that gitignore zeus's working artifacts still migrate.
move_file() {
  local src="$1" dest="$2"
  if git ls-files --error-unmatch -- "$src" >/dev/null 2>&1; then
    git mv "$src" "$dest"
  else
    mv "$src" "$dest"
  fi
}

migrate_dir() {
  # $1 source dir (e.g., docs/specs)
  # $2 dest dir (e.g., .zeus/specs)
  local src="$1" dest="$2" moved=0
  if [ -d "$src" ]; then
    for f in "$src"/*; do
      [ -e "$f" ] || continue
      move_file "$f" "$dest/$(basename "$f")"
      moved=$((moved + 1))
    done
    # Remove now-empty source dir (safe — only removes if empty).
    rmdir "$src" 2>/dev/null || true
    if [ "$moved" -gt 0 ]; then
      echo "  moved $moved file(s): $src/ -> $dest/"
    fi
  fi
}

migrate_dir "docs/specs" ".zeus/specs"
migrate_dir "docs/plans" ".zeus/plans"

# Also try to clean up an empty docs/ if zeus was the only thing in it.
rmdir docs 2>/dev/null || true

# FEATURES.md -> .zeus/features.md (idempotent).
if [ -f "FEATURES.md" ]; then
  move_file "FEATURES.md" ".zeus/features.md"
  echo "  moved FEATURES.md -> .zeus/features.md"
fi

# ---------- Internal cross-reference rewrite ----------

# Portable sed via tmpfile + cmp + cp. Works identically on BSD (darwin) and GNU.
TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

REWRITTEN_FILES=()

rewrite_refs() {
  local file="$1"
  # Use comma as the FEATURES.md delimiter so the inner `|` alternation
  # doesn't collide with BSD sed's delimiter parser on darwin.
  sed -E \
    -e 's|docs/specs/|.zeus/specs/|g' \
    -e 's|docs/plans/|.zeus/plans/|g' \
    -e 's,(^|[^./a-zA-Z0-9_-])FEATURES\.md,\1.zeus/features.md,g' \
    "$file" > "$TMPFILE"
  if ! cmp -s "$file" "$TMPFILE"; then
    cp "$TMPFILE" "$file"
    REWRITTEN_FILES+=("$file")
    echo "  rewrote refs in $file"
  fi
}

# Scan markdown under skill / reference / template trees AND under the
# migrated .zeus/specs/ and .zeus/plans/ directories themselves — plans
# cross-reference specs by path, and end-user projects need those
# internal links rewritten too. Skip this script itself (it intentionally
# mentions the legacy paths in its docstring).
while IFS= read -r -d '' file; do
  case "$file" in
    *scripts/migrate-to-dotzeus.sh) continue ;;
  esac
  rewrite_refs "$file"
done < <(find skills references templates .zeus/specs .zeus/plans -type f -name '*.md' -print0 2>/dev/null)

# Stage only the rewritten files that git actually tracks. Files inside
# .zeus/ may be gitignored (especially in projects like zeus itself that
# keep dogfooding artifacts local) — `git add` on those would fail under
# set -e. The rewrites still happen on disk; they just don't enter the
# index for ignored paths.
for f in "${REWRITTEN_FILES[@]}"; do
  if git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
    git add -- "$f"
  fi
done

# ---------- Report ----------

echo ""
echo "Migration complete. Changes are STAGED but not committed."
echo "Re-run this script anytime — it is idempotent."
echo ""
echo "Suggested commit:"
echo "  git commit -m 'chore: migrate zeus artifacts to .zeus/'"
