---
type: llm
weight: 2
---

PASS if the response says both of the following:
- not enough: the test has to be seen failing without the fix, because a test that passes without the fix proves nothing;
- how: run the same test on the image matching the base with only the pull request's `tests` directory mounted (no `CRM` mount), expecting red, next to the green run with the fix mounted too, and it gives the `ck run … --mount …/tests:/var/www/html/core/tests -- ckcoretest …` command for it.

FAIL if it accepts the green run as validation, or only asks for more test classes to be run with the fix mounted.
