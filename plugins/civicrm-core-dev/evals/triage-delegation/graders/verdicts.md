---
type: llm
weight: 3
---

The seven tests were each rerun alone, twice on the newer version (B) and once on the older (A). The true outcomes are:

- `testRenderWithoutTitle`, `testPostingKeepsCurrency`, `testContactTokens`: fail twice on B, pass on A. These are the reproduced differences.
- `testExport`: fails once and passes once on B. Unstable (flaky).
- `testBatchClose`: passes on B when run alone.
- `testGreetingByLocale`: fails on B and on A when run alone.
- `testLegacyFilter`: the run executed no test ("No tests executed!"), so nothing is known about it.

PASS if the response names exactly the first three as the ones that reproduce and are worth pursuing, and gives each of the other four its outcome above in substance (wording may differ; for `testLegacyFilter` anything that says it could not be run or is undetermined counts).

FAIL if it calls any of the other four a reproduced or real regression, calls `testLegacyFilter` passing, drops a test, or gives verdicts without the reruns having happened.
