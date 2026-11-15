# Modernize existing tests

The test keeps its subject and gets stricter, never looser. The style rules
are in `SKILL.md`; this page adds what is specific to converting. Read
`AGENTS.md`, the docs checklist and three recently merged conversion
commits (`git log --grep='apiv4' -- tests/phpunit`) before the first edit,
because the conventions move.

Contents: Triage each v3 call · Conversion patterns · Leave alone · What
the conversion surfaces · Verify · Slicing for upstream · Completion

## Triage each v3 call

Inventory with `git grep -nE "callAPI|civicrm_api3?\(" -- <dir>` and sort
every call into one bucket before editing:

1. **Fixture or read-back** — convert.
2. **v3 is the subject** (`api/v3/**`, a v3-only action, a test of v3
   permissions or v3 output shape) — keep, and write it as
   `callApiV3Success()`, which pins version 3 regardless of the class default.
3. **v3 does work v4 does not** — keep. `Mailing.create` schedules, attaches
   groups and creates jobs; `Contact.get` runs `CRM_Contact_BAO_Query`;
   `ContactType.create` munges the name. Converting these changes the test
   subject or the fixture.
4. **No v4 counterpart** — keep. Check `Civi/Api4/` and `ext/*/Civi/Api4/`
   rather than guessing:
   MailingRecipients, MembershipPayment, ParticipantPayment, SystemLog,
   ReportTemplate, Attachment, `Job.process_mailing`, `Extension.install`,
   `System.flush`, `getoptions`, `getstatistics`.

Renamed entities: Case → CiviCase, Exception → DedupeException,
Rule → DedupeRule, RuleGroup → DedupeRuleGroup.

"Easy" files are those with a handful of bucket-1 calls. A file whose calls
are mostly buckets 2–4 is not worth a partial conversion.

## Conversion patterns

```php
$contact = $this->createTestEntity('Contact', ['contact_type' => 'Individual', 'first_name' => 'Jo']);
$this->createTestEntity('Mapping', ['name' => 'Ducks', 'mapping_type_id:name' => 'Import Contact']);
$row = Contribution::get(FALSE)->addWhere('id', '=', $id)->execute()->single();
MailSettings::update(FALSE)->addValue('domain', 'example.org')->addWhere('id', '>', 0)->execute();
```

- `single()` replaces `getsingle`, `->selectRowCount()->execute()->count()` replaces `getcount`,
  `->addSelect('field')->execute()->single()['field']` replaces `getvalue`.
  `->column('field')` returns an array of values, one per row.
- A v3 call that passed a name to an `*_id` field needs the `:name` suffix
  in v4 (see the option suffix rule in `SKILL.md`).
- Serialized fields (`form_values`, `contact_sub_type`, `parents`,
  `group_type`) are arrays and are matched with `CONTAINS`. Group
  `group_type` takes `'group_type:name' => ['Mailing List']`; the v3 form
  `['2' => 1]` stores wrong values in v4.
- Custom values are written through the owning entity:
  `->addValue('group_name.field_name', $value)`. A custom group needs
  `extends` plus, for subtypes, `extends_entity_column_value`.
- Results are keyed 0..n, not by id: add `->indexBy('id')` where the test
  indexes by id, and replace `$result['values']`, `$result['id']`,
  `$result['count']`.
- `checkPermissions` defaults to `TRUE` in v4: fixture calls pass `FALSE`.
- A v3 call that stays returns strings: `assertSame('1', ...)`.
- Cleanup: keep what the class has, transactional or `quickCleanup()`. A
  converted fixture that the v3 helper used to clean up now needs its
  table listed.

## Leave alone

Core's own test commits still add both forms of each pair below, so
upstream has no rule. Write the better form on every line you write or
convert; rewrite an untouched line only where the weaker form can hide a
failure, and name that in the PR.

- **Booleans:** `TRUE`/`FALSE`, the type APIv4 returns. `1`/`0` works; an
  existing line is not changed for it.
- **`single()` or `first()`:** `single()` where exactly one row is the
  claim; it throws on none or several. `first()` returns `NULL` on none and
  hides a second row, so it fits only with an explicit order or limit.
  A `first()` that means "the one row" can hide a failure: change it.
- **Exceptions:** `expectException()` plus `expectExceptionMessage()` when
  the throw ends the test. `try`/`catch` when state is asserted afterwards,
  and then with `$this->fail()` after the call. A `try`/`catch` without
  `fail()` passes when nothing is thrown: add it.
- **`addValue()` or `setValues()`:** `setValues([...])` for a whole
  record, `addValue()` for one or two fields; neither is rewritten into the
  other. `setValues()` replaces every value set before it, so it comes
  first in a chain.
- **`@throws` on test methods:** carries no information; do not add it,
  do not strip it in a conversion.
- Existing comments and existing v4 calls that work stay as they are.

What upstream does converge on beyond `AGENTS.md` is in `SKILL.md`
(`assertCount()`, `: void`, string identifiers, `processForm()`,
`setPermissions()`). Re-measure with
`git log -p --since=<a year ago> -- tests` when in doubt: count added
against removed lines per form, leaving out your own commits.

## What the conversion surfaces

Removing v3 calls lowers the assertion count (the helper asserted
`is_error`); that is expected and not a loosened test. Everything else is a
finding, not something to fit:

- A tightened assertion fails, a test turns out never to have run, or an
  assertion checks the wrong variable: fix the test in the same change when
  the intent is unambiguous, and name it in the PR.
- v4 behaves differently from v3 in a way that looks wrong: leave that call
  on v3, reproduce on current master in isolation, and report it separately.
  Never bend the expectation to the new behaviour.

## Verify

`php -l`, then run every changed class, not the directory
(`ckcoretest tests/phpunit/CRM/Foo/BarTest.php`, see `civicrm-verify-bug`).
Compare tests/assertions/failures with a run of the unchanged file: a class
that failed before must be reported as pre-existing, with the test name.
When the local core is older than the branch base, say which classes could
not be run; only upstream CI verifies those. Check per-job results there.
If the style job is the only failure, fix it locally; a `/lint` comment
rewrites and force-pushes the branch, so draft it and post only after the
user's go (`civicrm-pull-request`, "After opening").

## Slicing for upstream

One PR per directory or component, only test files, no production code, no
unrelated reformatting. Twelve small files in one PR are fine; one large
form test deserves its own. Title names the directory
("Switch CRM/Contact tests with few api calls to apiv4"). The body lists what
stays on v3 and why, and which classes were not run locally. Core's PR
template and its AI rules apply.

## Completion

Report per file: calls converted, calls left on v3 with their bucket,
test fixes beyond the conversion, findings to report separately, and the
before/after test counts.
