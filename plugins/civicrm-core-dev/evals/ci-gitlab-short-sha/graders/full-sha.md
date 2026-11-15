---
type: llm
weight: 2
---

PASS if the response says no and names the cause: the `statuses` call with a shortened SHA returns `[]`, which only looks like "no CI"; the call has to be repeated with the full SHA of the head commit (it may add the merge request's pipelines as a second place to look) before anything is said to the maintainer.

FAIL if it agrees that the project has no CI, or explains the empty result only with permissions, login or a missing pipeline configuration without naming the shortened SHA.
