---
type: llm
weight: 2
---

PASS if the test drives the form through `$this->getTestForm('CRM_Contribute_Form_Contribution', ...)` followed by `processForm()`, asserts the mail with a FormTrait or mail assertion such as `assertMailSentTo`, `assertMailSentContainingStrings` or `assertMailSentCount`, and the response says the test has to be seen failing without the fix before it counts.

FAIL if the test calls `postProcess()`, `getFormObject()`, `testSubmit()` or another method of the form directly, or creates the contribution through the API instead of submitting the form. Creating the contact through the API or a test helper and reading the contribution back through the API for an assertion are fine.
