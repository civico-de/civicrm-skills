---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I ran our extension's suite against the CiviCRM release candidate and got the output below. Which of these do I report to CiviCRM as regressions, and what has to happen before I report anything? There is no shell in this session, so just tell me what you conclude from the output and what is still to do.

```
$ ck ab standalone-6.20 standalone-beta --mount "$PWD:/var/www/html/ext/org.example.myext" -- sh -c 'cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml'
ck ab: A (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: B (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: A ghcr.io/civico-de/civikitchen:standalone-6.20 (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): exit 1
ck ab: B ghcr.io/civico-de/civikitchen:standalone-beta (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): exit 1
ck ab: 212 tests on A, 211 on B, 0 only on B
ck ab: pass on A, fail on B: 2
  Civi\Example\WidgetTest::testRenderWithoutTitle
  Civi\Example\LedgerTest::testPostingKeepsCurrency
ck ab: fail on A, pass on B: 0
ck ab: fail on both: 1
  Civi\Example\GreeterTest::testGreetingInItalian
ck ab: ran on A, skipped or missing on B: 1
  Civi\Example\WidgetTest::testLegacyExport
```
