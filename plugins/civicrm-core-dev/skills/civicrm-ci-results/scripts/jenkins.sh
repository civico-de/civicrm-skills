#!/usr/bin/env bash
# Read test results from test.civicrm.org: public batch pages, and Jenkins with
# CIVICRM_JENKINS_USER and CIVICRM_JENKINS_TOKEN or CIVICRM_JENKINS_TOKEN_COMMAND.
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  jenkins.sh check                  is the token accepted
  jenkins.sh failed <job> <build>   counts and failed tests with their trace
  jenkins.sh console <job> <build>  plain build log
  jenkins.sh pr <n> [<repo>]        every failure of a pull request as plain text
                                    (repo defaults to civicrm/civicrm-core)
Exit codes: 1 no test.civicrm.org status, 2 usage, 3 token not set,
  4 a job or the batch could not be read completely.
USAGE
  exit 2
}

BASE=https://test.civicrm.org

# CIVICRM_JENKINS_TOKEN_COMMAND prints the token, e.g. from a password manager.
resolve_token() {
  [ -z "${CIVICRM_JENKINS_TOKEN:-}" ] && [ -n "${CIVICRM_JENKINS_TOKEN_COMMAND:-}" ] || return 0
  CIVICRM_JENKINS_TOKEN=$(sh -c "$CIVICRM_JENKINS_TOKEN_COMMAND") \
    || { echo "CIVICRM_JENKINS_TOKEN_COMMAND failed." >&2; exit 3; }
  [ -n "$CIVICRM_JENKINS_TOKEN" ] || { echo "CIVICRM_JENKINS_TOKEN_COMMAND printed nothing." >&2; exit 3; }
}

has_token() {
  resolve_token
  [ -n "${CIVICRM_JENKINS_USER:-}" ] && [ -n "${CIVICRM_JENKINS_TOKEN:-}" ]
}

require_token() {
  local missing=() var nl=$'\n'
  resolve_token
  [ -n "${CIVICRM_JENKINS_USER:-}" ] || missing+=(CIVICRM_JENKINS_USER)
  [ -n "${CIVICRM_JENKINS_TOKEN:-}" ] || missing+=("CIVICRM_JENKINS_TOKEN (or CIVICRM_JENKINS_TOKEN_COMMAND)")
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "Not set: ${missing[*]}. See 'CI details' in the repository README." >&2
    exit 3
  fi
  # Values that would break the quoted curl config line are rejected, not escaped.
  for var in CIVICRM_JENKINS_USER CIVICRM_JENKINS_TOKEN; do
    case "${!var}" in
      *'"'* | *"\\"* | *"$nl"*)
        echo "$var contains a double quote, backslash or newline; not supported." >&2
        exit 3
        ;;
    esac
  done
}

job_build() {
  [[ $1 =~ ^[A-Za-z0-9._-]+$ && $1 != . && $1 != .. ]] || { echo "Invalid job name: '$1' (allowed: A-Z a-z 0-9 . _ -, not . or ..)." >&2; exit 2; }
  [[ $2 =~ ^[0-9]+$ ]] || { echo "Invalid build number: '$2' (digits only)." >&2; exit 2; }
}

# The credentials reach curl on stdin, so they never appear in a process list.
jk() {
  printf 'user = "%s:%s"\n' "$CIVICRM_JENKINS_USER" "$CIVICRM_JENKINS_TOKEN" \
    | curl -sS --fail -K - -g "$BASE/$1"
}

report() {
  jk "job/$1/$2/testReport/api/json?tree=failCount,passCount,skipCount,suites[cases[className,name,status,errorStackTrace]]"
}

# Jenkins test report JSON on stdin: each failed test with its trace.
# Fails on an aggregated (matrix) report.
failed_text() {
  jq -r 'if has("suites") | not then
      error("no suites in this test report (an aggregated report, e.g. a matrix job, lists childReports instead)")
    else . end
    | .suites[].cases[] | select(.status == "FAILED" or .status == "REGRESSION")
    | "\(.className)::\(.name)" as $t
    | "- \($t)", ((.errorStackTrace // "") | split("\n")[] | select(. != $t) | "    \(.)")'
}

text() { sed -e 's/<[^>]*>//g' -e 's/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&#39;/'"'"'/g; s/&amp;/\&/g'; }

# One failed task row of a duderino batch, printed as a section.
# A part that cannot be read is named in the output and sets $incomplete.
print_task() {
  local row=$1 link job build cells results style files trace
  link=$(grep -oE "href=\"$BASE/job/[A-Za-z0-9._-]+/[0-9]+\"" <<<"$row" | head -1 | tr -d '"')
  job=$(cut -d/ -f5 <<<"$link")
  build=$(cut -d/ -f6 <<<"$link")
  cells=$(grep -oE '<code>[^<]*</code>' <<<"$row" | text | head -3 | paste -sd' ' -)
  results=$(sed -n 's|.*<td><div>\(.*\)</div></td><td><div role="group".*|\1|p' <<<"$row" | text)
  echo "## $cells — ${results:-no result}"
  echo "$job #$build  $BASE/job/$job/$build"
  if [ "$job" = CiviCRM-Style ]; then
    if ! style=$(curl -sS --fail "$BASE/duderino/build/CiviCRM-Style/$build/bad-style"); then
      files="  The style page could not be read."
      incomplete=1
    elif [[ $style == *'id="bad-style-details-body"'* ]]; then
      style=${style#*id=\"bad-style-details-body\"}
      files=$(grep -oE '<code>[^<]*</code>' <<<"${style%%</ul>*}" | text | sed 's/^/- /' || true)
    else
      incomplete=1
    fi
    echo "${files:-  The style page lists no files.}"
    echo "  Messages: jenkins.sh console CiviCRM-Style $build"
  elif [[ $results =~ [1-9][0-9]*\ failed ]]; then
    if ! has_token; then
      echo "  Test names need the Jenkins token (README, 'CI details')."
      untokened=1
    elif trace=$(report "$job" "$build" | failed_text); then
      echo "$trace"
    else
      echo "  The test report could not be read: jenkins.sh failed $job $build"
      incomplete=1
    fi
  else
    echo "  No test report: jenkins.sh console $job $build | tail -100"
    echo "  Server logs: https://storage.googleapis.com/civicrm-build/job-log/$job/$build/server-logs.tar.gz"
  fi
  echo
}

pr() {
  local n=$1 repo=${2:-civicrm/civicrm-core} sha statuses context state description url page rows row expected
  [[ $n =~ ^[0-9]+$ ]] || { echo "Invalid pull request number: '$n'." >&2; exit 2; }
  [[ $repo =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] || { echo "Invalid repository: '$repo' (owner/name)." >&2; exit 2; }
  sha=$(gh pr view "$n" -R "$repo" --json headRefOid -q .headRefOid)
  statuses=$(gh api "repos/$repo/commits/$sha/status" \
    --jq ".statuses[] | select(.target_url // \"\" | test(\"^$BASE/duderino/batch/[A-Za-z0-9._-]+/[0-9]+\$\")) | [.context, .state, .description // \"\", .target_url] | join(\"\u001f\")")
  if [ -z "$statuses" ]; then
    echo "$repo#$n $sha: no test.civicrm.org status, tests have not started." >&2
    exit 1
  fi
  untokened=0 incomplete=0
  while IFS=$'\x1f' read -r context state description url; do
    echo "# $repo#$n $sha"
    echo "$context: $state, $description"
    echo "$url"
    echo
    page=$(curl -sS --fail "$url/tasks?filter=failed" | tr -d '\n')
    rows=$(awk '{gsub(/<tr>/, "\n<tr>")} 1' <<<"$page" | grep '^<tr><td><a href' || true)
    expected=$(sed -n 's/.*id="title-failed">Failed Jobs (\([0-9]*\)).*/\1/p' <<<"$page")
    if [ "${expected:-x}" != "$(grep -c . <<<"$rows" || true)" ]; then
      echo "The batch lists ${expected:-an unknown number of} failed jobs; not every one was read." >&2
      incomplete=1
    fi
    while IFS= read -r row; do
      if [ -n "$row" ]; then print_task "$row"; fi
    done <<<"$rows"
  done <<<"$statuses"
  if [ "$untokened" = 1 ]; then
    has_token || require_token
  fi
  if [ "$incomplete" = 1 ]; then
    exit 4
  fi
}

case "${1:-}" in
  check)
    [ $# -eq 1 ] || usage
    require_token
    jk whoAmI/api/json | jq '{name, authenticated}'
    ;;
  failed)
    [ $# -eq 3 ] || usage
    require_token
    job_build "$2" "$3"
    r=$(report "$2" "$3")
    t=$(failed_text <<<"$r")
    jq -r '"\(.failCount) failed, \(.passCount) passed, \(.skipCount) skipped"' <<<"$r"
    [ -z "$t" ] || echo "$t"
    ;;
  console)
    [ $# -eq 3 ] || usage
    require_token
    job_build "$2" "$3"
    jk "job/$2/$3/consoleText"
    ;;
  pr)
    [ $# -ge 2 ] && [ $# -le 3 ] || usage
    has_token && require_token
    pr "$2" "${3:-}"
    ;;
  *)
    usage
    ;;
esac
