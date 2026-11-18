---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

On my civicrm-core pull request one Jenkins job, CiviCRM-Test build 254622, shows "no result" and has no test report. The console says only `DB Error: unknown error` in the middle of an extension suite, then `phpunit-xml-cleanup` fails with "Document is empty". Where do I find the actual database error, and what in it would tell me whether my change caused it? There is no shell in this session.
