---
name: civicrm-verify-bug
description: Verify a suspected CiviCRM bug in a disposable civikitchen instance before it is reported or fixed. Use for "reproduce this bug", for the red run without a fix and the green run with it, and when a core bug is suspected from reading code, a user report or a failing test, also one that shows up through an extension, and before drafting an issue, a PR or a fix. Covers image choice, ckcoretest, ck demo, the failing reproducer and the evidence a finding needs. Owns the verification workflow for one suspected bug and uses civikitchen for the instance; comparing versions or "is this a regression in X.Y" is civicrm-release-regressions, the test that ships with the fix is civicrm-tests.
---

# Verify a CiviCRM bug with civikitchen

Reading the source produces a suspicion. A bug is verified when a test
fails in a clean instance on a named core version, on the assertion that
states the bug, with a control beside it that passes. Until then, say
"suspected" and do not draft an issue, a PR or a fix on top of it. A
verified bug can be reported without a fix; a fix is proven separately, by
the same test turning green.

civikitchen (`github.com/civico-de/civikitchen`) provides the images and the
`ck*` tools used below; `docs/core-development.md` there is the reference.
Check it when a command behaves differently from this page.

## Sequence

1. **Search upstream first.** Look for an existing issue or PR on
   lab.civicrm.org and GitHub, and check whether current master still has the
   code path. Write down what you searched and what you did not.
2. **Pin the base.** `:standalone-master` and `:standalone-beta` are built
   daily from core's master and newest release branch (shortly after a
   release, beta can still be the branch that just shipped); a released version
   uses its tag. Another upstream branch or tag is built from git
   (in a civikitchen checkout:
   `scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=<ref>`; the
   ref must exist in civicrm-core and civicrm-packages; the result is the
   local image `civikitchen:standalone-<ref>`). A contributor's
   branch runs on the nearest image with its changed directories mounted.
   Record the commits from `/usr/local/share/civikitchen/civicrm-source.log`.
   A local checkout or an image pulled last week is not "master".
3. **Boot** a stack of its own, with a compose project name no other
   session uses. For core, when one command settles it:
   `ck run <image> --name <name> --mount <checkout dir>:/var/www/html/core/<dir> -- ckcoretest <path>`.
   For a longer investigation: a compose file as in civikitchen's
   `examples/standalone/` with the chosen image, then
   `docker compose -p <name> up -d --wait` and
   `docker compose -p <name> exec -u www-data app <cmd>` (see the
   `civikitchen` skill). When the bug shows up through an extension,
   mount the extension into the stack at `/var/www/html/ext/<name>`.
4. **Reproduce at the boundary the claim is about.** A claim about the UI is
   reproduced by clicking through the UI, including the setup the user would
   do there; creating that state through the API proves only half the path.
   That needs a browser the agent can drive (for example the Playwright
   MCP server or Claude in Chrome; any equivalent counts): read the page
   snapshot, console messages and network requests instead of inferring
   from code. `ck demo` records fixed routes and a scripted `--steps` flow
   as videos and lists each page's script errors; that is evidence for a
   person watching it, not a way to explore a page, and it proves the
   behaviour only where its `--steps` module asserts it. Without a
   drivable browser, say so and report the UI claim as not reproduced in
   the UI; the rest of the investigation goes on. Behaviour outside the UI
   is reproduced through API or test.
   A claim about an API is reproduced through that API, with
   `checkPermissions` as the caller would have it.
5. **Write the reproducer as a test**, next to the existing tests for that
   class and in their style. Add a control: the nearest healthy case, which
   passes. Without a control, a red test can be a broken test.
6. **Red, and green if there is a fix.** Run the test without the fix and
   read the failure: it must fail on the assertion that states the bug, not
   on a setup error. With a fix at hand, apply it, flush (`cv flush`) and
   run the same test again. Keep the fix as a patch file or a commit of its
   own and toggle it with `git apply` / `git apply -R` in a checkout mounted
   over the touched directory, or use two worktrees. Do not toggle with
   `git stash`: it takes unrelated work and the reproducer with it.
7. **Classify.** Regression or long-standing? Find the introducing commit
   (`git log -S`, `git bisect` with the test as the oracle) and the first
   release containing it (`git tag --contains <sha>`), or write "unknown".
   Never estimate a version from a date.

## Discipline

- Capture before diagnosing: version, CMS, PHP, enabled extensions,
  acting user and permissions, entry point, data shape. A route's
  permission comes from menu XML (`CRM/*/xml/Menu/*.xml`,
  `ext/*/xml/Menu/*.xml`), from `hook_civicrm_alterMenu`, or for an Afform
  page from its `server_route` and `permission`. Ask the running site:
  `cv ev 'print_r(CRM_Core_Menu::get("civicrm/<path>"));'`, key
  `access_arguments`; an unknown path returns its nearest parent, so
  check `path` in the result.
- Root cause before fix: instrument, reproduce in isolation, remove the
  instrumentation before committing. "I changed it and it worked" is not
  causation; a cache flush is a diagnostic step, not an explanation.
- A claim about `cv`, bootstrap, database behaviour or timing is run in a
  throwaway instance first; the measured value goes into the commit
  message or pull request. No success from reading code when a runnable
  check exists; label every check that could not run.
- A control that finds nothing counts only if it looked at the right
  scope. A proposed fix counts only after it also ran against the
  success case.
- An incompatibility with a newer CiviCRM or PHP: establish the mechanism
  and fix at the proper layer, never fall back to an older version. Fix
  in reproducible artefacts (code, upgrade step, test), never by editing
  instance state by hand; no rebuild or wipe before the question is
  answered empirically.

## Which tool

`ckcoretest` exists on the Standalone images only.

| Bug shows in | Run |
|---|---|
| Core PHP, headless | `ckcoretest tests/phpunit/<path>` |
| A core extension (`ext/<name>`) | `ckcoretest --ext <name> <path>` |
| End-to-end, Mink, Angular screens | `ckcoretest --e2e <path>`, with `docker compose --profile browser up -d` |
| Something visible on screen, one CMS or several | `ck demo <PR or diff> --page <route> [--cms all]` |
| Upgrade path, karma, qunit | not covered; needs buildkit/civibuild. Say so instead of claiming it |

## Traps

- A released image ships without core's tests; `ckcoretest` fetches them for
  the tag. A git-built image carries its own.
- The mount covers files only. A change to composer dependencies or the
  schema needs a rebuilt image; `ck demo` also applies files only.
- Angular and asset caches serve the old code until `cv flush`.
- `--e2e` runs against the dev site, not the test database, and enables
  extensions there. Disable them afterwards.
- `ck demo` records before and after on one database: each phase must create
  its own starting state, or "after" passes because "before" did the work.
- A patch that does not apply to the instance's core is a base mismatch, not
  a result. Rebuild on the right base instead of hand-fitting hunks.
- A stack shared with another session gives flaky results. One stack per
  investigation.
- Never point any of this at a production database.

## What a verified finding contains

- Base: core version and commit, CMS flavour, extensions enabled.
- Upstream: what was compared and searched.
- Introduced by: commit and version, or "unknown".
- Problem in one to three sentences, and the mechanism with `file:line`.
- Steps, expected, actual (the exact assertion message), and where the
  expected value comes from (documentation, a sibling code path, the schema).
- The test: file, the methods that are red, the controls that are green,
  deliverable as a test-only patch that fails on the target branch.
- Status: failing test only / fix proven / duplicate / disproven. A
  disproven suspicion is recorded as such, not deleted.

Anything security-relevant leaves this path here: no public issue, no public
test. Follow the project's security process
(https://docs.civicrm.org/dev/en/latest/security/reporting/).

## Completion

State the base commit, the commands run, the red output of the reproducer
and the green output of the control; the green output with the fix only
when a fix was tested.
"Locally green" says nothing about upstream CI; report that separately once
it has run.
