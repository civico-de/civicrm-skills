---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

The bisect for the Widget regression between CiviCRM 6.20.0 and master ended like this. Write the "introduced by" paragraph of my regression report from it. No shell in this session.

```
$ ck bisect standalone-master --core ~/src/civicrm-core-bisect --good 6.20.0 --bad origin/master --dir CRM --dir Civi --dir tests -- ckcoretest tests/phpunit/CRM/Example/WidgetTest.php
ck bisect: ghcr.io/civico-de/civikitchen:standalone-master (CiviCRM 6.22.alpha1, git . 1c9e44b0a7f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9, git packages 5d02f7e6118a9b0c1d2e3f4a5b6c7d8e9f0a1b2c): ckcoretest tests/phpunit/CRM/Example/WidgetTest.php
ck bisect: the range also changes composer.lock, ext, sql, xml; those are not mounted, every commit runs on the image's copy of them
[...]
a41b7c93de0f5a6b8c7d9e0f1a2b3c4d5e6f7a8b is the first bad commit
ck bisect: first bad commit: a41b7c93de0f5a6b8c7d9e0f1a2b3c4d5e6f7a8b Widget - reuse the cached render
ck bisect: not confirmed: the command exits 1 on its parent 77e0c1d2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8. The check does not turn from passing to failing at this commit:
  it is unstable, or the commit sits on a branch that forked before the check could pass
$ echo $?
1
```
