---
type: llm
---

PASS if the paragraph does all of the following:
- it does not attribute the regression to commit a41b7c93de (or to "Widget - reuse the cached render"); mentioning it as a candidate the bisect pointed at is fine when the text says it is not confirmed;
- it says why: the check also fails on the commit's parent, so the bisect did not confirm a turn from passing to failing there (an unstable check or a forked branch are the reasons the tool gives);
- it places the regression between the two ends of the range, 6.20.0 and master.

FAIL if it states or implies that a41b7c93de introduced the regression, names a pull request as the cause, or presents the commit as "likely" the cause without saying the confirmation failed.
