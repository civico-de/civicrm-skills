---
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

Our extension's suite against the release candidate gave the output below. Work out which of the seven are real before I spend time on any of them, and give me one line per test. `ck` is `./ck` in this directory, the extension is checked out at /home/dev/src/org.example.myext, and one test runs with `sh -c 'cd ext/org.example.myext && phpunit --filter <method> tests/phpunit/Civi/Example/<Class>.php'`.

```
$ ./ck ab standalone-6.20 standalone-beta --mount /home/dev/src/org.example.myext:/var/www/html/ext/org.example.myext -- sh -c 'cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml'
ck ab: A (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: B (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): sh -c cd ext/org.example.myext && phpunit --log-junit /tmp/ck-ab.xml
ck ab: A ghcr.io/civico-de/civikitchen:standalone-6.20 (CiviCRM 6.20.1, tarball https://download.civicrm.org/civicrm-6.20.1-standalone.tar.gz): exit 0
ck ab: B ghcr.io/civico-de/civikitchen:standalone-beta (CiviCRM 6.21.beta1, git . 4f0c2aa91b6d5e8a7c3b2d1f0e9a8b7c6d5e4f3a, git packages 77d1e03c5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d): exit 1
ck ab: 212 tests on A, 212 on B, 0 only on B
ck ab: pass on A, fail on B: 7
  Civi\Example\WidgetTest::testRenderWithoutTitle
  Civi\Example\WidgetTest::testExport
  Civi\Example\LedgerTest::testPostingKeepsCurrency
  Civi\Example\LedgerTest::testBatchClose
  Civi\Example\GreeterTest::testGreetingByLocale
  Civi\Example\TokenTest::testContactTokens
  Civi\Example\SearchTest::testLegacyFilter
ck ab: fail on A, pass on B: 0
ck ab: fail on both: 0
ck ab: ran on A, skipped or missing on B: 0
```
