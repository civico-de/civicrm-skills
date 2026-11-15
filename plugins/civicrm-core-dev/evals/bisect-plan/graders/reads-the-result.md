---
type: llm
---

PASS if the response explains how to read the outcome of `ck bisect`: a confirmed first bad commit (exit status 0) can be named, and any other outcome (not confirmed, the check not passing on the good end, only skipped commits) means no commit is named and the regression is reported as introduced between the two versions.

FAIL if it presents the commit `git bisect` prints as the cause without any condition, or proposes building one image per commit by hand as the first approach.
