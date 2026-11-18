---
name: civikitchen
description: Run CiviCRM in disposable Docker instances with civikitchen - choosing an image and tag (standalone, CMS flavours, master, beta, an old minor), booting a stack, running commands in it, core's PHPUnit suites (ckcoretest), mounting a core checkout, comparing two versions (ck ab), bisecting to a commit (ck bisect), recording before and after (ck demo), resetting, and the traps. Use whenever a task needs a real CiviCRM instance, "spin up CiviCRM", "test against 6.x", "auf master testen", or a ck* command. Only how to get and run an instance; reproducing a bug is civicrm-verify-bug; verifying a bug, reviewing a PR or hunting a release regression follow civicrm-verify-bug, civicrm-review and civicrm-release-regressions, which call this skill.
---

# civikitchen

[civikitchen](https://github.com/civico-de/civikitchen) provides CiviCRM
Docker images with the development tools built in, plus host commands that
boot and compare stacks. The host needs Docker with the compose plugin and
bash; PHP, node and browsers run in containers. Its documentation
(`docs/` in the repository, published at civico-de.github.io/civikitchen)
is the reference: `images.md`, `core-development.md`,
`configuration.md`. Read the matching page
before relying on a flag from this page; tools change between releases.

Never point an instance at a production database or copy production data
into one. Data in these instances is seed data.

## Pick the image

`ghcr.io/civico-de/civikitchen:<tag>`, multi-arch.

| Need | Tag |
|---|---|
| Current stable, fastest loop | `standalone` |
| A specific minor | `standalone-<minor>`, e.g. `standalone-6.16` |
| Core `master` | `standalone-master`, built daily from git |
| Release candidate | `standalone-beta`, head of the newest `X.Y` branch, built daily. Shortly after a release this can still be the branch that just shipped: check the version |
| Another upstream branch or tag | build it in a civikitchen checkout: `scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=<ref>`, which gives the local image `civikitchen:standalone-<ref>`. The ref must exist in civicrm-core and civicrm-packages (`master`, `X.Y`, release tags) |
| A contributor's branch or a single commit | the nearest image above, with the changed directories mounted from a checkout |
| Behaviour that crosses the CMS | `drupal10`, `drupal11`, `wordpress`, `joomla`, `backdrop` |
| A site to click through, with seed data | `<flavour>-demo`, optionally with `CIVIKITCHEN_PROFILE` |

Use Standalone unless the behaviour depends on the CMS. When a change
also touches other CMS paths, finish Standalone and name the rest as open. Moving tags are
rebuilt daily: `docker pull` before a run that matters, and record what
you ran on.

```bash
docker inspect <image> --format '{{ index .Config.Labels "org.opencontainers.image.version" }}'
docker run --rm --entrypoint cat <image> /usr/local/share/civikitchen/civicrm-source.log   # git-built: core and packages commits
```

## Boot and run

For one command on one version, `ck run` needs no compose file: it boots a
fresh stack, runs the command as `www-data`, removes the stack and returns
the command's exit status (`--keep` leaves it up and prints how to enter and
remove it). Write a compose file when the stack has to live longer or needs
more than mounts.

A stack is the app image plus MariaDB; `examples/standalone/` in the
repository is the starting point; it publishes fixed host ports (8080,
8081, 1080, 1025), so remove or change its `ports:` entries before a second
stack runs on the machine. With `CIVICRM_AUTO_INSTALL=1` the site installs
on first start and creates the headless test database `<db>_test`, which
needs `CIVICRM_DB_ROOT_PASSWORD`.

```bash
docker compose -p <unique-name> up -d --wait      # first boot installs; allow a few minutes
docker compose -p <unique-name> exec -u www-data app cv ev 'echo CRM_Utils_System::version();'
docker compose -p <unique-name> down -v           # -v for a clean reset
```

- One compose project per investigation, with a name no other session
  uses, and no fixed host port unless a browser needs one.
- CiviCRM lives in `/var/www/html`, core in `/var/www/html/core`,
  extensions in `/var/www/html/ext`. `cv` runs as `www-data` also when
  called as root, so files and caches it writes stay writable for the site.
- Before headless tests, confirm the configured database is the
  disposable one of this stack.
- Host paths mounted into a stack must be shared with Docker's VM: keep
  them under `$HOME` on macOS.
- Removing the app container without `-v` keeps the database but loses the
  site's settings. Standalone then installs again over the surviving
  tables; a CMS flavour refuses to rebuild unless `CIVIKITCHEN_REINSTALL=1`.
  For a clean start use `down -v`.

## Working on core

| Task | Command |
|---|---|
| Run core's PHPUnit | `ckcoretest tests/phpunit/<path>` in the app container |
| Suite of a core extension | `ckcoretest --ext <name>`, the path below `ext/`: `afform/core`, not `afform` |
| End-to-end and browser tests | `ckcoretest --e2e <path>`, plus `docker compose --profile browser up -d` |
| Test a change | mount the touched directory of a civicrm-core checkout over `/var/www/html/core/<dir>` |
| One command in a fresh stack, removed afterwards | `ck run <image> [--mount src:dst] [--name <project>] [--keep] -- <command>` on the host |
| Same check on two versions | `ck ab <A> <B> [--mount src:dst] -- <command>` on the host |
| The core commit at which a check starts to fail | `ck bisect <image> --core <checkout> --good <rev> --bad <rev> --dir <name> [--mount src:dst] -- <command>` on the host |
| Before and after on screen | `ck demo <PR or diff> --page <route> [--cms all]` on the host |

`ck` on the host is the `civikitchen-cli` image; it needs Docker and no
checkout. Run it from a directory below `$HOME`, with the `ck` arguments
after the image name:

```bash
docker run --rm -i --init --network host -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME:$HOME" -w "$PWD" -e HOME=/tmp -e CK_USER="$(id -u):$(id -g)" ghcr.io/civico-de/civikitchen-cli run standalone-master -- cv api4 Contact.get
```

In a civikitchen checkout `scaffold/ck` does the same and adds
`scaffold/ck make`, which building an image needs.
`ckcoretest`, `cktestreset`, `ck run`, `ck ab` and `ck bisect` work on the Standalone images only;
on a CMS flavour, reproduce through the site itself.

Checking behaviour in the UI of a stack by hand needs a browser the agent
can drive (for example the Playwright MCP server or Claude in Chrome; any
equivalent counts). Without one, say so, report the UI behaviour as not
verified and carry on with what needs no browser. `ck demo` records fixed
routes or a `--steps` script in its own Playwright container and lists
script errors: enough to show a visible change to a person, not to explore
a page; it proves behaviour only where its `--steps` module asserts it.
Core's own browser tests above run without either.

- A released image ships without core's tests; `ckcoretest` fetches them
  for the installed tag. A git-built image carries its own.
- Mount tests and code from the same commit as the image's core, or from
  one close to it. Tests newer than the core fail for reasons that have
  nothing to do with the change; a patch that does not apply is a base
  mismatch, not a result.
- A mount covers files only. A change to composer dependencies or the
  schema needs an image built from that branch. `ck demo` also applies
  files only.
- `cv flush` after every toggle of a mounted change; Angular and asset
  caches serve the old code otherwise.
- `--e2e` runs against the dev site, not the test database, and enables
  extensions there.
- `ck ab` compares per test when the command writes JUnit to
  `/tmp/ck-ab.xml`, otherwise by exit status.
- `ck bisect` moves the HEAD of the checkout it is given and installs the
  site on `--bad`: give it a work tree of its own and the image closest to
  `--bad`. The steps are in `civicrm-release-regressions`, "From
  difference to cause".
- Some failures belong to the environment, not the change (locale files,
  `open_basedir`). Run the unchanged class as a baseline before attributing
  a failure.
- Upgrade tests, karma and qunit are not covered; they need
  buildkit/civibuild.

## When it does not work

- `$GLOBALS[_CV][TEST_DB_DSN] is not set`, or `ckcoretest` refusing to run
  headless: no test database. It is switched off (`CIVIKITCHEN_TEST_DB=0`)
  or the first boot could not reach the database as root
  (`CIVICRM_DB_ROOT_PASSWORD`).
- `DB Error: already exists` on install: an earlier install failed halfway
  and left tables behind. Fix its cause, then start from an empty database.
- `Interface "…" not found` on every headless boot, or a suite that does
  not see new seed data: stale test database; `cktestreset`.
- Flaky results: another session uses the same stack.
- `ck` does not know `bisect`: it is older than the command. Pull the
  current `civikitchen-cli` image, or update the checkout behind
  `scaffold/ck`.
- `Class "CiviUnitTestCase" not found` with `tests` mounted into a
  released image: its `ckcoretest` predates the one that fetches
  `phpunit.xml.dist` and the seed SQL for a mounted `tests/`. Pull the
  current image, or use a git-built one (`standalone-master`,
  `standalone-beta`), which carries both.

## Completion

Name the image tag with its CiviCRM version and, for git-built images, the
core commit; the commands run; and that the stack was removed or why it
was kept.

A gap in this skill that cost time (a wrong command, a missing step, an
unnamed trap) is reported as an issue or fixed in a pull request on
civico-de/civicrm-skills, after the user's go.
