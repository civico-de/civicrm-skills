---
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Hand this candidate finding to the `review-verifier` agent and return its verdict block unchanged.

CANDIDATE:
- ID: F1
- CLAIM: SQL injection and missing APIv4 permission enforcement in `CRM/Example/Lookup.php:9-17` because `$contactId` is interpolated directly into SQL and `civicrm_api4('Contact', 'get', ...)` skips permission checks.
- SEVERITY: critical
- LOCATION: CRM/Example/Lookup.php:9
PR: example/myext base main (abc1234) head fix/lookup (def5678)
