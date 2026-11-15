---
type: llm
weight: 2
---

PASS if the response gives commands that rerun each of the two tests on its own (a `--filter` or an equivalent single-test selection) on both versions, standalone-6.20 and standalone-beta, in fresh stacks (`ck run` or `ck ab`), and says the run on the older version is the control: a test that fails alone there as well is not a regression between the two.

FAIL if it only repeats the whole suite, reruns on one version only, or tells the user to report or bisect straight away.
