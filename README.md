# AI Engineering Starter Kit

Prompt templates and a playbook for getting an AI-assisted software project off the ground quickly, with engineering discipline.

## Purpose

Coding agents make code cheap to produce, and unverified claims about that code just as cheap. This kit keeps the decisions with the people who own the problem and makes the agent back every claim with evidence. It targets the first hours of a project, when the goal is still being clarified and there is little time to lose:

- **Problem first:** clarify the goal with the people who own it, agree on an independent oracle, cut a P0, and make trade-offs explicit.
- **Agents with limits:** give the agent context and boundaries, require it to run checks rather than describe them, guard against its typical failures (claimed-but-unrun checks, edited expectations, scope creep, loops), and stop it when it stalls.

Claude Code plans and builds; Codex reviews, so the review comes from a different model with a separate context. The two share state only through `SCOPE.md`. Nothing needs to be installed beyond the agents themselves, so the kit works in a repository and environment you don't own. Every prompt is short enough for a pairing partner to read over your shoulder, and every rule in it has a reason you can explain.

`SOP.md` is the main line; each prompt in `prompts/` is used at one step of it. `prompts/exec/` holds the templates for ongoing work on GitHub (issue → PR → review → fix → merge); the short prompts condense ideas from them.

Not goals: letting an agent finish a project unattended, maximizing automation (agent fleets, long unattended loops), or storing project-specific problems, code, or data.

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

## Working in a host environment
- Do **not** install third-party skills, extra services, or transmit confidential material without permission.
- No indefinite loops, large agent fleets, or infrastructure provisioning in a timeboxed session.
- Prefer a verified end-to-end P0 over optimizations of weak or self-referential metrics.
- If verification cannot be automated, explain the residual human judgment needed.

## Fast human unblock question
> What is the biggest blocker to the next *verified* runnable milestone? Show the evidence, smallest experiment, and what you need from me.

## Five-hour example checkpoints (adapt to the actual demo time)
- ~60 min: representative input produces observable output.
- ~135 min: core P0 behavior implemented and tested.
- ~205 min: end-to-end demo exists.
- Final ~45 min: freeze scope, review evidence, rehearse demo, present.
