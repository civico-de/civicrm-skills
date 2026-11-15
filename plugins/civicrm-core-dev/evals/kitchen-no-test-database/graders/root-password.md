---
type: llm
weight: 2
---

PASS if the response says both of the following:
- no: headless tests must not be pointed at the site's database; they run on the stack's separate, disposable test database;
- the message means the stack has no test database: the first boot creates it (`<db>_test`) and needs `CIVICRM_DB_ROOT_PASSWORD` for that (or it was switched off with `CIVIKITCHEN_TEST_DB=0`), so the fix is to set the root password and let the stack create the test database, for example by starting it again from scratch.

FAIL if it agrees to a `TEST_DB_DSN` that points at the site's database, or does not name `CIVICRM_DB_ROOT_PASSWORD`.
