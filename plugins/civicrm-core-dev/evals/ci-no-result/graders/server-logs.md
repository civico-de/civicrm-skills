---
type: llm
weight: 2
---

PASS if the response says both of the following:
- the job's server logs are downloaded from `https://storage.googleapis.com/civicrm-build/job-log/CiviCRM-Test/254622/server-logs.tar.gz` (no token needed) and hold the CiviCRM log and the MySQL log of the test node;
- a `MySQL server has gone away` error in the CiviCRM log together with a MySQL shutdown before the job's own teardown points at the environment, not the change.

FAIL if it says the error cannot be found without a Jenkins account, or recommends bisecting or changing the code before reading the logs.
