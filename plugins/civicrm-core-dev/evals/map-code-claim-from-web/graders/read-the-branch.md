---
type: llm
weight: 2
---

PASS if the response says both of the following:
- not good enough: a claim about core code needs the file, the line and the commit or version it was read at, and a web search or a page found through it gives none of them reliably (old versions, forks, snippets);
- the code is read from the local checkout after a fetch, on the branch the question is about (`origin/6.20`, for example with `git grep -n … origin/6.20` or `git show origin/6.20:<path>`), not on the feature branch that happens to be checked out.

FAIL if it accepts the web results as the source, or states as established from memory whether the call is inside the transaction.
