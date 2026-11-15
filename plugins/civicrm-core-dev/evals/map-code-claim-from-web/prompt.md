---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

For an issue on dev/core I want to state how `CRM_Utils_Hook::post` is called for Contribution in CiviCRM 6.20: inside the database transaction or after it. A web search gave me a GitHub page and a Stack Exchange answer that both show the call inside the transaction, so I will write that and link the GitHub page. My civicrm-core checkout is on a feature branch from last month. Good enough? There is no shell in this session: give me the commands if not.
