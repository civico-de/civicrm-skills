---
type: llm
weight: 2
---

PASS if the response says both of the following:
- the status's `target_url`, read from the commit status of the head SHA, is the public batch page on test.civicrm.org; fetched with `curl` it lists the failed jobs (suite and build type) with their counts, and the task pages below it give the Jenkins job and build number;
- the names of the failed tests are not on these public pages and Jenkins itself refuses anonymous reads, so without an account or API token the result is the failed suites with their counts, and the test names need a test.civicrm.org account.

FAIL if it presents commands that are supposed to return the failed test names without an account (an anonymous Jenkins `testReport`, `gh run view --log-failed` and the like), or says the test results are in GitHub's check runs.
