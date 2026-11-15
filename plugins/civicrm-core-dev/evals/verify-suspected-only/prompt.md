---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Reading `CRM/Contact/BAO/GroupContactCache.php` in my checkout I am sure there is a bug: removing a contact from a parent group does not invalidate the cache of its smart child groups, so the contact keeps showing up in the child for hours. I have not run anything. Draft the bug report for CiviCRM so I can file it today. There is no shell in this session.
