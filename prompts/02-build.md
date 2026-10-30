# 02 — Build With a Bounded Feedback Loop

Use the agreed P0, success oracle, and actual repository conventions. Work on **only the next small vertical slice**.

For each iteration:
1. State the expected observable behavior and the command/fixture/check that can assess it.
2. Implement the smallest change that moves that behavior forward.
3. **Execute** the relevant check and inspect its actual output (do not merely describe a hypothetical run).
4. Compare with the agreed reference output/invariant. Report PASS / FAIL / NOT VERIFIED with evidence.
5. If failing, make one evidence-based fix and rerun. Keep the app runnable.

**Unblock protocol:** If two consecutive attempts have not improved the same failure, stop patching. Report: observed failure, best-supported cause, smallest diagnostic experiment, missing tool/data/permission if any, and what you need from me. Ask “What is the largest current blocker to a verified runnable slice?”

No unapproved dependencies, outside services, broad refactors, parallel agent fleets, or indefinite loops. Prefer P0 completion and demo readiness over optional features.

At the end of this slice, give: changed files, actual commands/results, remaining risks, next recommended slice, and an explicit scope-cut suggestion if time is tight.
