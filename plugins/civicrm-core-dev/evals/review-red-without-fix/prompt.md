---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I am reviewing civicrm-core pull request 41280 against master: a fix in `CRM/Contribute/BAO/Contribution.php` with a new test in `tests/phpunit/CRM/Contribute/BAO/ContributionTest.php`. I have a checkout of the pull request under `~/src/pr-41280`. I mounted its `CRM` and `tests` directories into `standalone-master` with `ck run` and ran the new test: green. I will write "fix validated locally". Enough? There is no shell in this session: if something is missing, give me the commands.
