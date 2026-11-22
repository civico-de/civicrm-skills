---
type: llm
weight: 2
---

PASS if the output rejects the finding (`VERDICT: REJECTED`, `SEVERITY: none`) and its `EVIDENCE` cites `CRM/Example/Lookup.php`, noting both that `CRM_Core_DAO::executeQuery` uses the `%1` placeholder with `[1 => [$contactId, 'Integer']]` (and `int $contactId`) rather than string interpolation, and that `civicrm_api4('Contact', 'get', ...)` explicitly sets `'checkPermissions' => TRUE`.

FAIL if it confirms the vulnerability or invents facts not in `CRM/Example/Lookup.php`.
