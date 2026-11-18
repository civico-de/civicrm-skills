---
name: civicrm-ci-results
description: Read CiviCRM CI results for a pull request (GitHub, civicrm/civicrm-core and siblings) or merge request (lab.civicrm.org) from the command line - commit status, the test.civicrm.org batch page, failed jobs and failed tests, the Jenkins console, GitLab pipelines, whitelisting and reruns. Use when asked "which tests failed", "why is CI red", "read the Jenkins result", "is master red too", "is the base branch red", "welche Tests sind rot", "CI Ergebnis lesen", before rerunning tests or reviewing a PR.
---

# Reading CiviCRM CI results

Core and the sibling repositories on GitHub are tested by Jenkins at
test.civicrm.org. Extensions on lab.civicrm.org mostly run their own GitLab
pipelines. Work from the head commit of the request, always the full SHA.

## GitHub pull request

```bash
gh pr checks <n> -R civicrm/<repo>          # exit code 1 when a check failed
sha=$(gh pr view <n> -R civicrm/<repo> --json headRefOid -q .headRefOid)
gh api repos/civicrm/<repo>/commits/$sha/status \
  --jq '.statuses[] | {context, state, description, target_url}'
```

- Jenkins reports one commit status, context `CiviCRM-PR`, with a summary
  only: `description` reads like `4 of 18 failed` or `18 successes`.
  `target_url` is the batch page
  `https://test.civicrm.org/duderino/batch/CiviCRM-PR/<batch id>`.
- Check runs (`.../commits/$sha/check-runs`) hold only GitHub Actions
  housekeeping such as `Remind Contributor`; no test results. The bot
  comment on the PR holds commands and the demo-site link, no results.
- No `CiviCRM-PR` status at all means the tests have not started. For a new
  contributor that is normal until an administrator comments
  `jenkins, ok to test` or `jenkins, add to whitelist`.

## Every failure of a pull request at once

```bash
scripts/jenkins.sh pr <n> [civicrm/<repo>] > failures.md   # repo defaults to civicrm-core
```

Plain text, one section per failed job: suite and build type, counts, the
Jenkins build, then each failed test with its `errorStackTrace` (all lines
after the test name), or the files a style failure names. It is meant to be
pasted into a prompt or an issue as it is. Without the token it still prints
the jobs, counts and style files; when a test job failed it says there that
the names need the token and exits 3. Exit 1: no test.civicrm.org status yet.
Exit 4: a page or report could not be read; the section names it and the
other jobs are still printed.

## The batch page (no account needed for core PRs)

The batch page is public HTML. It lists failed, pending and successful
jobs, one row per suite and build type (e.g. `standalone-clean php85m57
phpunit-api3-1`) with counts such as `3 failed, 1335 passed, 3 skipped`,
and links to the Jenkins build `https://test.civicrm.org/job/CiviCRM-Test/<build>`,
its `consoleFull` and `testReport`.

```bash
curl -sS https://test.civicrm.org/duderino/batch/CiviCRM-PR/<batch id> -o batch.html
```

Each task page `.../batch/CiviCRM-PR/<batch id>/<task id>` is public too and
carries a JSON block with `jenkinsJob`, `jenkinsBuildId`, `outcome`,
`failCount`, `passCount`, `skipCount`, `node` and `image`.
`.../batch/CiviCRM-PR/<batch id>/tasks?filter=failed` returns only the failed
rows. For a style failure, `.../duderino/build/CiviCRM-Style/<build>/bad-style`
names the offending files; the messages are in the console.

The names of the failed tests are not on these pages. Jenkins itself
answers 403 to anonymous reads; without a token the batch and task pages
are the limit, so report the failed suites with their counts and say that
the test names need a test.civicrm.org account.

## Jenkins with an API token

`scripts/jenkins.sh` in this skill's directory reads Jenkins with the
caller's API token: `CIVICRM_JENKINS_USER` plus `CIVICRM_JENKINS_TOKEN` or
`CIVICRM_JENKINS_TOKEN_COMMAND`, a command that prints the token (README,
"CI details"). It exits 3 and names what is missing or failed when the token
is not set up: then say so and stop at the public pages. It needs `bash`,
`curl` and `jq`, and `gh` for `pr`.

```bash
scripts/jenkins.sh check                          # authenticated: true
scripts/jenkins.sh failed CiviCRM-Test <build>    # counts, failed tests, trace
scripts/jenkins.sh console CiviCRM-Test <build> | tail -100
```

- Job and build number come from the task page (`jenkinsJob`,
  `jenkinsBuildId`).
- `failed` prints the same plain text as one section of `pr`: a counts line,
  then each failed test with its data set and its `errorStackTrace`, the
  failure message with any expected/actual diff, then file and line.
- `console` is the plain build log, about 150 KB for a PHPUnit task.

## lab.civicrm.org merge request (GitLab pipelines)

```bash
p='<group>%2F<repo>'
glab api --hostname lab.civicrm.org "projects/$p/merge_requests/<iid>/pipelines"   # newest first: id, status, sha
glab api --hostname lab.civicrm.org "projects/$p/repository/commits/<full sha>/statuses"
glab api --hostname lab.civicrm.org "projects/$p/pipelines/<id>/jobs?scope[]=failed"
glab api --hostname lab.civicrm.org "projects/$p/jobs/<job id>/trace" | tail -40
glab api --hostname lab.civicrm.org "projects/$p/pipelines/<id>/test_report"
```

- `statuses` with a shortened SHA returns `[]`, which looks like "no CI".
- Pipeline statuses carry `name`, `status`, `pipeline_id` and
  `allow_failure`, no `target_url`. A failed job with `allow_failure: true`
  does not fail the pipeline.
- `test_report` lists `test_suites[].test_cases[]` with `classname`, `name`,
  `status` and `stack_trace` for jobs that publish JUnit output; lint jobs
  (`civilint`, `phpcompatibility`) only have the trace.
- Anonymous API access is uneven: the jobs list answers without login,
  commit statuses and job traces answer 401. Use `glab` logged in to
  lab.civicrm.org.
- A project tested by test.civicrm.org instead reports one external status
  whose `description` is a summary and whose `target_url` is a duderino
  batch page. For a non-public project that page answers 404 without login.

## Reading the console

- Code style runs first; when it fails, the other suites are skipped, so
  "few jobs ran" can mean a lint failure (`civicrm-pull-request`,
  `references/code-changes.md`).
- A long console (hundreds of KB): most tests ran. Search for `EXITCODE`;
  it is normally blank or 0, and the first non-empty one is near the
  problem.
- A short console (a page or two): usually a network service was
  unavailable (rerun), the branch is too old to apply (rebase), or the
  test node ran out of disk, RAM or inodes (rerun; recent failures go to
  the `infrastructure` chat channel). Source: `tools/jenkins.md`.

## A job with no result

A job listed as `no result`, with no test report, is a suite that died
mid-run: PHPUnit left an empty JUnit file, so the console ends in
`phpunit-xml-cleanup … Document is empty`. Find the suite with a non-empty
`Found EXITCODES` and read the last lines it printed. The cause is usually
in the server logs, public without a token:

```bash
curl -sSf -o server-logs.tar.gz \
  https://storage.googleapis.com/civicrm-build/job-log/CiviCRM-Test/<build>/server-logs.tar.gz
```

They hold the CiviCRM log (`…/private/log/CiviCRM.*.log`) and the MySQL,
php-fpm and Apache logs of the test node. `nativecode=2006 ** MySQL server
has gone away` in the CiviCRM log with a shutdown in the MySQL log before
the job's own teardown means the database was stopped under the test: the
environment, not the change.

## Is the target branch red too

The PR job tests pull request heads only. The base branch is covered by
`CiviCRM-Core-Matrix` (more upgrade tests, several PHP and database
versions, every 4-24 hours, no code style) and `CiviCRM-WebTest-Matrix`
(`testing/continuous-integration.md`, "Full Matrix Testing";
`tools/jenkins.md`). Both live in Jenkins and need the token. A matrix
build's test report may be aggregated over its configurations;
`scripts/jenkins.sh failed` reads only a report with `suites` and exits
non-zero naming the problem otherwise; its use on matrix builds is
untested. Without the token, compare other recent pull requests on the
same base: the same suites failing there points at the base, not this
change.

## Before rerunning

A red check is explained, not only seen: name the failing test and why it
fails, or why it is unrelated. A watcher's or `gh pr checks`' exit code is
not the result; read the per-job conclusions before reporting green.

A rerun is a public comment: draft it and post only after the user's go
(`civicrm-pull-request`, one go per item). The commands are `test this
please` on GitHub once whitelisted (`tools/jenkins.md`), and `/test` for
extensions tested by civibot (`testing/continuous-integration.md`).
The batch page also carries a retry action per task
(`…/batch/CiviCRM-PR/<batch id>/<task id>/retry`) that posts nothing on
GitHub; whether its result reaches the PR status is unchecked, so prefer
the comment. Starting `CiviCRM-Test` directly through the Jenkins
API bypasses the batch and leaves the PR status as it was.

## Completion

State the head SHA, the status summary, each failed job with its counts, the
failed test names if they were readable, and what could not be read and why.
