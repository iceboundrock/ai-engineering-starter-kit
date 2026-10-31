#!/usr/bin/env bash
# Fill the {{NAME}} placeholders in the exec templates from environment variables.
#
# Each {{NAME}} is replaced with the value of the environment variable NAME,
# and the result is written to filled/ next to this script (git ignores it).
# Values are inserted literally, in one pass, so a value is never substituted again.
# A template with any unset or empty variable is skipped, never half-filled, and
# its output from an earlier run is removed so it cannot be mistaken for this one.

set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd)
out="$dir/filled"
token='[{][{]([A-Z0-9_]+)[}][}]'

placeholders() {
  { grep -oE '\{\{[A-Z0-9_]+\}\}' "$1" || true; } | sed 's/^{{//; s/}}$//' | sort -u
}

usage() {
  cat <<'EOF'
Usage: fill.sh [-h] [TEMPLATE...]

TEMPLATE is a template name such as 03-fix, 03-fix.md, or 03. With no
TEMPLATE, every template whose variables are all set is filled and the rest
are skipped. A template that is skipped or fails to write loses its output
from any earlier run. The exit status is non-zero if any write fails, if a
named template is skipped, or if nothing is filled.

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

# Remove a template's earlier output after a failed run, and say so.
discard() {
  [ -e "$1" ] || return 0
  if rm -f "$1"; then
    echo "  removed earlier output $1" >&2
  else
    echo "  could not remove earlier output $1; do not use it" >&2
  fi
}

# fill returns 1 when variables are missing and 2 when the output cannot be written.
fill() {
  local f=$1 name missing="" rest result="" match dest tmp
  dest="$out/$(basename "$f")"
  for name in $(placeholders "$f"); do
    [ -n "${!name:-}" ] || missing="$missing $name"
  done
  if [ -n "$missing" ]; then
    echo "skipped $(basename "$f"): unset or empty:$missing" >&2
    discard "$dest"
    return 1
  fi
  rest=$(cat "$f"; printf x)
  rest=${rest%x}
  while [[ $rest =~ $token ]]; do
    match=${BASH_REMATCH[0]}
    name=${BASH_REMATCH[1]}
    result+=${rest%%"$match"*}${!name}
    rest=${rest#*"$match"}
  done
  result+=$rest
  tmp="$dest.tmp.$$"
  if ! { [ ! -d "$dest" ] && mkdir -p "$out" && printf '%s' "$result" >"$tmp" && mv -f "$tmp" "$dest"; }; then
    rm -f "$tmp" 2>/dev/null || true
    echo "failed to write $dest" >&2
    discard "$dest"
    return 2
  fi
  echo "$dest"
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
    rc=0
    fill "$f" || rc=$?
    case $rc in
    0) count=$((count + 1)) ;;
    1) ;; # skipped: not every variable is set
    *) status=1 ;;
    esac
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
