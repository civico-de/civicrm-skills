---
name: civicrm-review
description: Review someone else's CiviCRM core pull request - pick and claim it, read the issue and the diff, reproduce on the base branch, validate the fix locally (red without, green with), check it against the review standards (r-explain … r-test) and gotchas (packaging, permissions, security, settings, upgrades, hooks), and draft the review comment for the user's go. Use for "review PR 12345", "is this PR mergeable", "PR reviewen", "Review schreiben". Only for someone else's change; receiving review on your own PR is civicrm-pull-request.
---

# Review a CiviCRM pull request

Sources: Developer Guide [`core/pr-review`](https://docs.civicrm.org/dev/en/latest/core/pr-review/)
and [`standards/review`](https://docs.civicrm.org/dev/en/latest/standards/review/)
with its templates under `docs/standards/review/template-*.md`. A review
needs no special rights; merging is done by maintainers. Uncited rules are
this repository's own practice (README, "Contributing"). Running a stack:
`civikitchen`.

## Pick and claim

- Pick a pull request with green tests, no merge conflicts, no `WIP` in
  the title and no unresolved disagreement or unanswered question.
- Claiming it ("Reviewing this now") is a comment: outward text, so only
  after the user's go.

## Read

1. The linked issue: how to reproduce, what the solution should be.
2. The base branch (`gh pr view <n> -R civicrm/civicrm-core --json
   baseRefName,headRefOid,files`), and the diff.
3. Label honesty: `(NFC)` excludes refactorings, altered tests and changed
   docblock annotations; `(REF)` must preserve behaviour
   (`tools/git.md`). A removed function needs its deprecation period
   (`civicrm-pull-request`, `references/code-changes.md`).

## Reproduce and validate

Reproduce the problem on the base branch first and judge whether it is a
problem worth solving in core. Then validate the fix, proportionately
(`r-run`):

- **Demo site and CI.** The bot links an "Online demo of this PR"; it
  expires after hours or days. A red or missing check is explained, not
  only seen (`civicrm-ci-results`). Labels `run-drupal-x`,
  `run-wordpress`, `run-extended-tests` and others request more tests, for
  those allowed to add labels, after the user's go; integration or
  bootstrap changes merit them.
- **Locally with civikitchen.** Image matching the base (`standalone-master`
  or `standalone-beta`; a pull request against an older `X.Y` branch: that
  branch built from git, `CIVICRM_VERSION=<X.Y>`), the PR's changed
  directories mounted (`civicrm-verify-bug`). The PR's test runs red with only
  the test mounted and green with the fix mounted too (`ck run <image>
  --mount <src>:<dst> -- ckcoretest <path>`); a test that passes without the fix proves
  nothing (`civicrm-tests`). Visible changes: `ck demo <PR> --page
  <route>`. A claimed regression between versions: `ck ab`.
- **Limit of a mount.** Mounts and `ck demo` apply files only, with no
  `composer install` and no schema upgrade: a change to the schema or to
  composer dependencies does not reach the installed database or
  `vendor/` (civikitchen `docs/core-development.md`, "Recording a change
  before and after: `ck demo`"). It needs an image built from the change
  (`scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=<ref>`).
  The Dockerfile fetches that ref from the civicrm/civicrm-core
  repository itself, so a commit only on the contributor's fork cannot be
  built without changing it, and the image is tagged with the ref, so a
  ref containing `/` is no valid tag. Whether a `refs/pull/<n>/head` ref
  builds is untested. Otherwise write "schema change not verified
  locally".
- **Database upgrades.** The guide installs the latest release, applies
  the PR, runs `bin/setup.sh -Dg` and the upgrade. civikitchen cannot do
  this; write "upgrade path not verified locally" and read the
  `civicrm-upgrade-test` result in CI. Check that a new upgrade step sits
  in the version of `xml/version.xml` on the base branch
  (`civicrm-pull-request`, `references/code-changes.md`, "Schema and
  upgrade steps").
- Runs stay targeted: the changed files' tests plus one or two neighbours,
  red and green. Name a broader suite with its runtime instead of starting
  it. Anything that could not run is listed as not verified, never left
  out.

## Judge

Give each standard of `standards/review.md` (`r-explain` … `r-test`) a
Pass or Issue and check the gotchas that apply (`rg-pkg`, `rg-perm`,
`rg-sec`, `rg-setting`, `rg-upgrades`, `rg-hook`); the questions per code
and what else to look for are in `references/standards.md`.

## Findings

Ordered by severity, each with `file:line` and a concrete failure
scenario. Proven bugs apart from questions and version-dependent doubts.
No style-only nits; lint is CI's job. When nothing material remains, say
so plainly.

## The comment

- Use `template-word-1.0.md` (short) or `template-del-1.0.md` /
  `template-mc-1.0.md` (with examples); the files are named 1.0 and
  head themselves "Review Template … 1.2". Or summarise what was done,
  found and recommended. Tag an active contributor so the PR moves on.
- Say what was reproduced and tested, on which base and commit, and what
  was not verified.
- Declare the agent's name, use and role (`AGENTS.md`: "clearly declared
  in commits, PRs, etc."), e.g. one blockquoted line on what the agent ran
  and drafted; the judgement posted is the user's.
- civicrm-core has GitHub labels such as `merge ready`, `merge on pass`,
  `has-test`, `needs-test` and `needs-work-not-review-ready`; the
  Developer Guide does not document their use. Recommend one in the
  comment, do not set it.
- Draft it, show it, post only after the user's explicit go.

A second, independent look at your own review is another local review
pass with an explicit base (commit range), not a public request; asking
anyone in public needs the user's go.

## Completion

Name the PR, base branch and head SHA; what was reproduced on the base and
with the fix (commands, red and green); CI status read; each standard's
verdict; findings by severity; what was not verified and why; the drafted
comment, and whether it was posted.
