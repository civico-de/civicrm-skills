---
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Hand this one test to the regression-triage agent and give me the block it returns, unchanged and without anything added.

TEST: Civi\Example\SearchTest::testLegacyFilter
A: standalone-6.20
B: standalone-beta
RUN: sh -c 'cd ext/org.example.myext && phpunit --filter testLegacyFilter tests/phpunit/Civi/Example/SearchTest.php'
CK: ./ck
ID: legacyfilter
OPTIONS: --mount /home/dev/src/org.example.myext:/var/www/html/ext/org.example.myext
