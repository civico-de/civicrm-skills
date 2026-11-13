# The regression test for a fix

A regression test is a test that fails on the code before the fix, for the
reason the bug report gives, and passes after it. Everything below serves
that sentence. Verify the bug first (`civicrm-verify-bug`); the reproducer
written there becomes this test. The style rules are in `SKILL.md`.

## The proof

1. Run the new test on the unfixed code. It fails on the assertion that
   states the bug. A failure in setup, a fatal error or a missing class is
   not the red run.
2. Apply the fix. The test passes.
3. Show both outputs, freshly run. "It failed earlier" is not evidence.

A test that was already green before the fix pins behaviour; it may be worth
keeping, but label it as a pinning test and never present it as proof of the
fix.

## Shape

- **One control beside the reproducer.** The nearest healthy input, asserted
  to still work. It guards against a test that is red for the wrong reason
  and against a fix that breaks the neighbour.
- **Cross the boundary the bug lives at.** A bug in a form's submit handler
  is tested through the form (`getTestForm(...)->processForm()`), a bug in
  an API action through the API with the caller's permissions, a bug that
  only shows in the browser through a browser test. Calling the fixed
  function directly proves the function, not the fix. The level is the
  cheapest at which the bug still reproduces (`SKILL.md`, Level).
- **Assert the user-visible outcome** with a literal expected value. Do not
  assert on the implementation detail the fix happened to change.
- **Smallest fixture that still fails.** Remove setup until the red run turns
  green, then put the last piece back.
- **Sit next to the existing tests** for that class and follow their
  structure, helpers and naming (`testSubmitWithZeroAmount`, not
  `testBug1234`). Reference the issue in the docblock.
- **Justify cleanup by running without it.** A `tearDown()` or cleanup call
  that changes nothing when removed is noise; one that is needed says which
  state it removes.
- **Deterministic.** No sleeps, no retries, no dependence on the order of
  install data or on ids. Fix the clock where time matters.

## Before blaming the fix or the test

- Run the same subset on the unchanged code. A failure that was there before
  is pre-existing: report it with the test name, do not fold it into the fix.
- When CI is red, check whether the target branch itself is red before
  touching the test; rebase onto the repaired branch first.
- Never make it green by loosening the assertion, widening the expected
  value or adding a wait. If the strict assertion fails, that is the next
  finding.

## Handing it over

- The reviewer must be able to see the failure: deliver the test so that it
  can run without the fix, as a separate first commit or a test-only patch
  that fails on the target branch.
- One fix, one test, as short as both can be. No unrelated reformatting.
- In the description: what was red, what is green, which base. Do not argue
  with test counts or coverage numbers.
- Say whether it is a regression and name the introducing commit and
  version, or say "unknown".

## Loop

Run the changed class and its neighbours, not the suite. The full matrix is
CI's job; local green is a statement about the classes you ran on the base
you ran them on, and is reported as exactly that.
