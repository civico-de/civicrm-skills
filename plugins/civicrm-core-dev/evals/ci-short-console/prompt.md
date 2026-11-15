---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

On my civicrm-core pull request one Jenkins job failed. With my API token I read its console: it is barely a page long and stops during setup, before any test ran. My change only touches a help text. I would start bisecting my change to find what broke the job. Sensible? And how do I get the job run again? There is no shell in this session.
