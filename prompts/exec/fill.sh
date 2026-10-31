#!/usr/bin/env bash
# Fill the {{NAME}} placeholders in the exec templates from environment variables.
#
# Each {{NAME}} is replaced with the value of the environment variable NAME,
# and the result is written to filled/ next to this script (git ignores it).
# A template with any unset or empty variable is skipped, never half-filled.

set -euo pipefail
shopt -u patsub_replacement 2>/dev/null || true # bash 5.2+: keep "&" in values literal

dir=$(cd "$(dirname "$0")" && pwd)
out="$dir/filled"

placeholders() {
  { grep -oE '\{\{[A-Z0-9_]+\}\}' "$1" || true; } | sed 's/^{{//; s/}}$//' | sort -u
}

usage() {
  cat <<'EOF'
Usage: fill.sh [-h] [TEMPLATE...]

TEMPLATE is a template name such as 03-fix, 03-fix.md, or 03. With no
TEMPLATE, every template whose variables are all set is filled and the rest
are skipped.

Example:
  PR_URL=https://github.com/<owner>/<repo>/pull/<n> REVIEWER=<login> ./fill.sh 03-fix

Placeholders by template:
EOF
  local f
  for f in "$dir"/[0-9][0-9]-*.md; do
    printf '  %-14s %s\n' "$(basename "$f" .md)" "$(placeholders "$f" | tr '\n' ' ')"
  done
}

resolve() {
  local m
  for m in "$dir/$1" "$dir/$1.md" "$dir/$1"-*.md; do
    if [ -f "$m" ]; then
      echo "$m"
      return 0
    fi
  done
  return 1
}

fill() {
  local f=$1 name missing="" content
  for name in $(placeholders "$f"); do
    [ -n "${!name:-}" ] || missing="$missing $name"
  done
  if [ -n "$missing" ]; then
    echo "skipped $(basename "$f"): unset or empty:$missing" >&2
    return 1
  fi
  content=$(cat "$f"; printf x)
  content=${content%x}
  for name in $(placeholders "$f"); do
    content=${content//"{{$name}}"/${!name}}
  done
  mkdir -p "$out"
  printf '%s' "$content" >"$out/$(basename "$f")"
  echo "$out/$(basename "$f")"
}

case "${1:-}" in
-h | --help)
  usage
  exit 0
  ;;
esac

status=0
if [ $# -eq 0 ]; then
  count=0
  for f in "$dir"/[0-9][0-9]-*.md; do
    if fill "$f"; then count=$((count + 1)); fi
  done
  [ "$count" -gt 0 ] || status=1
else
  for arg in "$@"; do
    case "$arg" in
    */*)
      echo "not a template name: $arg" >&2
      status=1
      continue
      ;;
    esac
    if f=$(resolve "$arg"); then
      fill "$f" || status=1
    else
      echo "no such template: $arg" >&2
      status=1
    fi
  done
fi
exit "$status"
