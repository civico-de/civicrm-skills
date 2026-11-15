---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

A contributor's pull request against civicrm-core master comes from the branch `campaign-archive` on their fork and changes PHP files under `CRM/Campaign` and `Civi/Api4` only. I want to run core's tests for it in civikitchen. My plan: in my civikitchen checkout, `scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=campaign-archive`, then run the tests on the image that gives me. Is that the way? There is no shell in this session: give me the commands.
