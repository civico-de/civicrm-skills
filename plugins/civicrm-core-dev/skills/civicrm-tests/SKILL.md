---
name: civicrm-tests
description: Write, modernize and review CiviCRM core PHPUnit tests in upstream's current style. Use when adding tests - choosing unit, headless, end-to-end or browser level, the base class, fixtures with createTestEntity, getTestForm, mail and validation assertions, strict assertions, cleanup; when writing the regression test for a bug fix ("write a test for this fix"), preparing a bug-fix PR, checking whether a fix is covered, or when a test passes but may not prove anything (red/green proof, controls); when moving tests from APIv3 to APIv4 (`callAPISuccess`, `civicrm_api3` → `createTestEntity`, `Civi\Api4`) and slicing that into upstream PRs, "Tests auf v4 umstellen", "Tests modernisieren", "easy tests".
---

# CiviCRM tests

The style upstream reviews against is [`AGENTS.md`](https://github.com/civicrm/civicrm-core/blob/master/AGENTS.md) in civicrm-core ("Writing
PHPUnit tests") and the ["Test style checklist"](https://docs.civicrm.org/dev/en/latest/testing/phpunit/#test-style-checklist) in civicrm-dev-docs
`docs/testing/phpunit.md`. Helpers live in `Civi/Test/` and
`tests/phpunit/CRMTraits/`; read the trait before using a helper, signatures
change between versions. This page holds the rules for every test, upstream's
and this repository's own (README, "Contributing"); the reference files
below add what is specific to a task.

## Level

| Behaviour | Level | Base |
|---|---|---|
| Pure logic, no database | unit | `PHPUnit\Framework\TestCase` |
| API, BAO, hooks, permissions, managed entities, forms | headless | `CiviUnitTestCase`. In a core extension under `ext/`: `HeadlessInterface` + `TransactionalInterface`, plus `HookInterface` to receive hooks |
| Running site: HTTP, routing, sessions, cron, real mail delivery | end-to-end | `EndToEndInterface` (`CiviEndToEndTestCase`), `@group e2e` |
| Rendering, Afform, SearchKit displays, anything decided in JavaScript | browser | `Civi\Test\MinkBase` (Mink driving Chrome over DevTools at `CHROME_HOST`:`CHROME_PORT`, default `localhost:9222`), in `tests/phpunit/E2E/` or an extension's `tests/phpunit/E2E/`, `@group e2e` |
| Angular directives and services in isolation | JavaScript unit | Karma + Jasmine, `tests/karma/unit/*Spec.js` |

Take the cheapest level at which the behaviour can still fail for the
reason you care about, and no cheaper. Regressions decided in JavaScript are
invisible to PHP tests. Transactions do not isolate end-to-end tests: the
site runs outside them. `HookInterface` and subscriber listeners run only in
the test's own process, so they never fire in end-to-end tests. Suites are
selected by group: a `HeadlessInterface` class declares `@group headless`,
an `EndToEndInterface` class `@group e2e`, never both; the listener only
warns. Slow or browser tests that should not run on every push go into an
opt-in group, as the project already does, rather than being left out.

## Fixtures

- `createTestEntity($entity, $values, $identifier = 'default')` creates
  through APIv4, returns the row and stores the id under
  `$this->ids[$entity][$identifier]` for
  `getTestEntityID($entity, $identifier)`. A test that creates more than one
  record of an entity gives each its own identifier, also in a loop, or the
  ids overwrite each other; core's `AGENTS.md` requires this.
- Scenario helpers build the bigger fixtures: `individualCreate()`,
  `organizationCreate()`, `createLoggedInUser()` (ContactTestTrait),
  `eventCreatePaid()` / `eventCreateUnpaid()` (EventTestTrait),
  `contributionPageCreatePaid()` (ContributionPageTestTrait),
  `createMailing()` (MailingTestTrait),
  `createCustomGroupWithFieldOfType()` (CustomDataTrait). Give them string
  identifiers: `individualCreate([...], 'donor')`.
- In APIv4 test classes, `createTestRecord()` fills required fields and
  `saveTestRecords()` creates several records of one entity at once
  (Api4TestTrait); both register the records. `Api4TestBase` deletes them in
  `tearDown()`; a class that only uses the trait calls `deleteTestRecords()`
  in its own `tearDown()`. A transaction replaces that only when nothing in
  the test commits it (DDL does).
- No hard-coded ids, no reliance on install data or its order, or on the
  state another test left. Take ids from the created row; reach seeded rows
  by name (`'financial_type_id:name' => 'Donation'`) or through
  `LookupHelperTrait` (`getFinancialTypeID('Donation')`,
  `getLocationTypeID('Home')`). No fallbacks in fixtures: never guess an
  id or option value; a missing one fails the setup.
- In APIv4 joins, a reverse join (one-to-many) multiplies rows; count or
  group before asserting.
- Option suffixes follow what the column stores. A field that stores an id
  from an option list (`*_id`) takes the name, never the bare number:
  `'activity_type_id:name' => 'Meeting'`. A field that stores the word
  itself has no suffix: `'status' => 'Added'`,
  `'entity_table' => 'civicrm_group'`, `'contact_type' => 'Individual'`.
  A field declares which suffixes it has: Address `country_id` and
  `state_province_id` have `:label` and `:abbr`, no `:name`; use `:label`
  only there. A name passed to an `*_id` field without the suffix is cast
  to a number and 0 is stored, with no error. On write, an unknown name
  throws `Invalid value for <field>:name` from 6.22 on; before that it
  silently became NULL on an optional field, so on older branches assert
  the stored id.
- APIv4 goes through the imported entity class by its short name with the
  permission flag written out: `Contact::get(FALSE)`, not `civicrm_api4()`
  and not a bare `::get()`.
- APIv3 appears only where v3 is the subject, as `callApiV3Success()`.
- Prefer the public path. Private and protected members go through
  [`Civi\Test\Invasive`](https://docs.civicrm.org/dev/en/latest/testing/phpunit/#civitestinvasive), never `ReflectionMethod` or `ReflectionProperty`:
  `Invasive::call([$obj, 'method'], [$arg])`, `Invasive::get([$obj, 'prop'])`,
  `Invasive::set([$obj, 'prop'], $value)`; `['Class', 'member']` for statics.

## Forms, mail, validation

```php
$form = $this->getTestForm('CRM_Contribute_Form_Contribution', $submitted, ['cid' => $contactID]);
$form->processForm();
$this->assertMailSentTo(['jo@example.org']);
$this->assertMailSentContainingStrings(['Total: $100.00']);
```

`processForm()` runs the real build, validate and submit flow;
`addSubsequentForm()` chains multi-step flows. FormTrait also gives
`assertValidationError()`, `assertMailSentCount()`,
`assertTemplateVariable()` and `assertPrematureExit()`. Do not call a form's
static or public methods directly, do not call `postProcess()` and do not
use `getFormObject()`.

## Assertions

- Expected value first. `assertSame` for scalars and arrays alike, with the
  expected value in the type the code really returns (`'1'` for v3, `1` for
  v4). Never cast the actual value, never fall back to `assertEquals`. SQL
  counts are cast: `(int) CRM_Core_DAO::singleValueQuery(...)`.
- On arrays `assertSame` also compares key order and element types: fix an
  unstable order in the query (`addOrderBy`) or sort before comparing.
- Under `@dataProvider versionThreeAndFour`, wrap the expected v4 value in
  `$this->apiValue()`: `assertSame($this->apiValue(TRUE), $result['is_active'])`.
- `assertTrue`/`assertFalse`/`assertNull`/`assertCount` instead of comparing
  against literals or `count()`.
- Assert the outcome a user or caller sees: the stored row, the mail, the
  API result, the rendered value.
- One behaviour per test method, named for the behaviour, with `: void`.
  Data providers for the same behaviour over several inputs.
- A negated or swallowed check asserts nothing (an assertion
  inside a `catch`, a check on a path the test never reaches). Watch every
  new test fail once, by breaking the code or the expectation, before
  trusting it.
- Never make a test pass by loosening or deleting an assertion, bending
  the expectation to the broken behaviour, or adding sleeps or retries;
  fix the defect. Dropping a test as out of scope counts the same: fix it
  at the layer you control or replace it with a correct assertion of the
  same behaviour. An assertion that is itself wrong (it pins an
  implementation detail, or behaviour that changed on purpose) is replaced
  by one of the intended behaviour, with the reason in the pull request.
- A check that passes without checking is worse than none. For code that
  warns or flags, pin "a healthy record produces no warning" as a test.
- Permission tests set the acting user's permissions explicitly
  (`setPermissions([...])`) and call the API with `checkPermissions` on,
  and say so; fixture calls switch it off. `checkPermissions` defaults to
  `TRUE` in v4.

## Cleanup

- `useTransaction()` (`CiviUnitTestCase`) or `TransactionalInterface`
  (`ext/`) for plain data.
- DDL commits implicitly: creating a custom group or field, or installing
  an extension, inside a transactional test commits everything written
  before it. On current master the custom groups and fields themselves are
  removed after a transactional test (`Civi\Test\CustomDataCleanup`); the
  other rows committed with them are not. Create custom data first, or
  make the test non-transactional and clean up in `tearDown()` with
  `quickCleanup([...], TRUE)`; `TRUE` drops the custom groups and their
  tables. `quickCleanup()` fails in a class that called `useTransaction()`.
  Put extension installs in `setUpHeadless()`.
- Always call `parent::setUp()` and `parent::tearDown()`. Cleanup belongs
  in `tearDown()`, not at the end of a test method, where a failure skips it.
- Restore shared state (settings, locale, logged-in user, default mail
  account, message templates) to the value read before the change.
- `Civi\Test::headless()->…->apply()` rebuilds the test database only when
  the signature of its steps changes (`Civi/Test/CiviEnvBuilder.php`). A
  `callback()` without a signature argument signs with
  `md5(var_export($callback, 1))` (`CiviEnvBuilder/CallbackStep.php`), and
  every closure exports to the same text: editing a closure's body does not
  rebuild. Pass a signature (`callback($fn, 'v2')`) and change it with the
  body. `apply(TRUE)` reruns the configured steps whatever the signature;
  `useOnce()` gives the builder a random signature, so its first `apply()`
  reruns them. Either resets the database only as far as those steps do.
  Never edit the database by hand.
- `CIVICRM_SLOPPY_TEST` names the test that leaked state into the next one.

## Task references

- `references/regression-test.md` — read when the test belongs to a bug
  fix: the red/green proof, controls, shape, the boundary it must cross,
  handing it over.
- `references/modernize.md` — read before converting existing tests from
  APIv3 to APIv4 or to the style above: triage, conversion patterns, what
  to leave alone, slicing for upstream.

Running the tests: `ckcoretest` in the `civikitchen` skill; reproducing a
suspected bug first: `civicrm-verify-bug`.

## Completion

Name the level chosen and why, the classes run with their counts, what you
watched fail, and which meaningful behaviour is still untested. Comments
describe the code as it stands, not the approaches tried along the way.

A gap in this skill that cost time (a wrong command, a missing step, an
unnamed trap) is reported as an issue or fixed in a pull request on
civico-de/civicrm-skills, after the user's go.
