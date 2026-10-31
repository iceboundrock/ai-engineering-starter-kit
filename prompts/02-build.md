# 02 — Build With a Bounded Feedback Loop

**Scope file:** {{SCOPE_FILE}}
**Task:** {{TASK}} (the next slice, or the review findings I accepted)

Follow the scope file's P0, acceptance checks, and oracles, and the repository's conventions. Work only on the task above.

For each iteration:
1. State the expected observable behavior and the command, fixture, or check that assesses it.
2. Implement the smallest change that moves that behavior forward.
3. **Execute** the check and inspect its actual output; never describe a run you did not do.
4. Compare with the oracle. Report PASS / FAIL / NOT VERIFIED with evidence.
5. If failing, make one evidence-based fix and rerun. Keep the app runnable.

**Never change an agreed expected output, or skip, delete, or weaken a check, to get a PASS.** If you think the oracle is wrong, stop and tell me why.

**Unblock protocol:** if two consecutive attempts have not improved the same failure, stop patching. Report the observed failure, the best-supported cause, the smallest diagnostic experiment, any missing tool, data, or permission, and what you need from me.

No unapproved dependencies, outside services, broad refactors, parallel agent fleets, or indefinite loops. Prefer P0 completion and demo readiness over optional features. Do not commit; I review the diff first.

When done, update the slice's row and the acceptance-check statuses in the scope file. Then report: changed files, the commands you ran and their results, remaining risks, the next recommended slice, and a scope cut if time is tight. For review findings, give each one's status with evidence.
