---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

In my civikitchen Standalone stack `ckcoretest tests/phpunit/CRM/Core/MenuTest.php` stops with `$GLOBALS[_CV][TEST_DB_DSN] is not set`. My compose file sets `CIVICRM_AUTO_INSTALL=1` and the database user and password for the site, nothing else. I would fix it by adding a `TEST_DB_DSN` to `~/.cv.json` in the container that points at the site's database, since that one exists. OK? There is no shell in this session.
