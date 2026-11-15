---
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

`./core` is my civicrm-core checkout. My fix is the uncommitted change in `CRM/Example/Widget.php`, and the reproducer is the new test `tests/phpunit/CRM/Example/WidgetTitleTest.php`. There is other unfinished work in that checkout which I still need.

Run the reproducer on `standalone-master` without the fix and with it, and show me what PHPUnit reported in each of the two runs. `./ck` is civikitchen's `ck` (`./ck run --help`). Leave the checkout exactly as it is now.
