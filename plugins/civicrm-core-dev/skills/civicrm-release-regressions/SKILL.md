---
name: civicrm-release-regressions
description: Find regressions in a CiviCRM version before it is released or right after - in the release candidate, on master, or in a fresh stable. Use for "test the RC", "is 6.x safe to upgrade to", "what broke since the last release", running an extension's suite against beta and master, comparing two versions, testing a private or security branch that has no image, checking a security backport's diff for legitimate use it refuses, bisecting a regression to its commit, and reporting it so it is fixed before or in the next point release. Owns comparing versions around a release; one suspected bug on one version is civicrm-verify-bug; "is this a regression in X.Y" starts here.
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
   non-zero; script errors the page logs are only listed in the report:
   read from civikitchen's source, not confirmed by a run). Otherwise name
   the browser as not covered.
4. **The other CMS integrations.** Standalone is the fast loop; a regression
   in routing, permissions, assets or user sync shows only on the CMS.
5. **What changed.** Read the release notes and
   `git log <A>..<B> --stat` for the components you depend on, and aim
   checks at those: changed function signatures, removed deprecated code,
   schema changes, reworked forms. Where CI already runs B's own suites,
   as on a security or point-release branch, reading the code diff
   (`git diff <A> <B> -- . ':!tests' ':!*/tests/*'`) is the main check.
   Ask of every hunk which legitimate use it now refuses:
   - a contract other code relies on: event methods a listener has to call,
     new scalar type declarations (`?int` rejects `''`), an exception where
     a value used to pass through;
   - stricter input: validation or escaping that throws on a value an
     existing form, saved report or stored setting still sends;
   - new encoding: a value used as a path, URL or markup on purpose;
   - a new permission check on a path other roles use.

   Settle each one in the code of branch B (`git grep <term> <B>`, not the
   checked-out branch) by finding the callers or the stored values that
   reach it, and name the ones that stay open.

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
- More than a handful of tests under "pass on A, fail on B": hand each
  test to this plugin's `regression-triage` agent first, one agent per
  test and a few at a time, since each boots three stacks. Give it `TEST`,
  `A`, `B`, `RUN` (the command that runs only that test), `CK` (how `ck` is
  called here), `ID` (a short lowercase word of its own) and, as
  `OPTIONS`, the `--mount` and `--locales` arguments of the A/B run. It
  reruns the test alone, twice on B and once on A, and returns a verdict
  in a fixed format; it runs fixed steps on a small model, the judging
  stays here. Continue with `reproduced`.
  `flaky` and `fails-on-both` are no regression between A and B.
  `passes-alone` points at state an earlier test leaves behind, which may
  itself be new in B. Read the `A:` line with every verdict: a control
  that failed alone is not the pass the A/B run showed. Rerun `could-not-run` yourself. With a handful or
  fewer, or where the agent is not available, do the three runs yourself.
  Where the A/B run was on another machine, pull both images first: a run
  that has to pull one can outlast the ten minutes the agent gives it.

Data in these instances is seed data. Never copy a production database into
one to "get realistic data".

## A branch without an image

A branch that is in no image and that `ck make build` cannot build, such
as a private security branch whose refs are not public, runs on the image
of the release it is based on, with its changed directories mounted over
the image's copies. `ck ab` puts the same `--mount`s into both stacks, so
two such sides need one `ck run` each:

1. Check that the diff to the release holds no schema, `composer.*` or
   upgrade change (`git diff --name-only <release> <branch>`): a mount
   covers files only.
2. One work tree per side (`git worktree add --detach <dir> <ref>`),
   under `$HOME`.
3. Each side mounts the directories the diff touches (`CRM`, `Civi`,
   `templates`, `ext/<name>`) from its own work tree. Both sides mount
   `tests` and every `ext/<name>/<part>/tests` from A's work tree: B's
   own tests already ran in its CI, and A's tests against B's code find
   the regressions that an updated or removed test in B hides.
4. Write each suite's JUnit into a directory mounted from the host, e.g.
   `--mount "$HOME/ab-out:/out"` and
   `ckcoretest --log-junit /out/<side>/<n>.xml <suite>`, and give each
   side its own `--name`.
5. Compare the two sides per test: pass on A and fail on B, fail on both,
   ran on A only. The bullets of the A/B section apply unchanged.

A branch that is not public stays local: no image pushed, no public
issue, no public pull request (`civicrm-pull-request`).

## From difference to cause

- Intended change or regression? Check the release notes, the PR that
  touched the code and its tests. A documented behaviour change is an
  upgrade note for your own code, not an upstream bug.
- Find the commit with `ck bisect` (civikitchen
  `docs/core-development.md`, "Finding the commit"). It runs `git bisect`
  over a range of civicrm-core with the reproducer as the check, in one
  stack that has directories of a checkout mounted:

  1. Make the reproducer a command whose exit status is the verdict: 0
     when the behaviour is right, 1 when it is broken. A headless test
     (`ckcoretest <file>`) or a `cv ev` one-liner does; a check that needs
     a browser cannot drive a bisect.
  2. Give the run a work tree of civicrm-core of its own
     (`git worktree add --detach <dir> <B>`): its HEAD moves during the
     run. A reproducer test that is in no commit goes into that work tree
     as an untracked file, under a name no commit in the range uses.
  3. Take the image whose core is B or closest to it; the site installs
     on B. As `--dir`, name the directories that hold the suspect code and
     the reproducer (`git diff --stat <A>...<B>` lists what changed). A
     check that is an extension's test also needs the extension:
     `--mount <its checkout>:/var/www/html/ext/<name>`.
  4. Run it:

     ```bash
     ck bisect <image> --core <dir> --good <A> --bad <B> --dir CRM --dir Civi --dir tests -- ckcoretest tests/phpunit/<reproducer>
     ```

     It requires the check to pass on A and fail on B, bisects, and
     reruns the check on the commit found and on its parents.
  5. Exit status 0: the commit is confirmed. Name its pull request:
     - Its own subject reads `Merge pull request #…`: that is the one.
     - Otherwise it is the oldest pull request merge that descends from
       the commit:
       `git log --merges --ancestry-path <commit>..origin/master --reverse --format='%h %s' | grep -m1 'Merge pull request'`.
       Check that this merge brought the commit:
       `git merge-base --is-ancestor <commit> <that merge>^` exits 1. With
       0 the commit sat on the branch before that merge and has no pull
       request (a version bump, for example).
     - No output: `origin/master` does not hold the commit, or nothing was
       merged after it. Run the command with the release branch that holds
       it (`git branch -r --contains <commit>`), or name the commit
       without a pull request.

     Any other outcome (status 1 "not confirmed", a check that does not
     pass on A, only skipped commits left): say "introduced between A and
     B" with the reason `ck bisect` printed, and name no commit.

  `ck bisect` lists what the range changes outside the mounted
  directories. Every commit runs on the image's copy of those, a mixed
  state: say so in the result, and take a failure unrelated to the
  reproducer as a sign of it. Schema or composer changes between the two
  ends, or commits on which the site no longer flushes its caches, need an
  image built per commit instead; narrow the range by release tags first.
- The result is one commit and its PR, or "introduced between A and B".

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
