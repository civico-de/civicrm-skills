---
type: llm
weight: 2
---

PASS if the response says both of the following:
- `ckcoretest`, `ck ab` and `ck bisect` (like `ck run`) work on the Standalone images only, so the plan does not run on `drupal10` or `wordpress`;
- on a CMS flavour the behaviour is reproduced through the site itself (a stack from that flavour's image), and Standalone is where the tools and the comparison run, which also shows whether the failure depends on the CMS at all.

FAIL if it accepts the plan, or only adjusts the arguments of `ck ab` or `ck bisect` for the CMS images.
