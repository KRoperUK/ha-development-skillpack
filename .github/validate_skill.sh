#!/usr/bin/env bash
# Validates SKILL.md frontmatter and internal reference integrity against the
# agentskills.io specification. Exits non-zero on any violation.
set -euo pipefail

fail=0
err() { echo "FAIL: $*" >&2; fail=1; }

# --- Resolve expected skill name (repo/directory name) ---
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
  expected="${GITHUB_REPOSITORY##*/}"
else
  expected="$(basename "$PWD")"
fi

[ -f SKILL.md ] || { echo "FAIL: SKILL.md not found" >&2; exit 1; }

# --- Frontmatter: name ---
name="$(awk -F': *' '/^name:/{print $2; exit}' SKILL.md | tr -d '"'"'"' \r')"
if [ -z "$name" ]; then
  err "frontmatter 'name' is missing"
else
  [ "${#name}" -le 64 ] || err "name exceeds 64 characters ($name)"
  echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' || err "name not lowercase kebab-case ($name)"
  [ "$name" = "$expected" ] || err "name '$name' does not match directory/repo '$expected'"
fi

# --- Frontmatter: description present and within 1024 chars ---
desc="$(awk '/^description:/{f=1;next} /^[a-zA-Z_-]+:/{f=0} f' SKILL.md | tr -d '\n')"
if [ -z "$(echo "$desc" | tr -d ' ')" ]; then
  err "frontmatter 'description' is missing or empty"
elif [ "${#desc}" -gt 1024 ]; then
  err "description exceeds 1024 characters (${#desc})"
fi

# --- Reference integrity: every referenced resource path must exist ---
refs="$(grep -rhoE '(references|assets|scripts)/[A-Za-z0-9_./-]+\.(md|yaml|sh)' SKILL.md references 2>/dev/null | sort -u || true)"
for f in $refs; do
  [ -e "$f" ] || err "broken reference: $f"
done

if [ "$fail" -eq 0 ]; then
  echo "OK: SKILL.md frontmatter and references valid (name=$name)"
fi
exit "$fail"
