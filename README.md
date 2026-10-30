# Timeboxed AI Engineering Kit — v2

Lightweight, tool-agnostic instructions for a five-hour collaborative design/build/demo task. Inspired by the *verifiable goals and remove blockers* insights from the user-supplied interview transcript, **not** by its long-running multi-agent or compute-intensive setup.

## Files
- `SOP-01-clarify.md`: human/team conversation for the first 20 minutes.
- `AGENTS.md`: persistent, compact engineering and evidence rules.
- `CLAUDE.md`: Claude Code bridge to `AGENTS.md`.
- `prompts/01-scope.md`: convert the task into P0, acceptance oracles, and a first slice.
- `prompts/02-build.md`: implement → execute → measure → fix, with a stall breaker.
- `prompts/03-verify.md`: skeptical coverage and evidence review.
- `prompts/04-demo.md`: truthful, reproducible demonstration.

## Recommended operating sequence
1. Read the problem and any existing repository instructions; follow the host team's tool/data policy.
2. Use SOP 01 to agree the goal, success oracles, MVP, environment, and demo format.
3. Use `01-scope` briefly to check for overlooked requirements, **not** to replace team discussion.
4. Use `02-build` on the next small slice. Verify each increment. If stuck for two non-improving attempts, stop and diagnose.
5. Use `03-verify` periodically and before demo. Make independent expectations explicit.
6. Use `04-demo` only with tested behavior, with honest caveats.

## Examples of independent checks
- Data transformer: specified input/output pair; error cases; property checks.
- Battery simulator: hand-calculated 2-step example, SOC/energy constraints, comparable baseline initial/final state.
- API: contract example, valid/invalid response checks, idempotency under retry where required.
- Interactive UI: user flow actually exercised, critical state transitions, fallback CLI output.

## Interview-specific constraints
- Do **not** install third-party skills, extra services, or transmit confidential material without permission.
- No indefinite `/goal` loops, large agent fleets, or infrastructure provisioning for a five-hour exercise.
- Prefer a verified end-to-end P0 over optimizations of weak or self-referential metrics.
- If verification cannot be automated, explain the residual human judgment needed.

## Fast human unblock question
> What is the biggest blocker to the next *verified* runnable milestone? Show the evidence, smallest experiment, and what you need from me.

## Five-hour example checkpoints (adapt to the actual demo time)
- ~60 min: representative input produces observable output.
- ~135 min: core P0 behavior implemented and tested.
- ~205 min: end-to-end demo exists.
- Final ~45 min: freeze scope, review evidence, rehearse demo, present.
