---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Our extension's suite against the release candidate gave the output below. What do I run next to find out whether the two are real? `ck` is /home/dev/src/civikitchen/scaffold/ck and the extension is checked out at /home/dev/src/org.example.myext. No shell in this session: give me the commands.

```
$ ck ab standalone-6.20 standalone-beta --mount /home/dev/src/org.example.myext:/var/www/html/ext/org.example.myext -- sh -c 'cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml'
ck ab: A (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: B (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: A ghcr.io/civico-de/civikitchen:standalone-6.20 (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): exit 0
ck ab: B ghcr.io/civico-de/civikitchen:standalone-beta (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): exit 1
ck ab: 212 tests on A, 212 on B, 0 only on B
ck ab: pass on A, fail on B: 2
  Civi\Example\WidgetTest::testRenderWithoutTitle
  Civi\Example\LedgerTest::testPostingKeepsCurrency
ck ab: fail on A, pass on B: 0
ck ab: fail on both: 0
ck ab: ran on A, skipped or missing on B: 0
```
