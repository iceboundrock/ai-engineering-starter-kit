# 04 — Demo Real, Verified Behavior

**Scope file:** {{SCOPE_FILE}}

Prepare a concise live demo of what actually exists. Ground every claim in observed runs, code, and tests; never invent success, performance numbers, or visuals. Scope is frozen: do not change application code. If you find a demo-blocking bug, stop and report it.

Fit the demo to the format and time in the scope file, scaling these segments:
- 45 sec: user problem, P0, and key assumptions.
- 90 sec: architecture, major trade-offs, and what was intentionally deferred.
- 3 min: a deterministic end-to-end happy path and one meaningful boundary/failure path.
- 60 sec: evidence (reference case, invariant checks, actual tests); separate tested behavior from untested assumptions.
- 45 sec: what the agents contributed versus what humans decided (from the scope file's decisions), known limitations, and next steps.

Run the setup, start, and reset commands and the demo path once from a clean state. If reaching a clean state would delete anything you did not create, ask first. Report each command with its actual output, the demo input, and a fallback if the UI or environment fails. Mark anything you could not directly observe as NOT VERIFIED.

Suggest three likely technical questions, including “How do you know the result is correct?” and “What would be required for production?”
