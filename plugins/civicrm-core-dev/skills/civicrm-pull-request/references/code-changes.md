# Rules for the change itself

Read before writing code for core, and when reviewing a change of the kind
below. Each section names its source in civicrm-dev-docs or civicrm-core;
read the source when a case is not covered here.

## Core's AGENTS.md

Read civicrm-core's `AGENTS.md` on the base branch before changing code; it
is short and changes. The rules most often broken:

- A new Angular file loads only after it is listed in the module's
  `*.ang.php` and caches are flushed (`cv flush`).
- JavaScript: arrow functions, no new lodash (`_.`), APIv4 only
  (`crmApi4`, `CRM.api4()`), no new `crmApi` / `CRM.api3` calls.
- Extension code, including the core extensions under `ext/`, uses
  `E::ts()`, so the extension's own translations are searched first.
- `ts()` takes a string literal; a value known only at runtime goes
  through `_ts()`. Placeholders (`%1`) instead of concatenation, `plural`
  and `count` instead of branching on a number, no `ts()` on data.
- Karma: `npm test` never exits; one run is
  `node node_modules/karma/bin/karma start --single-run`, against an
  installed site with `cv` on `PATH`. civikitchen does not cover karma.

## Code style (lint)

Jenkins runs the code-style checks first; when they fail, the remaining
tests are skipped (`tools/jenkins.md`, `testing/continuous-integration.md`).
Lint before pushing.

- The checker is `civilint`, a wrapper around PHP_CodeSniffer with the
  civicrm/coder ruleset and jshint (`tools/civilint.md`), in
  civicrm-buildkit's `bin/`: `git diff --name-only <upstream>/<base> |
  civilint -` checks the branch.
- No full buildkit is needed: `pr-commands.yml` clones civicrm-buildkit,
  keeps only `drupal/coder` and `squizlabs/php_codesniffer` in its
  `composer.json`, runs `composer install` and `npm install jshint`, then
  calls `bin/civilint`. The same steps work locally (PHP, composer, npm).
  civikitchen offers no core lint: its images dropped phpcs and coder.
- `/lint` (or `/lintroll`) as a comment on an open pull request rebases
  it onto the current base, runs `civilint --fix` on each commit, amends
  it and force-pushes the branch; a conflict fails the command
  (`.github/workflows/pr-commands.yml`). It is a public comment that
  rewrites history: only after the user's go, and no substitute for
  linting before the first push. Fetch before working on the branch
  again.

## Secure coding

The Developer Guide's security pages, one line each:

- `security/inputs`: never trust `GET` parameters, validate them; input
  encoding and purification when saving.
- `security/outputs`: escaping by context: Smarty/HTML, attributes,
  JavaScript, Angular templates, SQL (`executeQuery` parameters,
  `CRM_Utils_Type::escape`, `CRM_Utils_SQL_Select`), shell commands.
- `security/permissions`: defining and enforcing permissions in APIv4,
  APIv3, routes, navigation and QuickForm.
- `security/access`: ACLs, what they restrict beyond permissions, and
  checking them in code.
- `security/csrf`: when CSRF protection is needed, `X-Requested-With` for
  REST, QuickForm's protection.

A vulnerability found on the way leaves the public path
(`civicrm-pull-request`, "Pull request or issue").

## Schema and upgrade steps

Source: current core code; copy the newest file, e.g.
`CRM/Upgrade/Incremental/php/SixTwentyTwo.php`, and
`CRM/Upgrade/Incremental/php/Template.php`. Review criteria:
`standards/review.md` (`rg-upgrades`).

- One class per minor series, named with English number words
  (`CRM_Upgrade_Incremental_php_SixTwentyTwo` for 6.22, resolved through
  `CRM_Utils_EnglishNumber` in `CRM/Upgrade/Form.php`), extending
  `CRM_Upgrade_Incremental_Base`.
- A release's steps are `upgrade_X_Y_Z($rev)` and/or
  `CRM/Upgrade/Incremental/sql/X.Y.Z.mysql.tpl`, usually with the
  pre-release id: `upgrade_6_22_alpha1`, `6.22.alpha1.mysql.tpl`.
  `getRevisionSequence()` in `Incremental/Base.php` collects both (methods
  matching `^upgrade_([0-9_alphabeta]+)$`); a `.tpl` alone runs
  automatically.
- Which version: `xml/version.xml` on the base branch (`version_no`, e.g.
  `6.22.alpha1` on master). Put the step into that version's method and
  file; after a rebase across a release cut, read it again and move the
  step if the version moved on. A method with a `.tpl` beside it must
  queue it as its first task:
  `$this->addTask(ts('Upgrade DB to %1: SQL', [1 => $rev]), 'runSql', $rev);`
  (`runSql` calls `processSQL()`, which throws when the file is missing).
- Every step is a queued task: `addTask($title, '<callback>', ...$args)`
  names a static method of the class or of `CRM_Upgrade_Incremental_Base`,
  each run in its own request. Base provides `alterSchemaField`,
  `addColumn`, `dropColumn`, `addIndex`, `dropIndex` and more.
  `addColumn`, `dropColumn`, `addIndex` (through
  `CRM_Core_BAO_SchemaHandler::createIndexes()`) and `dropIndex` check the
  current schema first, so a site that already applied a backport survives. Read the
  signatures in `Base.php`.
- PHP tasks over Smarty SQL. Prefer SQL and those helpers to APIs, BAOs
  and metadata, which can break in later upgrade environments; a narrow
  call is used where core has one, e.g. `Civi::settings()->set()` in
  `SixTwentyTwo::setMultipleGroupParents()`. Populating a large
  table (`civicrm_contact`, `civicrm_activity`, …) in one task can time
  out; split it.
- Strings in SQL files: a localizable field (`<localizable>` in its
  schema) takes `{localize}` around the column and value; other visible
  text takes `{ts escape="sql"}`; domain ids as `{$domainID}`
  (`CRM/Upgrade/Incremental/sql/README.txt`).
- A fresh install and an upgraded site must end with the same schema.
  Admins who must act after the upgrade get a post-upgrade message
  (`setPostUpgradeMessage()`) or a system check (`core/release-process.md`).
- Message templates or seeded option values: regenerate
  `sql/civicrm_generated.mysql` (`civicrm-pull-request`).
- The Developer Guide's `framework/upgrade.md` lags here: it says
  `upgrade_X_Y_Z()` must call `$upgrade->processSQL($rev)`, names
  `CRM_Upgrade_Form::addColumn()` and requires an SQL file per release,
  even an empty one. Core today queues `runSql` and needs no empty file.
- Not verifiable locally with civikitchen: it has no upgrade-test path
  (its `docs/core-development.md`), and a mount or `ck demo` carries
  files, not a database upgrade. Upstream that is `civibuild upgrade-test` in buildkit,
  and Jenkins runs `civicrm-upgrade-test` on the pull request. Say "upgrade
  path not verified locally" and read that CI result.

## Deprecation

Source: `standards/index.md`, "Deprecation Warnings". Mark deprecated code
with `CRM_Core_Error::deprecatedWarning($message)`, or
`CRM_Core_Error::deprecatedFunctionWarning($newMethod)` when a function
has a replacement. Removal is a candidate only after at least six months
of releases with the warning. Removing a function without that period, or
changing a hook or API contract, is not a refactoring (`r-tech`).

## Dependencies

Source: `core/dependencies.md`.

- New libraries go into `composer.json`; adding code to
  `civicrm-packages` is deprecated.
- JS and CSS libraries are declared under `extra.download` and land in
  `bower_components/`.
- Patches to a dependency go under `extra.patches` with an absolute URL to
  immutable content (raw gist, upstream PR diff); prefer fixing it
  upstream when upstream is active.
- A dependency change needs an image built from the branch; a mounted
  checkout does not install it (`civikitchen`).
