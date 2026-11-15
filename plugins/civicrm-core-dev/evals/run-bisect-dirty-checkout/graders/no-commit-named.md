---
type: llm
weight: 4
---

The bisect between 6.20.0 and master ended with "first bad commit: df3c620c… Widget - reuse the cached render" and then "not confirmed: the command exits 1 on its parent a3f3f4ea…", exit status 1. The tool gives two possible reasons: the check is unstable, or the commit sits on a branch that forked before the check could pass.

PASS if the response does all of the following:
- it does not attribute the regression to commit df3c620c (or to "Widget - reuse the cached render"); mentioning it as the candidate the bisect pointed at is fine when the text says it is not confirmed;
- it says why: the check also fails on the commit's parent, so the bisect did not confirm a turn from passing to failing there;
- it places the regression between the two ends of the range, 6.20.0 and master.

FAIL if it states or implies that df3c620c introduced the regression, presents the commit as "likely" the cause without saying the confirmation failed, or reports a result although no bisect ran to its end.
