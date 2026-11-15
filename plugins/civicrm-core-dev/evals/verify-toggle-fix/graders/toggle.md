---
type: llm
weight: 2
---

PASS if the response keeps the fix as a patch file or a commit of its own and toggles it with `git apply -R` / `git apply` (or uses two worktrees), runs the same test both times, and flushes CiviCRM's caches (`cv flush`) after switching.

FAIL if it uses `git stash` to toggle the fix (naming `git stash` as something to avoid is fine), or omits the cache flush.
