# Handling a civireview review on your own pull request

civireview (github.com/civico-de/civireview) posts an automated review when
someone comments `@civireview` on a pull request. Its docs explain each part:
`docs/reading-a-review.md` (verdict, score, finding tags) and `docs/running.md`
(comment flags).

## Triggering

- `@civireview` reviews the changes since its last review; `@civireview --full`
  the whole pull request. Other flags are in `docs/running.md`.
- A comment is public: post it on the user's go. After a force-push that fixed
  findings, a new `@civireview` shows whether they are gone.
- `@civireview <question>` inside a finding's thread answers there instead of
  starting a new review. Use it when a finding is unclear, not to argue.

## Reading it

- The verdict covers technical checks only. `Ready` means no finding passed the
  gate and no check failed; it says nothing about whether the change is wanted
  or the approach is right. Never cite it as approval.
- `NOT VERIFIED` and "Internal … runner error" rows mean the check did not run,
  not that the pull request failed. Do not chase them in the code.
- Findings come in three places: inline threads (Action Items), "Findings
  (Out-of-Diff / Summary)", and `NEEDS_QUESTION` notes in the folded
  walkthrough. All three count.

## Handling each finding

1. Check it against the pull request's current head, not the commit it was
   written for: a force-push may already have fixed it. `PROVEN` was shown in a
   run; `CONFIRMED` was only read in code, so reproduce it when that is cheap.
2. Real: fix it, with a test when the finding is about behaviour, and push.
   Not real or not worth it: give it a second, adversarial look first, then
   write down why.
3. Answer every inline thread in one line and resolve it:
   `Fixed in <sha>.` or `Not changed: <reason>.` A fixed-and-verified reply
   needs no separate go; a `Not changed` reason is drafted for the user's go.
4. Summary-only findings and `NEEDS_QUESTION` notes have no thread: answer them
   in the next pull request comment, one bullet each, naming civireview as the
   source (`also noted by civireview`).

Human reviewers lean on these findings when the diff is large. An unanswered
thread reads as an open defect, even when the fix is already pushed.
