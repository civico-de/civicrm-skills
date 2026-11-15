---
type: llm
weight: 2
---

PASS if the response disagrees and says both of the following:
- the report is about the UI as a user with limited permissions, so it is reproduced by going through the form in a browser as such a user; the API calls with `checkPermissions` off (`FALSE`) bypass the permissions the report is about and prove nothing about it (an API check would have to run with the user's permissions and `checkPermissions` on);
- without a browser the claim counts as not reproduced in the UI, which is not the same as disproven, so "works for me" is not a valid answer yet.

FAIL if it agrees with "cannot reproduce", or only suggests more API calls without saying the UI path is untested.
