---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

`ck bisect` ended with exit status 0 and these lines:

```
ck bisect: first bad commit: 5c1d9e07ab3344f0a9d1c2b3e4f5a6b7c8d9e0f1 Merge pull request #41877 from example/participant-status-order
ck bisect: confirmed: the command passes on 0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d and 7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b and fails on 5c1d9e07ab3344f0a9d1c2b3e4f5a6b7c8d9e0f1
```

To find the pull request I ran

```
git log --merges --ancestry-path 5c1d9e07ab..origin/master --reverse --format='%h %s' | grep -m1 'Merge pull request'
```

and it prints `e2f40b6c18 Merge pull request #41875 from example/afform-draft-display`. Which pull request do I name as the one that introduced the regression?
