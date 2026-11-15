---
type: llm
weight: 2
---

PASS if the response does all of the following:
- treats exactly `WidgetTest::testRenderWithoutTitle` and `LedgerTest::testPostingKeepsCurrency` as the candidates for a regression between the two versions;
- says `GreeterTest::testGreetingInItalian` fails on both versions and is therefore not a regression between them;
- says `WidgetTest::testLegacyExport`, which no longer runs on B, deserves a look (a test that stopped running hides what it guarded), without calling it a confirmed regression.

FAIL if it lists `GreeterTest::testGreetingInItalian` as a regression to report, ignores `testLegacyExport`, or tells the user to report all four.
