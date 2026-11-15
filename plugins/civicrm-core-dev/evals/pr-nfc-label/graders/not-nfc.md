---
type: llm
weight: 2
---

PASS if the response says the `(NFC)` prefix does not apply here, because altering an existing test and changing a docblock annotation are both excluded from NFC by the Developer Guide's definition, and proposes a title without that prefix.

FAIL if it accepts `(NFC)` for this change, or swaps it for `(REF)` without saying why NFC does not apply.
