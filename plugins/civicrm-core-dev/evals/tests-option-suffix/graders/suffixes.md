---
type: llm
weight: 2
---

PASS if the response says both of the following:
- a name given to an `*_id` field without an option suffix is cast to a number, so 0 is stored without an error, and the call should read `'activity_type_id:name' => 'Meeting'`;
- Address `country_id` has no `:name` suffix (it has `:label` and `:abbr`), so the call should read `'country_id:label' => 'Germany'` or use `:abbr`.

FAIL if it proposes a hard-coded numeric id as the fix for either field, or keeps `country_id:name`.
