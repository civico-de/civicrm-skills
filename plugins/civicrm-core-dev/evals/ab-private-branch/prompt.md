---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

A private branch `example-fixes` (not public, cloned at /home/dev/src/core-private) sits on top of the 6.20.0 release. Before it ships I want to know whether it breaks anything that worked on 6.20.0 in the Widget component. My plan: `ck ab standalone-6.20 standalone-6.20 --mount /home/dev/src/core-private/CRM:/var/www/html/core/CRM -- ckcoretest --log-junit /tmp/ck-ab.xml tests/phpunit/CRM/Widget`. `ck` is /home/dev/src/civikitchen/scaffold/ck. No shell in this session: tell me whether the plan works and give me the commands.
