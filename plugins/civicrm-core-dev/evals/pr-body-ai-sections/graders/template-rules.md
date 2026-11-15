---
type: llm
weight: 2
---

PASS if all of the following hold:
- the body follows core's template sections (Overview, Before, After; Technical Details and Comments optional);
- the Overview is left for the human to write: empty or a placeholder, with a note that core requires a human-written overview. A suggestion of points the human could cover is fine only when it is clearly marked as not the overview text itself;
- the Before and After text written by the model is in Markdown blockquotes and short;
- the body, or the commit, declares that an AI agent was used and what it did.

FAIL if the model writes the Overview text itself as part of the body to paste, or the model-written sections are not blockquoted, or there is no declaration of the agent's use.
