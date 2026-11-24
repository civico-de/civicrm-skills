---
name: civicrm-pull-request
description: Contribute your own change to CiviCRM upstream - decide between a pull request, an issue and a private security report, follow core's rules for the code (AGENTS.md, lint, upgrade steps, deprecation, dependencies), prepare branch, commit and PR body by core's template and its AI rules, push and open it as draft after the user's go, use the PR bot commands, receive and answer review on your own PR, including a civireview review. Use for "open a PR for this fix", "report this upstream", "answer the review on my PR", "handle the civireview findings", before writing code for core and before anything is pushed or created on GitHub or lab.civicrm.org. Searching for an existing issue, where to report and which branch to target are civicrm-project-map; writing the test is civicrm-tests; reviewing someone else's PR is civicrm-review.
---

# Contribute a change upstream

Where things live and which branch takes what: `civicrm-project-map`.
Sources: Developer Guide [`tools/git`](https://docs.civicrm.org/dev/en/latest/tools/git/),
[`tools/issue-tracking`](https://docs.civicrm.org/dev/en/latest/tools/issue-tracking/),
[`core/contributing`](https://docs.civicrm.org/dev/en/latest/core/contributing/),
[`core/release-process`](https://docs.civicrm.org/dev/en/latest/core/release-process/),
and in civicrm-core `AGENTS.md`, `.github/PULL_REQUEST_TEMPLATE.md`,
`.github/workflows/pr-commands.yml`. Uncited rules are this repository's
own practice (README, "Contributing").

**Every outward step waits for the user's explicit go:** pushing a branch
to a public fork, a force-push, a PR bot command, a workflow run in the
fork, opening or marking a pull request, an issue, any comment or reply.
Draft it, show it, act after the go. One go covers one item, and the item
is what was shown: opening a pull request is one item (see "Opening").

## Pull request or issue

- **You can fix it: open a pull request with the fix and a test.** The
  Developer Guide says to consider an issue and recommends one for
  significant changes, expected discussion or several pull requests
  (`tools/git.md`, workflow step 1); otherwise go straight to the pull
  request.
- **Open an issue when the change needs other people's input:** a design
  decision or unclear intended behaviour, a significant change or one where
  discussion is expected, a change split over several pull requests, or a
  fix outside your reach.
- APIv3 is "minimally maintained with no new features and regression
  bug-fixes only" (`api/index.md`). A v3/v4 difference is a question about
  v4; a v3 fix is a regression fix with its introducing commit, or stays
  inside v3; a fix for both goes into the BAO or v4 with the test in v4.
- **A security problem is neither.** Report it to security@civicrm.org
  ([`security/reporting`](https://docs.civicrm.org/dev/en/latest/security/reporting/))
  with what is needed to replicate it. Keep it out of public pull
  requests, issues, commit subjects and chat until the security team
  decides; a "harmless" fix-only pull request, or a fix branch pushed to a
  public fork, discloses it too. In the report: what an attacker gains,
  code as permalinks, steps, limits, the introducing commit, fixture data
  only, no severity adjectives. The agent drafts the report; the user
  sends it. Never mail it from the agent.

## Before writing code

1. Search open and closed issues and pull requests (`civicrm-project-map`,
   "Before reporting or fixing"); write down what was searched.
2. A bug claim or a fix: reproduce on current `master` or the branch in
   question (`civicrm-verify-bug`); unverified, it gets no pull request
   and no bug report. An issue that asks a question (design, intended
   behaviour) needs no reproducer; it states what was verified and what
   was not.
3. Read core's `AGENTS.md` on the base branch, then
   `references/code-changes.md` for the kind of change: JavaScript and
   translation rules, lint, secure coding, schema and upgrade steps,
   deprecation, dependencies. A change to a hook, API or signature: find
   its callers in core and the published extensions first.
4. For a fix: the test fails without it on the assertion that states the
   bug and passes with it (`civicrm-tests`, `references/regression-test.md`).
   For a regression, find the introducing commit
   (`civicrm-release-regressions`).

Comments describe the code as it stands, in about two lines, without
reference to the change or what it replaced. Keep lint clean by
refactoring; a suppression is narrow and carries its reason on the line.

## Branch and commits

- Base branch: the rule in `civicrm-project-map`, "Branches and
  releases"; usually `master`.
- Fetch, branch from `<upstream>/<base>`, push to your fork, never to
  `civicrm/*`, and only after the user's go: a public fork publishes the
  change. Pass `-R civicrm/civicrm-core` to every `gh` call.
- Commit subject: `dev/core#1234 - Subsystem - What changes`, the issue
  reference only when there is one; at most 72 characters, sentence case,
  imperative, no full stop. The body explains why.
- Each commit makes sense on its own. Fix an unpushed commit with
  `git commit --amend` (`AGENTS.md`). After pushing, new commits are fine;
  on conflicts rebase, show the result, and force-push to your fork after
  the user's go.
- One clearly defined problem per pull request, with its test. Minor,
  uncontroversial cleanup may be a separate commit; anything larger is a
  separate pull request.
- Message templates or seeded option values changed: regenerate
  `sql/civicrm_generated.mysql` (`bin/regen.sh`, it wipes the database, or
  the `regen.yml` workflow in your fork, dispatched after the user's go).
- Lint the branch before pushing (`references/code-changes.md`, "Code
  style (lint)").
- First pull request: add yourself to `contributor-key.yml`.

## Title and body

- The title is what release-note editors read: for a bug fix, the bug
  stated concisely ("Changes to CiviContribute Component Settings not
  saved"), with a modifier when it applies only to some cases
  (`core/release-process.md`). Prefixes: `(WIP)` not ready, `(REF)`
  behaviour-preserving refactoring, `(NFC)` no functional change. Altering
  an existing test, a refactoring or a changed docblock annotation is not
  NFC (`tools/git.md`, NFC).
- Body: the template's `Overview`, `Before`, `After`, `Technical Details`,
  `Comments`; only Overview is required. Link the issue, an earlier closed
  pull request with discussion, and the ports to other branches.
- The template: Overview "must be written by a human. PRs with AI-written
  overviews may be rejected"; AI output in every optional section goes "in
  blockquotes … brief". The agent leaves Overview to the user. This
  repository's practice: the agent writes short, plain blockquoted Before
  and After and leaves Technical Details to the user.
- `AGENTS.md`: "the name, use and role of the agent must be clearly
  declared in commits, PRs, etc."; it forbids a session-link trailer and
  prescribes no format. One compact way covering all three: a
  `Co-authored-by:` trailer for the name in each commit, and one line in
  the pull request body saying what the agent did and what the human did
  (for example "> Reproducer, fix and Before/After drafted by <agent>;
  reviewed and tested by me."). civicrm-dev-docs and civicrm/coder carry
  no `AGENTS.md` or template of their own; the rule is written for core.
- Admins must act after upgrading: a post-upgrade message or a system
  check, named in the body. Behaviour the guides describe changed: a pull
  request in the documentation repository, linked.
- Everything posted on a forge is English. Link code with permalinks on a
  full commit SHA and a line range, never a branch name.

## Opening

Show the user title, body, base branch, the fork branch and the full diff.
Their go on that covers this one item: pushing the branch to the fork and
running `gh pr create --draft -R civicrm/civicrm-core --base <base>`. If
they approve only the push, push and stop. Marking it ready (`gh pr ready`)
is a separate item.

## After opening

- Read the checks with `civicrm-ci-results`.
- Comment commands, for the pull request's author or a repository owner,
  member or collaborator (`pr-commands.yml`). Each is a public comment that rewrites history, so
  each needs the user's go:
  - `/squash` squashes into one commit with the first commit's message;
    `/rebase` rebases onto the base, `/rebase <branch>` onto another branch
    and retargets the pull request; `/lint` or `/lintroll` rebases onto
    the current base, running `civilint --fix` on each commit, and fails
    on a conflict. These force-push the pull request's branch: fetch
    before working on it again.
  - `/port <branch>` leaves the pull request's branch alone: it rebases a
    copy onto `<branch>`, force-pushes it to `port-<PR>-<branch>` in
    civicrm/civicrm-core and opens, or on a rerun updates, a separate pull
    request `Port: "<title>" to <branch>`; also after merge.
- Receiving review: check every finding against the actual source before
  acting; a finding you want to dismiss gets a second, adversarial look
  first. An independent second opinion is another local review pass with
  an explicit base (commit range), not a public request; asking anyone in
  public needs the user's go.
- Answer review in the pull request, drafted for the user's go.
  Every finding gets an answer in its own thread, automated reviews
  included: "Fixed in <sha>." or "Not changed: <reason>." in one short
  line, then resolve the thread. Reviewers lean on those findings and
  cannot tell a fixed one from an open one after a force-push. A
  "Fixed" line for a finding verified at head needs no separate go.
  A civireview review: `references/civireview.md`.
  Substantive discussion there goes into the issue too; a pull request
  closed in favour of another is explained in the issue and named in the
  new one (`core/contributing.md`). After long discussion, update the
  description to what was finally done.

## The issue path

- Where: core and the CMS integrations in lab.civicrm.org group `dev`; an
  extension where its `info.xml` points; tools on GitHub
  (`civicrm-project-map`).
- Title: the bad thing that happens, concretely, never "improve X". One
  closeable problem per issue.
- Body, around ten lines: the problem; measured evidence (failing test,
  output, commit) or, for a question, what was and was not verified;
  version and environment; minimal reproduction where there is one; the
  question others must answer. No next-step list, no speculation.
- Labels such as `regression` need membership in the Development group;
  without it say "regression" in the text.
- Show it to the user, create after their go. Once the fix is yours to
  make, the pull request references the issue as `dev/core#1234`.

## Completion

State which path was taken and why (pull request, issue, security report),
what was searched beforehand, the base branch, the red and green runs of
the test, the lint result, the title and body shown to the user, and the
URL if they gave the go and it was created. Name what is still open: CI,
review, port.

A gap in this skill that cost time (a wrong command, a missing step, an
unnamed trap) is reported as an issue or fixed in a pull request on
civico-de/civicrm-skills, after the user's go.
