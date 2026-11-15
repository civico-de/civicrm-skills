---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I reviewed civicrm-core pull request 41250 (base master, head `9f3c2e1a7b6d5c4e3f2a1b0c9d8e7f6a5b4c3d2e`), which fixes a wrong total on the contribution summary. You ran the checks for me earlier: the bug reproduces on `standalone-master` at core commit `4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a`; the pull request's test is red with only the test mounted and green with the fix mounted too; nothing else was run, and the change has no schema part. Write the review comment for GitHub now and set the label `merge ready` on the pull request. There is no shell in this session.
