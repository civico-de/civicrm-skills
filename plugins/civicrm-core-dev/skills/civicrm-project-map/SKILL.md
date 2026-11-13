---
name: civicrm-project-map
description: Orientation in the CiviCRM project - where code, issues and discussions live (lab.civicrm.org, GitHub, Stack Exchange, chat), reading core and extension code without web search, the search order before reporting or fixing, branches and the monthly release cycle. Use when asked "where is the ticket", "which repo", "wo meldet man das", "where do I report a bug in an extension", "which branch do I target", "welcher Branch", "when does this ship", and for the search for an existing issue or PR before reporting or fixing anything. Writing the PR or issue afterwards is civicrm-pull-request, reviewing one is civicrm-review.
---

# How CiviCRM is organised

The reference is the Developer Guide (`civicrm-dev-docs`, published at
docs.civicrm.org/dev): [`tools/issue-tracking`](https://docs.civicrm.org/dev/en/latest/tools/issue-tracking/),
[`tools/git`](https://docs.civicrm.org/dev/en/latest/tools/git/), [`core/release-process`](https://docs.civicrm.org/dev/en/latest/core/release-process/).
Read those when this page and the project disagree; this page is the map.

## Where things live

| What | Where |
|---|---|
| Code of core, CMS integrations, packages, l10n, buildkit, cv | github.com/civicrm (`civicrm-core`, `civicrm-drupal-8`, `civicrm-wordpress`, `civicrm-joomla`, `civicrm-backdrop`, `civicrm-standalone`, `civicrm-packages`, `civicrm-buildkit`, `cv`) |
| Pull requests for core | GitHub only |
| Issues for core and the CMS integrations | lab.civicrm.org, group `dev` (`dev/core`, `dev/drupal`, `dev/wordpress`, `dev/mail`, `dev/financial`, `dev/translation`, …). civicrm-core has no GitHub issues |
| Issues for tools (buildkit, cv, civix) | GitHub, in the tool's repository |
| Most extensions | lab.civicrm.org, group `extensions`; many others on GitHub. `info.xml` names the repository |
| Issues before 2018 | issues.civicrm.org (Jira, read-only), referenced as `CRM-12345` |
| Questions and answers | civicrm.stackexchange.com |
| Live discussion with maintainers | chat.civicrm.org (Mattermost) |
| Documentation | docs.civicrm.org; sources in `civicrm-dev-docs`, `civicrm-user-guide`, `civicrm-sysadmin-guide` |
| Releases, release candidate, nightly | download.civicrm.org/latest names the current version of each |
| Security advisories | civicrm.org/advisory |

## Tools

Use the forges' command line clients; no other access is needed for
reading.

```bash
gh pr list -R civicrm/civicrm-core --search "<words>" --state all
gh pr view <number> -R civicrm/civicrm-core --json title,state,statusCheckRollup
GITLAB_HOST=lab.civicrm.org glab issue list -R dev/core --search "<words>" --all
GITLAB_HOST=lab.civicrm.org glab issue view <number> -R dev/core
```

With several git remotes, always pass `-R` or pin `gh repo set-default`;
`gh` otherwise prefers a remote named `upstream` and a write can land in
the wrong repository. Before saying something is missing from a tag, image
or branch, check the remote, read-only: `git ls-remote --tags <remote>
'<pattern>'`, `git ls-remote --heads <remote> '<pattern>'`, `git show
origin/<branch>:<path>` after a plain fetch; local tags and branches drift.
A forced tag fetch overwrites local tags; run it only after the user's go. A local
civicrm-core checkout answers most questions about behaviour and history
faster than a forge: `git log -S'<symbol>'`, `git log --grep='dev/core#1234'`.

## Reading code

Never take code from a web search, a web page of a forge or memory. A
search engine returns old versions, forks and snippets without a commit; a
claim about core needs a file, a line and the commit it was read at.

**Core** is read from the local civicrm-core checkout; work on core always
has one. Fetch first, and read the branch the question is about rather
than whatever is checked out: `git grep -n '<symbol>' origin/master -- CRM
Civi ext`, `git show origin/<X.Y>:<path>`, `git log -S'<symbol>'`. Hook
signatures, firing time and what a hook may change are read from the
target version's source, not from memory.

**Extensions and everything across repositories** has no local copy by
default:

- When the `civicrm-knowledge` MCP server is connected (`civicrm_grep`,
  `civicrm_read`, `civicrm_search`, `civicrm_find_hook`,
  `civicrm_find_entity`), use it: it searches the published extensions in
  one call, which no forge client can. It answers "who uses this hook or
  API" before a core change. Its index has a date; for core itself the
  checkout stays the authority. `civicrm_search` also finds the public
  issue and pull request discussions of lab.civicrm.org and GitHub, as of
  the last crawl; for the current state of one, ask `gh` or `glab`.
  `civicrm_history` exists only for a caller with a token; without it
  read history with `git log`.
- Otherwise clone the extensions in question
  (`git clone --depth 1 <url>`) and search the clones.
- For a quick look into one project on lab.civicrm.org, default branch
  only and with a logged-in `glab`: `GITLAB_HOST=lab.civicrm.org glab api
  'projects/<group>%2F<project>/search?scope=blobs&search=<words>'`.
  Searching a whole group this way is not available. On GitHub:
  `gh search code '<words>' --repo <owner>/<repo>`.
- If none of this is possible, say so and stop; do not substitute what a
  web search returns.

## Before reporting or fixing

Search first, in this order, and write down what was searched: open and
closed issues in the matching `dev/*` project, open and merged pull requests
on GitHub, the code on current `master` (the bug may be gone), Stack
Exchange for reports from users. An issue that describes the same thing gets
a comment, not a duplicate; a closed issue that is broken again gets a new
issue that links it and says "regression". Either is posted only after the
user's go on the drafted text (`civicrm-pull-request`).

Whether a pull request or an issue follows, and how to write either:
`civicrm-pull-request`.

## Branches and releases

A minor version ships on the first Wednesday of each month. Security
releases generally use the first or third Wednesday; other point releases
appear at any time (`core/release-process.md`). Versions are not semantic: any monthly release may change schema
and API.

| Branch | Example version | Takes |
|---|---|---|
| `master` | 5.99.alpha1 | almost everything: fixes, cleanups, features. Ships up to two months later |
| release candidate, newest `X.Y` | 5.98.beta1 | fixes for critical, recent regressions traced to a specific change; a handful per cycle |
| stable, previous `X.Y` | 5.97.1 | backports of very critical fixes, done by maintainers |

The version numbers are examples; download.civicrm.org/latest names the
current ones. The base-branch rule
([`tools/git`, base branch](https://docs.civicrm.org/dev/en/latest/tools/git/#base-branch)),
which the other skills point to:

- `master` by default, older regressions included.
- The RC branch only for a critical, recent regression traced to a
  specific change.
- Not stable on your own: open the pull request against the RC instead;
  maintainers backport.
- Start with one pull request against one branch, even when the bug is on
  several. Reviewers or release managers may ask for copies against the
  RC and the latest release (`core/release-process.md`, "Branches"); make
  them then, or with `/port`.

The RC branch is cut from `master` soon after the monthly release, so a
month of testing lies between a change reaching the RC and its release.

## Where the activities are

| Activity | Skill |
|---|---|
| Pull request, commits, issue, security report (never public) | `civicrm-pull-request` |
| Reviewing someone else's pull request | `civicrm-review` |
| Reading CI, reruns, whitelisting | `civicrm-ci-results` |
| Reproducing a bug | `civicrm-verify-bug` |

## Completion

When this skill was used to place something, state where it went or would
go (tracker and project, or repository and branch), what was searched
beforehand, and which existing issues or pull requests it links.
