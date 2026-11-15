---
type: llm
weight: 2
---

PASS if the response treats the bug as suspected and not verified, and does not hand over a report that states the bug as an established fact ready to file: it either holds the report back or marks it clearly as unverified. It must name what is missing before reporting: a reproducer (a test or run) that fails in a clean instance on a named core version, with a control beside it that passes, and a search for an existing issue or pull request (or a check whether current master still has the code path).

FAIL if it delivers a finished bug report that asserts the behaviour as fact without those conditions.
