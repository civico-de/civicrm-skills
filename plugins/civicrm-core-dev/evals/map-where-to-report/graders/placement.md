---
type: llm
weight: 2
---

PASS if the response says all of the following:
- civicrm-core has no GitHub issues; issues for core go to lab.civicrm.org, project `dev/core` (it may add that an issue is optional when a fix with a test is ready);
- the pull request goes to GitHub against `master`, as one pull request;
- no pull requests against the stable branch on one's own, and the release candidate branch only takes critical, recent regressions, which this is not; maintainers backport or ask for a port.

FAIL if it recommends a GitHub issue on civicrm-core, or opening pull requests against all three branches.
