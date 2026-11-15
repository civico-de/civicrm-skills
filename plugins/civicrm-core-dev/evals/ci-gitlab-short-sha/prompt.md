---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

For merge request 57 of the extension project `extensions/myext` on lab.civicrm.org I ran, logged in with glab: `glab api --hostname lab.civicrm.org 'projects/extensions%2Fmyext/repository/commits/3f2a1b9/statuses'` and got `[]`. So the project has no CI and the merge request is untested; I will tell the maintainer. Right? There is no shell in this session.
