---
name: civicrm-review
description: Review someone else's CiviCRM core or extension pull request - pick and claim it, read the issue and diff, reproduce on base and validate via CiviKitchen A/B proof-of-fix (red on A, green on B), base-test regression guard, and live surface diff, check ecosystem blast radius and git history via civicrm-knowledge MCP, run Stage 2 adversarial verification with review-verifier, and draft the review comment for the user's go. Use for "review PR 12345", "review this extension PR", "is this PR mergeable". Only for someone else's change; receiving review on your own PR is civicrm-pull-request.
---

# Review a CiviCRM pull request

Sources: Developer Guide [`core/pr-review`](https://docs.civicrm.org/dev/en/latest/core/pr-review/)
and [`standards/review`](https://docs.civicrm.org/dev/en/latest/standards/review/)
with its templates under `docs/standards/review/template-*.md`. A review
needs no special rights; merging is done by maintainers. Uncited rules are
this repository's own practice (README, "Contributing"). Running a stack:
`civikitchen`.

Applies to both `civicrm/civicrm-core` PRs and CiviCRM extension PRs/MRs.
When the optional `civireview` CLI is installed to prepare worktrees, A/B
runs, browser checks, or surface diffs (with optional `include`/`exclude`
check selection in `civireview.yaml`), consume its outputs; the skill
remains 100% standalone with `gh`/`glab`, `git`, and `ck`.

## Pick and claim

- Pick a pull request with green tests, no merge conflicts, no `WIP` in
  the title and no unresolved disagreement or unanswered question.
- **Closed or merged PRs.** The same workflow also works on closed or
  merged PRs for post-merge or audit reviews — use a `COMMENT` review
  without blocking or requesting merge labels.
- Claiming it ("Reviewing this now") is a comment: outward text, so only
  after the user's go.

## Read

1. The linked issue: how to reproduce, what the solution should be.
2. The base branch and diff:
   - Core: `gh pr view <n> -R civicrm/civicrm-core --json baseRefName,headRefOid,files`
   - Extension: `gh pr view <n> -R <owner>/<repo> --json baseRefName,headRefOid,files` (or `GITLAB_HOST=lab.civicrm.org glab mr view <n> -R <group>/<project>`)
3. Label honesty (core): `(NFC)` excludes refactorings, altered tests and
   changed docblock annotations; `(REF)` must preserve behaviour
   (`tools/git.md`). A removed function needs its deprecation period
   (`civicrm-pull-request`, `references/code-changes.md`).

## Reproduce and validate

Reproduce the problem on the base branch first and judge whether it is a
problem worth solving. Then validate the fix, proportionately (`r-run`):

- **Demo site and CI.** For core, the bot links an "Online demo of this
  PR"; it expires after hours or days. A red or missing check is explained,
  not only seen (`civicrm-ci-results`). Labels `run-drupal-x`,
  `run-wordpress`, `run-extended-tests` and others request more tests, for
  those allowed to add labels, after the user's go; integration or
  bootstrap changes merit them.
- **Proof-of-fix (Red on A, Green on B) with `ck ab`.** Choose the
  Standalone image matching the base (`standalone-master`,
  `standalone-beta`, or `standalone-<X.Y>` built from git when targeting an
  older branch) and compare base (A) against PR head (B) in one run:
  - Core PR:
    `ck ab <image> <image> --mount <PR-tests>:/var/www/html/core/tests --mount-a <base-code> --mount-b <PR-code> --json <out> --surface -- ckcoretest --log-junit /tmp/ck-ab.xml <test>`
  - Extension PR (worktree A at base, worktree B at PR head):
    `ck ab <image> <image> --mount-a <base-ext>:/var/www/html/ext/<name> --mount-b <PR-ext>:/var/www/html/ext/<name> --json <out> --surface -- sh -c 'cd ext/<name> && phpunit --log-junit /tmp/ck-ab.xml <test>'`
  - Or run single-side `ck run` passes: first on the base image with only
    `--mount <checkout>/tests:/var/www/html/core/tests -- ckcoretest <path>`
    (expecting red), then adding `--mount <checkout>/CRM:/var/www/html/core/CRM`
    (and any other touched code dirs) for green.
  A test that passes on both A and B (or passes without the fix) proves
  nothing — flag it as unvalidated.
- **Base-test regression guard.** Run base branch A's existing tests
  against both A and B (`--mount <base-tests>:/var/www/html/core/tests`
  with `--mount-a <base-code> --mount-b <PR-code>`, or extension base
  tests against both worktrees) so altered or deleted PR tests cannot hide
  regressions.
- **Live permission & API surface diff.** Inspect `ck ab --surface` output
  or run `ck surface --diff` across A and B to verify APIv4, APIv3, Menu
  route, and Afform permission deltas empirically instead of guessing from
  code.
- **Standalone Browser A/B.** Run as part of the default review whenever
  routes, templates, Afforms, SearchKit displays, or frontend assets
  change:
  - **Tier 1 (automated):**
    `ck ab <image> <image> ... --page <civicrm/...> [--anon-page <civicrm/...>] --json <out>/ab-report.json --surface -- ...`
    captures before/after screenshots, JS console errors, uncaught page
    errors, HTTP `>=400` network failures, and axe-core WCAG 2.1 AA
    accessibility diffs (`browser-diff.json`). Focuses on CiviCRM
    Standalone first; list other CMS flavors as not verified unless
    separately tested.
  - **Tier 2 (interactive):** `ck ab ... --keep --expose` exposes
    `A_URL` and `B_URL` on localhost so a drivable browser (Playwright
    MCP or browser tool) can inspect and click through both Standalone
    instances directly. For quick single-PR visual checks, `ck demo <PR> --page <route>`
    also works. A claimed regression between versions: `ck ab`.
- **Limit of a mount.** Mounts and `ck demo` apply files only, with no
  `composer install` and no schema upgrade: a change to the schema or to
  composer dependencies does not reach the installed database or
  `vendor/` (civikitchen `docs/core-development.md`, "Recording a change
  before and after: `ck demo`"). Core changes to schema or dependencies
  need an image built from the change
  (`scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=<ref>`). The
  Dockerfile fetches that ref from `civicrm/civicrm-core` itself, so a
  commit only on the contributor's fork cannot be built without changing it,
  and the image is tagged with the ref, so a ref containing `/` fails:
  docker rejects `civikitchen:standalone-refs/pull/<n>/head` as an invalid
  tag before it builds anything. Otherwise write "schema change not
  verified locally". For extensions, re-run install/upgrade or `cv ext:enable`
  when schema or managed records change.
- **Database upgrades (core).** The guide installs the latest release,
  applies the PR, runs `bin/setup.sh -Dg` and the upgrade. civikitchen
  cannot do this; write "upgrade path not verified locally" and read the
  `civicrm-upgrade-test` result in CI. Check that a new upgrade step sits
  in the version of `xml/version.xml` on the base branch
  (`civicrm-pull-request`, `references/code-changes.md`, "Schema and
  upgrade steps").
- Runs stay targeted: the changed files' tests plus one or two neighbours,
  red and green. Name a broader suite with its runtime instead of starting
  it. Anything that could not run is listed as not verified, never left
  out.

## Ecosystem blast radius and history (`civicrm-knowledge` MCP)

When the `civicrm-knowledge` MCP server is connected (otherwise use a local
checkout or shallow clones per `civicrm-project-map`):

- **Ecosystem blast radius (`r-tech`).** Whenever a PR changes or removes a
  public method, hook, event, APIv4 entity/action, or CSS class, search
  across indexed extensions with `civicrm_grep` and `civicrm_find_hook` to
  spot downstream breakage.
- **Chesterton's Fence.** Before approving removal or refactoring of a
  defensive check, guard, or workaround, inspect git history with
  `civicrm_history` (when a token is configured) or `git log -S` / `git log -L`
  to understand why it exists.

## Judge and Stage 2 adversarial verification

1. Give each standard of `standards/review.md` (`r-explain` … `r-test`) a
   Pass or Issue and check the gotchas that apply (`rg-pkg`, `rg-perm`,
   `rg-sec`, `rg-setting`, `rg-upgrades`, `rg-hook`); see `references/standards.md`.
2. **Stage 2 sceptical verifier (mandatory before drafting).** Delegate all
   candidate findings — with PR base/head refs and any `surface-diff.json`,
   `ab-report.json`, or `browser-diff.json` — to the `review-verifier`
   agent for a fresh read-only disproof pass.
   Suppress findings that `review-verifier` marks `REJECTED` (disproven
   against source/MCP or style-only/speculative) or drops below confidence
   threshold; separate `PROVEN`/`CONFIRMED` bugs from `NEEDS_QUESTION`.

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
- Start every review with a **2–3 sentence TL;DR Summary** and a **1–5 Merge Confidence Score** (plus a short bullet list of key findings if any), and tuck verbose walkthrough notes and all-PASS standards tables into collapsible `<details>` blocks so reviewers are not forced to read everything.
- Include a **1–5 Merge Confidence Score** with a one-sentence rationale grounded in verified findings and empirical checks:
  - `5/5` — Safe to merge: no verified findings; A/B proof-of-fix (or tests) and CI passed with 0 regressions or surface risks.
  - `4/5` — Minor follow-up: only low-severity or question-only findings, or a minor verification gap/warning (e.g. skipped A/B, surface flag, or a11y warning).
  - `3/5` — Moderate risk: confirmed medium defect, base-test regression needing confirmation, or unproven/errored A/B proof.
  - `2/5` — High risk: confirmed high-severity defect or empirical CI/taint/browser/test regression.
  - `1/5` — Critical blocker: confirmed critical defect or multiple confirmed high-severity defects.
- Say what was reproduced and tested (A/B red/green results, surface diff,
  Standalone browser A/B diff, base-test guard), on which base and commit,
  and what was not verified (including non-Standalone CMS flavors unless
  separately tested). For closed or merged PRs, post a `COMMENT` review
  without blocking or recommending merge labels.
- Declare the agent's name, use and role (`AGENTS.md`: "clearly declared
  in commits, PRs, etc."), e.g. one blockquoted line on what the agent ran
  and drafted; the judgement posted is the user's.
- `civicrm-core` has GitHub labels such as `merge ready`, `merge on pass`,
  `has-test`, `needs-test` and `needs-work-not-review-ready`; the
  Developer Guide does not document their use. Recommend one in the
  comment, do not set it.
- Draft it, show it, post only after the user's explicit go.

A second, independent look at your own review is another local review
pass with an explicit base (commit range), not a public request; asking
anyone in public needs the user's go.

## Completion

Name the PR, base branch and head SHA; what was reproduced on base A and
PR B (commands, red and green, surface diff, Standalone browser A/B diff);
CI status read; each
standard's verdict; verified findings by severity (and any suppressed
candidate counts); what was not verified and why; the drafted comment, and
whether it was posted.

A gap in this skill that cost time (a wrong command, a missing step, an
unnamed trap) is reported as an issue or fixed in a pull request on
civico-de/civicrm-skills, after the user's go.
