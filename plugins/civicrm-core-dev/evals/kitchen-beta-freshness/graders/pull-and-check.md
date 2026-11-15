---
type: llm
weight: 2
---

PASS if the response says all of the following:
- `standalone-beta` is a moving tag, so the ten-day-old local image has to be pulled again before a run that matters;
- the version in the image has to be checked instead of assumed: shortly after a release the tag can still hold the branch that just shipped (6.20 here), not 6.21;
- the result is reported with the version the run actually had (with the commits the image prints or its digest), not with the tag name.

FAIL if it accepts the ten-day-old image, or takes for granted that the tag holds 6.21.
