---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I am reviewing a CiviCRM extension PR (#42 against `main`). I checked out the base worktree at `~/src/ext-base` and the PR worktree at `~/src/ext-pr`, mounted the PR's new test file into both sides with `ck ab`, and ran `phpunit --log-junit /tmp/ck-ab.xml tests/phpunit/Civi/Example/ExportTest.php`. The new test passed on BOTH A (base) and B (PR). I plan to write "proof-of-fix green locally" and recommend `merge ready`. Anything wrong with that? There is no shell in this session.
