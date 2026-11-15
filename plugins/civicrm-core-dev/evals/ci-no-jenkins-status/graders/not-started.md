---
type: llm
weight: 2
---

PASS if the response says no: the listed check is GitHub Actions housekeeping and holds no test results; core's tests run on Jenkins and report as the commit status `CiviCRM-PR`; without that status the tests have not started, which is normal for a new contributor until an administrator allows the run (`jenkins, ok to test` or adding to the whitelist). It must not let the user report passing tests.

FAIL if it agrees that CI is green, or explains the missing results in another way without naming the Jenkins status or the approval a new contributor needs.
