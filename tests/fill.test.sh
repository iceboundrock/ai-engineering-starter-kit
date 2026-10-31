#!/usr/bin/env bash
# Regression tests for prompts/exec/fill.sh.
#
# Each case copies fill.sh into a fresh temporary directory with synthetic
# templates, so nothing in the repository is read or written except the script.
# Usage: bash tests/fill.test.sh
set -u

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/prompts/exec/fill.sh"
work=$(mktemp -d)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
pass=0 fail=0 skip=0

setup() { # setup <case>: fresh directory with fill.sh and two templates
  d="$work/$1"
  mkdir -p "$d"
  cp "$src" "$d/fill.sh"
  printf 'A={{AAA}} B={{BBB}}\n\n' >"$d/01-demo.md"
  printf 'only {{CCC}}\n' >"$d/02-other.md"
}
check() { # check <name> <status> <detail>
  if [ "$2" -eq 0 ]; then
    pass=$((pass + 1)) && echo "PASS $1"
  else
    fail=$((fail + 1)) && echo "FAIL $1: $3"
  fi
}

setup literal
AAA='x&y\z/w' BBB=$'two\nlines\n' bash "$d/fill.sh" 01-demo >/dev/null 2>&1
rc=$?
want=$'A=x&y\\z/w B=two\nlines\n\n\n'
got=$(cat "$d/filled/01-demo.md" 2>/dev/null; printf x)
got=${got%x}
[ $rc -eq 0 ] && [ "$got" = "$want" ]
check "values with & \\ / and newlines stay literal; trailing newlines kept" $? "rc=$rc got=$(printf %q "$got")"

setup single-pass
AAA='{{BBB}}' BBB=secret bash "$d/fill.sh" 01-demo >/dev/null 2>&1
rc=$?
got=$(head -1 "$d/filled/01-demo.md" 2>/dev/null)
[ $rc -eq 0 ] && [ "$got" = 'A={{BBB}} B=secret' ]
check "a value containing placeholder syntax is not substituted again" $? "rc=$rc got=$got"

setup missing
AAA=1 BBB= bash "$d/fill.sh" 01-demo >"$d/out" 2>"$d/err"
rc=$?
[ $rc -ne 0 ] && [ ! -e "$d/filled/01-demo.md" ] && grep -q BBB "$d/err" && [ ! -s "$d/out" ]
check "an unset or empty variable skips the template" $? "rc=$rc err=$(cat "$d/err")"

setup bad-args
AAA=1 BBB=1 bash "$d/fill.sh" nope >/dev/null 2>&1
rc1=$?
AAA=1 BBB=1 bash "$d/fill.sh" ../01-demo >/dev/null 2>&1
rc2=$?
[ $rc1 -ne 0 ] && [ $rc2 -ne 0 ]
check "unknown names and paths exit non-zero" $? "rc1=$rc1 rc2=$rc2"

setup write-failure
mkdir -p "$d/filled"
chmod 555 "$d/filled"
if [ -w "$d/filled" ]; then
  skip=$((skip + 1)) && echo "SKIP write failure (directory still writable, probably running as root)"
else
  AAA=1 BBB=1 bash "$d/fill.sh" 01-demo >"$d/out" 2>&1
  rc=$?
  [ $rc -ne 0 ] && ! grep -q "^$d/filled" "$d/out"
  check "a failed write exits non-zero and prints no output path" $? "rc=$rc out=$(cat "$d/out")"
fi
chmod 755 "$d/filled"

setup stale
AAA=old BBB=value bash "$d/fill.sh" 01-demo >/dev/null 2>&1
AAA=new BBB= bash "$d/fill.sh" 01-demo >/dev/null 2>&1
rc=$?
[ $rc -ne 0 ] && [ ! -e "$d/filled/01-demo.md" ]
check "a failed rerun removes the template's earlier output" $? "rc=$rc left=$(cat "$d/filled/01-demo.md" 2>/dev/null)"

setup fill-all-skip
CCC=old bash "$d/fill.sh" 02-other >/dev/null 2>&1
AAA=1 BBB=2 CCC= bash "$d/fill.sh" >"$d/out" 2>&1
rc=$?
[ $rc -eq 0 ] && [ -e "$d/filled/01-demo.md" ] && [ ! -e "$d/filled/02-other.md" ]
check "fill-all fills complete templates and clears skipped ones" $? "rc=$rc out=$(cat "$d/out")"

setup fill-all-write-failure
mkdir -p "$d/filled/02-other.md"
AAA=1 BBB=2 CCC=3 bash "$d/fill.sh" >"$d/out" 2>"$d/err"
rc=$?
[ $rc -ne 0 ] && [ -e "$d/filled/01-demo.md" ] && ! grep -q 02-other "$d/out"
check "fill-all fails when any write fails" $? "rc=$rc out=$(cat "$d/out") err=$(cat "$d/err")"

setup help
bash "$d/fill.sh" -h >"$d/out" 2>&1
rc=$?
[ $rc -eq 0 ] && grep -q '01-demo *AAA BBB' "$d/out" && grep -q '02-other *CCC' "$d/out"
check "-h lists each template's variables" $? "rc=$rc out=$(cat "$d/out")"

leftover=$(find "$work" -name '*.tmp.*' | head -1)
[ -z "$leftover" ]
check "no temporary files are left behind" $? "found $leftover"

echo "passed=$pass failed=$fail skipped=$skip"
[ "$fail" -eq 0 ]
