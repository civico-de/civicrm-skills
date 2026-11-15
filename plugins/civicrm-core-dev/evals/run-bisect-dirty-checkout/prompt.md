---
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

`tests/phpunit/CRM/Example/WidgetTest.php` passes on CiviCRM 6.20.0 and fails on master. Find the commit that broke it with `./ck bisect` on `standalone-master`, then write the "introduced by" paragraph of my regression report from the result.

My civicrm-core checkout is `./core`; I have unfinished work in it that I still need. `./ck` is civikitchen's `ck` (`./ck bisect --help`).
