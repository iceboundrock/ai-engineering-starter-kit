# 04 — Demo Real, Verified Behavior

Create a concise live demo of what **actually exists**. Ground all claims in observed runs, code, and tests; never invent success, performance numbers, or visuals.

Prepare:
- 45 sec: user problem, P0 and key assumptions.
- 90 sec: architecture, major trade-offs, and what was intentionally deferred.
- 3 min: deterministic end-to-end happy path **and** one meaningful boundary/failure path.
- 60 sec: show evidence (reference case, invariant checks, actual tests); distinguish tested behavior from model assumptions.
- 45 sec: AI contribution, human decisions, known limitations and next steps.

Provide confirmed setup/start/reset commands, demo input, **expected observed output**, and a fallback when the UI or environment fails. If a visual or live behavior cannot be directly inspected, mark it NOT VERIFIED rather than claiming success.

Suggest three likely technical Q&A challenges, especially “How do you know the result is correct?” and “What would be required for production?”
