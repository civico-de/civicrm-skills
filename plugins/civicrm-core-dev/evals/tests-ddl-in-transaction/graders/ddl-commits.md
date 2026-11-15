---
type: llm
weight: 2
---

PASS if the response says that creating a custom group or field is DDL, which commits implicitly, so the two contacts created before it are committed and survive the rollback, and gives one of these fixes: create the custom data before the other rows, or make the test non-transactional and clean up in `tearDown()` with `quickCleanup([...], TRUE)`.

FAIL if it names another cause, proposes deleting the contacts at the end of the test method as the fix, or proposes `quickCleanup()` while keeping `useTransaction()`.
