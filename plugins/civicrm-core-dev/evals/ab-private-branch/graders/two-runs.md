---
type: llm
weight: 2
---

PASS if the response says the plan does not compare anything, because `ck ab` puts the same mounts into both stacks, so A also runs the branch's code; and proposes instead one `ck run` per side on the 6.20 image, each mounting the changed directories (such as `CRM`, `Civi`, `ext/<name>`) from its own work tree of the respective ref, with JUnit written to a directory mounted from the host and compared per test afterwards.

FAIL if it accepts the `ck ab` command as a valid comparison, or proposes building an image of the branch with `ck make build` from civicrm-core.
