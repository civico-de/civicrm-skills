---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

A user reports that merging two contacts fails on Drupal 10 only. I want to check with civikitchen whether it depends on the CMS. Plan: `ck ab drupal10 wordpress -- ckcoretest tests/phpunit/CRM/Dedupe/MergerTest.php` to compare the two, and if they differ, `ck bisect drupal10 ...` to find the commit. Good plan? There is no shell in this session.
