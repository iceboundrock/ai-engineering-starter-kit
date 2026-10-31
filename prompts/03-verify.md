# 03 — Verify Against Independent Evidence

**Scope file:** {{SCOPE_FILE}}
**Review target:** {{COMMIT}} (a commit or range)

Review the target skeptically; you did not write this code. Read the problem statement the scope file points to, its acceptance checks, the diff, the tests, and the observed run outputs. The builder's reports, commit messages, and the statuses in the scope file are claims to check, not evidence. Do not infer correctness merely because tests pass.

**Read-only:** do not edit, create, or delete files in the repository. You may run existing checks, and throwaway scripts kept outside the repository.

Prioritize:
1. P0 coverage, and whether each acceptance check has an **independent oracle**.
2. Hand-calculated/reference cases, domain invariants, invalid inputs, boundary conditions, units, and time/state semantics.
3. Failure handling, retries, concurrency, security, and data exposure where relevant.
4. End-to-end behavior and demo startup; inspect UI/visual output only if you can actually observe it.
5. Unnecessary changes or risks that threaten delivery.

Return:
- BLOCKER / IMPORTANT / OPTIONAL findings, each with file location, reproducible evidence, and a minimal fix direction.
- A coverage matrix: requirement → oracle → observed result → PASS / FAIL / NOT VERIFIED.
- The checks you actually ran, and what remains uncertain.
- The top blocker, if any, and the lowest-risk next action.

Expectations derived from the current implementation are not independent evidence; never present them as proof.
