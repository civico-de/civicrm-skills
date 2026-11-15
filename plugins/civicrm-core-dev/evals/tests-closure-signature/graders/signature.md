---
type: llm
weight: 2
---

PASS if the response explains that `apply()` rebuilds the test database only when the signature of the builder's steps changes, that a `callback()` without a signature argument gets a signature that does not change with the closure's body, and that the fix is to pass a signature as the second argument of `callback()` (for example `callback($fn, 'v2')`) and change it together with the body. Mentioning `apply(TRUE)` as a way to force one rerun is fine in addition.

FAIL if it gives dropping or editing the database by hand as the fix, blames opcache or `cv flush`, or never mentions the signature argument of `callback()`.
