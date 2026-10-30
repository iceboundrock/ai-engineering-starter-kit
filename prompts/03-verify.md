# 03 — Verify Against Independent Evidence

Act as a skeptical reviewer. Read the **original problem**, the agreed acceptance checks, the diff, tests, and observed run outputs. Do not infer correctness merely because tests pass or another agent says the result is correct.

Prioritize:
1. P0 requirement coverage and whether each acceptance check has an **independent source of expected behavior**.
2. Hand-calculated/reference cases, domain invariants, invalid inputs, boundary conditions, units, and time/state semantics.
3. Failure handling, retries, concurrency, security, and data exposure where relevant.
4. End-to-end functionality and demo startup; inspect UI/visual output only if you truly have tools/access to observe it.
5. Unnecessary changes or risks that threaten delivery.

Run the smallest useful checks where allowed. Return:
- BLOCKER / IMPORTANT / OPTIONAL findings with file location, reproducible evidence and minimal fixes.
- A coverage matrix: requirement → oracle → observed result → PASS / FAIL / NOT VERIFIED.
- What checks were actually executed and what remains uncertain.
- The top blocker, if any, and the lowest-risk next action.

Do not write tests with expectations copied solely from the current implementation and call them independent proof. Do not rewrite unrelated modules or silently change agreed behavior.
