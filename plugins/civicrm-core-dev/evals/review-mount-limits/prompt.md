---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I am reviewing civicrm-core pull request 41300 against master. It adds a column `is_archived` to `civicrm_campaign` (the schema definition plus an upgrade step) and raises a composer dependency. I mounted the pull request's `CRM`, `Civi`, `schema` and `ext` directories into a `standalone-master` stack with `ck run ... -- ckcoretest tests/phpunit/CRM/Campaign`, and everything is green. I would write "tested locally, works, upgrade is fine" in my review. Anything wrong with that?
