---
type: llm
weight: 2
---

PASS if the response says both of the following:
- a console of a page or two usually points at the environment and not the change: a network service was unavailable, the branch is too old to apply (rebase), or the test node ran out of disk, memory or inodes; the console is read for which of these it shows, and the failure is explained before it is rerun, instead of bisecting the change;
- the rerun is the public comment `test this please` on the pull request (for a whitelisted contributor), drafted and posted only after the user's go.

FAIL if it recommends bisecting the change, or gives pushing an empty commit or closing and reopening the pull request as the way to rerun without naming the comment.
