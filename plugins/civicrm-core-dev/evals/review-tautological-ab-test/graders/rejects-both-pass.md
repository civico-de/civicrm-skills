---
type: llm
weight: 2
---

PASS if the response says all of the following:
- a test that passes on both A (base) and B (PR) proves nothing about the fix; proof-of-fix requires the test to fail (red) on base A and pass (green) on PR B;
- do not mark proof-of-fix green or recommend `merge ready` until the test reproduces the failure on base A and passes on PR B;
- suggests checking why it passed on base (e.g., the test does not cover the bug or base A was also running PR code) and checking base tests against B (base-test regression guard) / `ck surface --diff` where relevant.

FAIL if it accepts the A/B run as valid proof-of-fix or agrees with recommending `merge ready`.
