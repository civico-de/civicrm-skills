---
name: civicrm-release-regressions
description: Find regressions in a CiviCRM version before it is released or right after - in the release candidate, on master, or in a fresh stable. Use for "test the RC", "is 6.x safe to upgrade to", "what broke since the last release", running an extension's suite against beta and master, comparing two versions, bisecting a regression to its commit, and reporting it so it is fixed before or in the next point release. Owns comparing versions around a release; one suspected bug on one version is civicrm-verify-bug; "is this a regression in X.Y" starts here.
---

# Find regressions around a CiviCRM release

A regression is behaviour that worked on version A and is broken on
version B. Every claim here is therefore a pair of runs: the same check,
green on A, red on B, each side named by its exact version, plus the
commit for an image built from git. One red run on B is a bug
report at best; it is a regression only with the green run on A beside it.

CiviCRM's cycle gives a fixed window. master is the next-but-one version;
the newest `X.Y` branch is cut soon after each monthly release and is the
release candidate until the next one, on the first Wednesday of the month;
then it ships and gets point releases. A regression reported while the version is
still the RC can be fixed before anyone installs it. One found after
release may get a point release if it is serious enough; the report should
name the introducing change.
[civikitchen](https://github.com/civico-de/civikitchen) builds
`:standalone-beta` (head of the newest `X.Y` branch) and
`:standalone-master` daily, `:standalone` for current stable and
`:standalone-<minor>` for supported minors.

## Where regressions are found

Core's CI already runs core's PHPUnit suites on every pull request, so
rerunning them finds the least. Run the classes around what you depend on
as a baseline, and look mainly where core's CI does not:

1. **Extension suites against the new core.** The tests of extensions that
   pass on stable, run unchanged against beta and master. Every failure is
   either a core regression or an extension relying on something that was
   never promised; both are worth knowing before release.
2. **The upgrade path.** Install A with data, upgrade the database to B,
   then run the checks. A fresh install of B hides everything the upgrader
   or old data breaks.
3. **The browser.** Afform, SearchKit displays, Angular screens and theme
   rendering are decided in JavaScript and are thin in core's PHP tests.
   Exploring them needs a browser the agent can drive (`civicrm-verify-bug`,
   step 4). A `ck demo` recording is evidence for a person, not
   exploration: count it as browser coverage only when its `--steps`
   module asserts the behaviour (an error thrown there ends the run
   non-zero; script errors the page logs are only listed in the report,
   per civikitchen's source, not run here). Otherwise name the browser
   as not covered.
4. **The other CMS integrations.** Standalone is the fast loop; a regression
   in routing, permissions, assets or user sync shows only on the CMS.
5. **What changed.** Read the release notes and
   `git log <A>..<B> --stat` for the components you depend on, and aim
   checks at those: changed function signatures, removed deprecated code,
   schema changes, reworked forms.

When an extension's suite turns red against a daily image, the first
question is which side moved: rerun the last green extension commit
against today's image. Still red points at core or the image (PHP,
MariaDB, a dependency): compare the commits in the two images' `civicrm-source.log` before naming core.

## A/B with `ck ab`

```bash
ck ab standalone standalone-beta -- ckcoretest --log-junit /tmp/ck-ab.xml tests/phpunit/api/v4/Query
ck ab standalone-6.16 standalone-master --mount "$PWD:/var/www/html/ext/myext" -- <the extension's check>
```

`ck ab` boots both versions as fresh Standalone stacks, runs the same
command in each and, when the command writes JUnit to `/tmp/ck-ab.xml`,
lists the tests that pass on A and fail on B (exit status 1), those fixed,
those failing on both, and those that no longer run on B. Without a report
it compares exit statuses.

- Note the version and commits it prints for each side. Daily tags move, and
  a locally cached `:standalone-beta` can be older than the current stable:
  `docker pull` both before a run that matters.
- "Fail on both" is not a regression between A and B. "No longer runs on B"
  is worth a look: a test that silently stopped running hides whatever it
  guarded.
- For something visible, `ck demo <diff or PR> --page <route> --cms all`
  records before and after side by side; for another CMS or an upgrade from
  A to B with data, boot the two stacks by hand with the same profile and
  seed data and run the identical check on both.
- Each difference gets a reproducer of its own and goes through
  `civicrm-verify-bug`, with A as the control run.

Data in these instances is seed data. Never copy a production database into
one to "get realistic data".

## From difference to cause

- Intended change or regression? Check the release notes, the PR that
  touched the code and its tests. A documented behaviour change is an
  upgrade note for your own code, not an upstream bug.
- Bisect with the reproducer as the oracle: `git bisect start <B> <A>` in a
  core checkout, with the directories that hold the suspect code mounted
  into a git-built instance (`git diff --stat <A> <B>` names them), `cv
  flush` between steps, `git bisect run` when the test is headless. Mounted
  code on an older image is a mixed state: say so in the result, and take a
  failure unrelated to the reproducer as a sign of it. Schema, settings or
  composer changes between the two ends, or a stack that no longer boots,
  need a rebuilt image per step; narrow the range by release tags first.
- The result is one commit and its PR. If bisecting is not feasible, say
  "introduced between A and B".

## Reporting

A regression report contains: last good version and first bad version with
commits, the introducing PR if found, the reproducer as a test that passes
on A and fails on B, and who is affected (which screen, API or integration).
During the RC window, say so: it decides whether the release ships with
it. A critical regression traced to a change in the RC is what the RC
branch takes fixes for; any other goes to `master` (`civicrm-project-map`,
"Branches and releases").
The fix carries the test (`civicrm-tests`).

Separate from this, for your own sites: a verified regression in a version
you have not deployed yet is a reason to hold the upgrade or patch first.
State which.

## Completion

List what was compared (A, B, commits, CMS), which checks ran on both, the
differences found with their status (regression verified / intended change /
not reproduced / still open), and what was not covered: upgrade path,
browser, other CMS.
