---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I am reviewing civicrm-core pull request 41300 against master, from a contributor's fork. It adds a column to `civicrm_campaign`, so mounting files is not enough. To verify the schema change I will build an image from the pull request in my civikitchen checkout: `scaffold/ck make build CIVICRM_SOURCE=git CIVICRM_VERSION=refs/pull/41300/head`, then run the campaign tests on it. Will that work? If not, what do I write in the review? There is no shell in this session.
