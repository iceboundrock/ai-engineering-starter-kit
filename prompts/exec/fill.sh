#!/usr/bin/env bash
# Fill the {{NAME}} placeholders in the exec templates from environment variables.
#
# Each {{NAME}} is replaced with the value of the environment variable NAME,
# and the result is written to filled/ next to this script (git ignores it).
# Values are inserted literally, in one pass, so a value is never substituted again.
# A template with any unset or empty variable is skipped, never half-filled. A
# skipped template, or one that cannot be read or written, has its output from an
# earlier run removed so it cannot be mistaken for this one.

set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd)
out="$dir/filled"
token='[{][{]([A-Z0-9_]+)[}][}]'

# placeholders <template>: its placeholder names, one per line. Returns 2 if the
# template cannot be read; grep's "no match" status (1) is not an error.
placeholders() {
  local found rc=0
  found=$(grep -oE '\{\{[A-Z0-9_]+\}\}' "$1") || rc=$?
  [ "$rc" -le 1 ] || return 2
  [ -z "$found" ] || printf '%s\n' "$found" | sed 's/^{{//; s/}}$//' | sort -u
}

usage() {
  cat <<'EOF'
Usage: fill.sh [-h] [TEMPLATE...]

TEMPLATE is a template name such as 03-fix, 03-fix.md, or 03. With no
TEMPLATE, every template whose variables are all set is filled and the rest
are skipped. A template that is skipped, or cannot be read or written, loses
its output from any earlier run. The exit status is non-zero if any template
cannot be read or written, if a named template is skipped, or if nothing is
filled.

Example:
  PR_URL=https://github.com/<owner>/<repo>/pull/<n> REVIEWER=<login> ./fill.sh 03-fix

Placeholders by template:
EOF
  local f names
  for f in "$dir"/[0-9][0-9]-*.md; do
    if names=$(placeholders "$f" 2>/dev/null); then
      names=$(printf '%s' "$names" | tr '\n' ' ')
    else
      names="(cannot read)"
    fi
    printf '  %-14s %s\n' "$(basename "$f" .md)" "$names"
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

# fill returns 1 when variables are missing, and 2 when the template cannot be read
# or the output cannot be written.
fill() {
  local f=$1 name names missing="" rest result="" match dest tmp
  dest="$out/$(basename "$f")"
  if ! names=$(placeholders "$f") || ! rest=$(cat "$f" && printf x); then
    echo "cannot read $(basename "$f")" >&2
    discard "$dest"
    return 2
  fi
  rest=${rest%x}
  for name in $names; do
    [ -n "${!name:-}" ] || missing="$missing $name"
  done
  if [ -n "$missing" ]; then
    echo "skipped $(basename "$f"): unset or empty:$missing" >&2
    discard "$dest"
    return 1
  fi
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
