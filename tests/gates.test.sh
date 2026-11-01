#!/usr/bin/env bash
# Regression tests for the review-state checks in the exec templates:
# the 04-merge gate (step 1) and the 02-review duplicate check (section 0, step 3).
#
# Each test runs the template's bash block itself, so it runs exactly what an agent
# would run. A stub `gh` on PATH serves synthetic JSON shaped like the paginated
# `gh api` output; nothing is read from or written to GitHub. Every run starts in a
# working directory that already holds user files named like the API responses, and
# fails if the block changes them, adds files there, or leaves anything in TMPDIR.
# Requires bash and jq. Usage: bash tests/gates.test.sh
set -u

root=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
pass=0 fail=0

# extract <file> <heading>: the first bash block after the heading, de-indented
extract() {
  awk -v h="$2" '
    index($0, h) == 1 { section = 1; next }
    section && !fence && match($0, /^ *```bash$/) { fence = 1; indent = RLENGTH - 7; next }
    fence && $0 ~ /^ *```$/ { exit }
    fence { print (substr($0, 1, indent) ~ /^ *$/) ? substr($0, indent + 1) : $0 }
  ' "$1"
}
merge_cmd=$(extract "$root/prompts/exec/04-merge.md" "## 1. Check before merging")
review_cmd=$(extract "$root/prompts/exec/02-review.md" "## 0. Pre-flight")
[ -n "$merge_cmd" ] && [ -n "$review_cmd" ] || { echo "FAIL could not extract the check blocks"; exit 1; }

# Stub for `gh api --paginate <endpoint>`: prints the current case's fixture for that
# endpoint. If GH_FAIL names the fixture, it prints the first page and then fails, as
# when a later page cannot be fetched.
mkdir -p "$work/bin"
cat >"$work/bin/gh" <<'EOF'
#!/usr/bin/env bash
[ "$#" -eq 3 ] && [ "$1" = api ] && [ "$2" = --paginate ] || { echo "stub gh: unexpected call: $*" >&2; exit 2; }
case $3 in
  repos/o/r/pulls/1/reviews) f=reviews.json ;;
  repos/o/r/pulls/1/comments) f=review_comments.json ;;
  repos/o/r/issues/1/comments) f=issue_comments.json ;;
  *) echo "stub gh: unexpected endpoint: $3" >&2; exit 2 ;;
esac
if [ "${GH_FAIL:-}" = "$f" ]; then head -n 1 "$GH_FIXTURES/$f"; echo "stub gh: HTTP 502" >&2; exit 1; fi
cat "$GH_FIXTURES/$f"
EOF
chmod +x "$work/bin/gh"

HEAD_SHA=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
OLD_SHA=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
BOT=codex-bot
T0=2026-01-01T10:00:00Z T1=2026-01-01T11:00:00Z T2=2026-01-01T12:00:00Z
# The blocks with their placeholders filled in; fill_merge takes the reviewer login
fill_merge() { sed "s/{{AUTOMATED_REVIEWER}}/$1/; s/<head-sha>/$HEAD_SHA/; s/<owner>/o/g; s/<repo>/r/g; s/<number>/1/g" <<<"$merge_cmd"; }
fill_review() { sed "s/<your-login>/$BOT/; s/<head-sha>/$HEAD_SHA/; s/<owner>/o/g; s/<repo>/r/g; s/<number>/1/g" <<<"$review_cmd"; }
clean() { # clean [sha] [verdict-line-ending]: a marker review body
  printf '<!-- automated-pr-review sha=%s -->\n### PR Review\n\n**Verdict:** %s\n**Findings:** 0' \
    "${1:-$HEAD_SHA}" "${2:-No blocking issues}"
}

# Synthetic GitHub objects, one JSON object each
rev() { # rev <id> <login> <time> <body> [state]
  jq -cn --argjson id "$1" --arg login "$2" --arg at "$3" --arg body "$4" --arg state "${5:-COMMENTED}" \
    '{id: $id, user: {login: $login}, state: $state, submitted_at: $at, body: $body, html_url: "https://example.test/r/\($id)"}'
}
rc() { # rc <id> <login> <time> <review-id>: an inline comment or thread reply
  jq -cn --argjson id "$1" --arg login "$2" --arg at "$3" --argjson rid "$4" \
    '{id: $id, user: {login: $login}, created_at: $at, pull_request_review_id: $rid, html_url: "https://example.test/rc/\($id)"}'
}
ic() { # ic <id> <login> <time>: a PR conversation comment
  jq -cn --argjson id "$1" --arg login "$2" --arg at "$3" \
    '{id: $id, user: {login: $login}, created_at: $at, body: "x", html_url: "https://example.test/ic/\($id)"}'
}

new_case() { c="$work/$1" && mkdir -p "$c" && : >"$c/reviews.json" && : >"$c/review_comments.json" && : >"$c/issue_comments.json"; }
page() { # page <file> [objects...]: append one page, as `gh api --paginate` prints one array per page
  local f=$1
  shift
  if [ $# -eq 0 ]; then echo '[]' >>"$c/$f"; else printf '%s\n' "$@" | jq -cs . >>"$c/$f"; fi
}
check() { # check <name> <status> <detail>
  if [ "$2" -eq 0 ]; then
    pass=$((pass + 1)) && echo "PASS $1"
  else
    fail=$((fail + 1)) && echo "FAIL $1: $3"
  fi
}

# run <block> [tmpdir]: runs a filled-in block with the stub gh, in a working directory
# that holds user files named like the API responses. Sets out (stdout and stderr) and
# damage (what the block changed there or left in TMPDIR; empty if nothing).
tree=$work/tree tmp=$work/tmp
names="reviews.json review_comments.json issue_comments.json"
run() {
  local f
  rm -rf "$tree" "$tmp" && mkdir -p "$tree" "$tmp"
  for f in $names; do printf 'user data in %s\n' "$f" >"$tree/$f"; done
  out=$(cd "$tree" && PATH="$work/bin:$PATH" TMPDIR="${2:-$tmp}" GH_FIXTURES="$c" GH_FAIL="${GH_FAIL:-}" bash <<<"$1" 2>&1)
  damage=""
  for f in $names; do
    [ "$(cat "$tree/$f" 2>/dev/null)" = "user data in $f" ] || damage+="changed $f; "
  done
  [ "$(ls -A "$tree" | wc -l)" -eq 3 ] || damage+="added files to the working directory; "
  [ -z "$(ls -A "$tmp")" ] || damage+="left $(ls -A "$tmp" | tr '\n' ' ')in TMPDIR; "
}

# expect_merge <name> <reviewer-login> <expected failures, |-separated substrings; empty for none>
expect_merge() {
  local name=$1 bot=$2 want=$3 got ok=0 n_want p
  run "$(fill_merge "$bot")"
  if ! got=$(jq -r '.failures[]' <<<"$out" 2>/dev/null); then
    check "04-merge: $name" 1 "no gate result: $out"
    return
  fi
  if [ -z "$want" ]; then
    [ -z "$got" ] || ok=1
  else
    n_want=$(($(tr '|' '\n' <<<"$want" | wc -l)))
    [ "$n_want" -eq "$(($(grep -c . <<<"$got")))" ] || ok=1
    IFS='|' read -ra parts <<<"$want"
    for p in "${parts[@]}"; do grep -qF -- "$p" <<<"$got" || ok=1; done
  fi
  [ -z "$damage" ] || ok=1
  check "04-merge: $name" $ok "failures=[$(tr '\n' ';' <<<"$got")] $damage"
}

# expect_review <name> <expected decision: review | stop | re-review>
expect_review() {
  local got ok=0
  run "$(fill_review)"
  got=$(jq -r .decision <<<"$out" 2>/dev/null) || got="(no result: $out)"
  [ "$got" = "$2" ] && [ -z "$damage" ] || ok=1
  check "02-review: $1" $ok "decision=$got $damage"
}

# expect_not_run <template: merge | review> <name> [tmpdir]: a failed setup or fetch must
# print NOT RUN and no result, and still leave the user's files alone
expect_not_run() {
  local ok=0 label=02-review cmd
  if [ "$1" = merge ]; then label=04-merge cmd=$(fill_merge $BOT); else cmd=$(fill_review); fi
  run "$cmd" "${3:-}"
  grep -q 'NOT RUN' <<<"$out" && ! grep -qE '"(failures|decision)"' <<<"$out" && [ -z "$damage" ] || ok=1
  check "$label: $2" $ok "$damage output: $(tr '\n' ' ' <<<"$out")"
}

new_case clean
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")"
page review_comments.json "$(rc 10 $BOT $T1 1)"
page issue_comments.json "$(ic 20 alice $T0)"
expect_merge "clean review with its own inline comment and nothing after" $BOT ""
expect_review "clean review with nothing after" stop

new_case later-review
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 2 alice $T2 "High: x breaks")"
expect_merge "a later body-only review blocks" $BOT "post(s)"
expect_review "a later body-only review" re-review

new_case later-comment
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")"
page issue_comments.json "$(ic 21 alice $T2)"
expect_merge "a later PR comment blocks" $BOT "post(s)"
expect_review "a later PR comment" re-review

new_case later-reply
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 3 alice $T2 "")"
page review_comments.json "$(rc 11 alice $T2 3)"
expect_merge "a later thread reply blocks" $BOT "post(s)"
expect_review "a later thread reply" re-review

new_case empty-approval
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 4 alice $T2 "" APPROVED)"
expect_merge "a later empty-body approval does not block" $BOT ""
expect_review "a later empty-body approval" stop

new_case pending
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 5 alice $T2 "draft" PENDING)"
expect_merge "a pending review is ignored" $BOT ""
expect_review "a pending review" stop

new_case forged
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 6 mallory $T2 "$(clean)")"
expect_merge "a marker review from another login counts as activity" $BOT "post(s)"
expect_review "a marker review from another login" re-review

new_case old-sha
page reviews.json "$(rev 1 $BOT $T1 "$(clean $OLD_SHA)")"
expect_merge "a latest review for an older commit blocks" $BOT "not the head"
expect_review "a review only of an older commit" review

new_case changes-recommended
page reviews.json "$(rev 1 $BOT $T1 "$(clean $HEAD_SHA "Changes recommended before merge")")"
expect_merge "Changes recommended before merge blocks" $BOT "verdict is Changes recommended before merge"

new_case none
page reviews.json "$(rev 7 alice $T1 "looks fine")"
expect_merge "no automated review blocks" $BOT "no automated review"
expect_review "no automated review" review

new_case login-forms
page reviews.json "$(rev 1 "Codex-Bot[bot]" $T1 "$(clean)")"
expect_merge "a [bot] suffix and letter case are ignored" "CODEX-BOT" ""
expect_merge "a leading @ on the configured login is ignored" "@codex-bot" ""

new_case pages
page reviews.json "$(rev 1 $BOT $T0 "$(clean $OLD_SHA)")"
page reviews.json "$(rev 8 $BOT $T1 "$(clean)")"
page review_comments.json
page review_comments.json
page issue_comments.json "$(ic 22 alice $T0)"
page issue_comments.json
expect_merge "the latest review is found across pages" $BOT ""
expect_review "the head review is found across pages" stop

new_case crlf
page reviews.json "$(rev 1 $BOT $T1 "$(clean | sed 's/No blocking issues$/No blocking issues  \r/')")"
expect_merge "trailing spaces and CR after the verdict are ignored" $BOT ""

new_case no-verdict
page reviews.json "$(rev 1 $BOT $T1 "$(printf '<!-- automated-pr-review sha=%s -->\nno verdict line' $HEAD_SHA)")"
expect_merge "a missing verdict blocks" $BOT "verdict is missing"

new_case short-sha
page reviews.json "$(rev 1 $BOT $T1 "$(clean | sed "s/sha=$HEAD_SHA/sha=${HEAD_SHA:0:12}/")")"
expect_merge "an abbreviated marker SHA is not a marker" $BOT "no automated review"
expect_review "an abbreviated marker SHA" review

# GitHub timestamps have one-second precision, so a post in the same second as the
# review may have come after it. Both templates must treat it as later activity.
new_case same-second-comment
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")"
page issue_comments.json "$(ic 23 alice $T1)"
expect_merge "a PR comment in the same second as the review blocks" $BOT "post(s)"
expect_review "a PR comment in the same second as the review" re-review

new_case same-second-review
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 9 alice $T1 "High: y breaks")"
expect_merge "a body-only review in the same second blocks" $BOT "post(s)"
expect_review "a body-only review in the same second" re-review

new_case same-second-reply
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")" "$(rev 12 alice $T1 "")"
page review_comments.json "$(rc 13 alice $T1 12)"
expect_merge "a thread reply in the same second blocks" $BOT "post(s)"
expect_review "a thread reply in the same second" re-review

# A failed setup or fetch must stop the check instead of yielding a result. Each
# fixture below would otherwise pass the gate, so a result means the check failed open.
for f in $names; do
  new_case "fetch-fails-$f"
  page reviews.json "$(rev 1 $BOT $T1 "$(clean)")"
  GH_FAIL=$f expect_not_run merge "a failed fetch of $f stops the gate"
  GH_FAIL=$f expect_not_run review "a failed fetch of $f stops the duplicate check"
done
new_case setup-fails
page reviews.json "$(rev 1 $BOT $T1 "$(clean)")"
expect_not_run merge "a scratch directory that cannot be created stops the gate" "$work/missing"
expect_not_run review "a scratch directory that cannot be created stops the duplicate check" "$work/missing"

echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
