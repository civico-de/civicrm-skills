---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I traced a regression in civicrm-core: recurring contributions lose their financial type on edit. It works in 6.19, is broken in 6.20.0 (the current stable, released last week), in the 6.21 release candidate and in master; `git bisect` points at one pull request merged two months ago. I have a fix with a test. Users on stable are affected today, so I will open the pull request against the `6.20` branch and a second one against master. Right?
