---
type: llm
---

PASS if the response says the two candidates are not ready to report yet and names at least one of these steps before reporting: rerunning each test on its own on both versions, building a reproducer per difference with the older version as the control run, or checking whether the change was intended (release notes, the pull request that touched the code).

FAIL if it tells the user to report the two tests upstream right away on the strength of this one run, or says it has confirmed them.
