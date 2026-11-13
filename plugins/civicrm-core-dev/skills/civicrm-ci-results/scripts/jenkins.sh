#!/usr/bin/env bash
# Read test results from Jenkins on test.civicrm.org with an API token.
# Needs CIVICRM_JENKINS_USER and CIVICRM_JENKINS_TOKEN in the environment.
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  jenkins.sh check                  is the token accepted
  jenkins.sh failed <job> <build>   counts and failed tests with their message
  jenkins.sh console <job> <build>  plain build log
USAGE
  exit 2
}

missing=()
[ -n "${CIVICRM_JENKINS_USER:-}" ] || missing+=(CIVICRM_JENKINS_USER)
[ -n "${CIVICRM_JENKINS_TOKEN:-}" ] || missing+=(CIVICRM_JENKINS_TOKEN)
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Not set: ${missing[*]}. See 'CI details' in the repository README." >&2
  exit 3
fi

# Values that would break the quoted curl config line are rejected, not escaped.
nl=$'\n'
for var in CIVICRM_JENKINS_USER CIVICRM_JENKINS_TOKEN; do
  case "${!var}" in
    *'"'* | *"\\"* | *"$nl"*)
      echo "$var contains a double quote, backslash or newline; not supported." >&2
      exit 3
      ;;
  esac
done

job_build() {
  [[ $1 =~ ^[A-Za-z0-9._-]+$ && $1 != . && $1 != .. ]] || { echo "Invalid job name: '$1' (allowed: A-Z a-z 0-9 . _ -, not . or ..)." >&2; exit 2; }
  [[ $2 =~ ^[0-9]+$ ]] || { echo "Invalid build number: '$2' (digits only)." >&2; exit 2; }
}

# The credentials reach curl on stdin, so they never appear in a process list.
jk() {
  printf 'user = "%s:%s"\n' "$CIVICRM_JENKINS_USER" "$CIVICRM_JENKINS_TOKEN" \
    | curl -sS --fail -K - -g "https://test.civicrm.org/$1"
}

case "${1:-}" in
  check)
    [ $# -eq 1 ] || usage
    jk whoAmI/api/json | jq '{name, authenticated}'
    ;;
  failed)
    [ $# -eq 3 ] || usage
    job_build "$2" "$3"
    jk "job/$2/$3/testReport/api/json?tree=failCount,passCount,skipCount,suites[cases[className,name,status,errorStackTrace]]" \
      | jq -e 'if has("suites") | not then
          error("no suites in this test report (an aggregated report, e.g. a matrix job, lists childReports instead)")
        else . end
        | {failCount, passCount, skipCount, failed: [.suites[].cases[]
          | select(.status == "FAILED" or .status == "REGRESSION")
          | {className, name, message: ((.errorStackTrace // "") | split("\n")[0:4])}]}'
    ;;
  console)
    [ $# -eq 3 ] || usage
    job_build "$2" "$3"
    jk "job/$2/$3/consoleText"
    ;;
  *)
    usage
    ;;
esac
