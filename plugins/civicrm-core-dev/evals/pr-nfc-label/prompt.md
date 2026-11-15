---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My pull request to civicrm-core changes no runtime code: in an existing test I rewrote two assertions from `assertEquals` to `assertSame` with corrected expected types, and I fixed a wrong `@param` type in a docblock of `CRM_Contribute_BAO_Contribution`. I will title it "(NFC) Contribution tests - strict assertions". Is the title right?
