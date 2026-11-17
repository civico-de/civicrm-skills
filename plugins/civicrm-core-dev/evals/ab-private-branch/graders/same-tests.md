---
type: llm
---

PASS if the response has both sides run the same tests, taken from 6.20.0 (core's `tests` and the extension `tests` directories mounted from the 6.20.0 work tree), so that a test the branch changed or removed cannot hide a regression; and says to check the diff for schema, composer or upgrade changes first, since a mount covers files only.

FAIL if each side runs its own tests without comment, or the schema/composer check is missing.
