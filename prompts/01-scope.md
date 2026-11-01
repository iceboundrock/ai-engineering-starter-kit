# 01 — Scope and Define an Oracle

**Scope file:** {{SCOPE_FILE}}

We have a time-limited design/build/demo task. Read the scope file, the problem statement it points to, and the relevant repository files and instructions. **Do not write code, and do not change any file until I confirm.** You may run read-only commands, such as the existing tests, to check the environment; say what you ran.

You propose; I decide. Return a brief (≤ 450 words):
1. Confirmed facts versus assumptions, and any gap or conflict between the problem statement and the scope file.
2. Up to three high-impact questions for the team; omit questions already answered.
3. For each P0 requirement: an observable acceptance check and a plausible independent oracle (supplied expected output, hand-calculated reference, trusted baseline, invariant/property, or live end-to-end result). Mark missing expected answers; do not invent them.
4. Each open choice that affects P0, correctness, or the demo: two or three options, their trade-off, and your recommendation.
5. The smallest first vertical slice and the executable check for it.
6. P1/P2 scope, constraints, and a fallback if time runs short.
7. Environment readiness: run/test commands confirmed versus unknown, and any access you need to observe results.

Avoid premature framework selection, speculative architecture, and feature expansion. Then stop and wait. When I confirm, update only the scope file: the agreed P0, acceptance checks, oracles, and first slice, and each decision with who made it.
