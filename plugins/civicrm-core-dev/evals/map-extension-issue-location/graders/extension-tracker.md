---
type: llm
weight: 2
---

PASS if the response says all of the following:
- not `dev/core`: the issue belongs in the extension's own project;
- how to find it: the extension's `info.xml` names its repository; most extensions are on lab.civicrm.org in the group `extensions`, many others on GitHub;
- search that project's open and closed issues first, and comment on an existing one instead of opening a duplicate.

FAIL if it sends the issue to `dev/core`, or names a place without saying how to find the extension's repository.
