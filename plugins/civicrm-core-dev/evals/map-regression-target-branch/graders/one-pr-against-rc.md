---
type: llm
weight: 2
---

PASS if the response says all of the following:
- no pull request against the stable branch (`6.20`) on one's own: maintainers do the backport to stable;
- this is a recent regression traced to a specific change, which is what the release candidate branch (`6.21`) takes, so the pull request goes against the release candidate branch (it may name master as the default the fix falls back to if maintainers do not see it as critical);
- one pull request against one branch to start with; copies for other branches follow when reviewers or release managers ask for them.

FAIL if it endorses the pull request against `6.20`, or opening pull requests against several branches from the start.
