---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

In my civicrm-core checkout I have a reproducer test (a new, untracked file), my fix as uncommitted edits in `CRM/Core/Menu.php`, and unrelated half-finished edits under `Civi/`. The checkout's `CRM`, `Civi` and `tests` directories are mounted into a running `standalone-master` stack. I need the red run without the fix and the green run with it. What is the cleanest way to switch the fix off and on? There is no shell in this session: give me the commands in order.
