---
type: llm
weight: 2
---

PASS if the response says both of the following:
- a mount applies files only: there is no schema upgrade and no `composer install`, so the new column is not in the installed database and the raised dependency is not in `vendor/`; the green run does not cover them;
- "upgrade is fine" is not supported by this run: the upgrade path (and the schema change) is to be written down as not verified locally, with the upgrade test in CI as the place to read it, or an image built from the change as the way to verify the schema.

FAIL if it accepts the statement as it is, or only asks for more test classes to be run on the same mounted stack.
