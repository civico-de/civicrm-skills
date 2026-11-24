---
type: llm
weight: 2
---

PASS if the response says to check the finding against the current head, then answer in the finding's thread with one short line naming the commit (e.g. "Fixed in <sha>.") and resolve the thread; and does not treat the NOT VERIFIED runner-error row as a defect of the pull request to fix in code.

FAIL if it proposes a new top-level comment instead of a reply in the thread, leaves the thread unresolved, or presents the Ready verdict as approval that the change is wanted.
