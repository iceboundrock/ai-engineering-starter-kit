# AI Engineering Starter Kit

Prompt templates and a playbook for getting an AI-assisted software project off the ground quickly, with engineering discipline.

## Purpose

Coding agents make code cheap to produce, and unverified claims about that code just as cheap. This kit keeps the decisions with the people who own the problem and makes the agent back every claim with evidence. It targets the first hours of a project, when the goal is still being clarified and there is little time to lose. Every template serves one or both of two goals:

- **Problem first:** clarify the goal with the people who own it, agree on an independent oracle, cut a P0, and make trade-offs explicit.
- **Agents with limits:** give the agent context and boundaries, require it to run checks rather than describe them, guard against its typical failures (claimed-but-unrun checks, edited expectations, scope creep, loops), and stop it when it stalls.

Claude Code plans and builds; Codex reviews, so the review comes from a different model with a separate context. The two share state only through `SCOPE.md`. Nothing needs to be installed beyond the agents themselves, so the kit works in a repository and environment you don't own. Every prompt is short enough for a pairing partner to read over your shoulder, and every rule in it has a reason you can explain.

`SOP.md` is the main line; each starter prompt in `prompts/` is used at one step of it. `prompts/exec/` holds the templates for ongoing work on GitHub (issue → PR → review → fix → merge); the starter prompts condense ideas from them.

Non-goals: letting an agent finish a project unattended, maximizing automation (agent fleets, long unattended loops), or storing project-specific problems, code, or data.

## Files
- `SOP.md`: the main line, from kickoff to demo. Start here.
- `prompts/01-scope.md` (Claude Code, plan mode): check the agreed goal for gaps and propose acceptance checks, oracles, and a first slice; the human decides.
- `prompts/02-build.md` (Claude Code): build one slice or fix accepted review findings (implement → execute → compare with the oracle), with a stall breaker.
- `prompts/03-verify.md` (Codex): read-only review of a commit against independent evidence.
- `prompts/04-demo.md` (Claude Code): a rehearsed demo of verified behavior, with scope frozen.
- `prompts/exec/`: templates for ongoing work on GitHub, from issue to merge. Its README explains the flow and the design decisions.
- `prompts/exec/fill.sh`: fills the exec templates' `{{...}}` placeholders from environment variables into the gitignored `prompts/exec/filled/`. Run it with `-h` to see each template's variables.
- `templates/SCOPE.template.md`: starting point for `SCOPE.md`, the shared state between the team and the agents.
- `templates/AGENTS.template.md`, `templates/CLAUDE.template.md`: optional engineering rules for the target repository, added only with the host team's permission.
- `AGENTS.md`, `CLAUDE.md`: instructions for agents maintaining this repository.

## Examples of independent checks
- Data transformer: specified input/output pair; error cases; property checks.
- Stateful simulation (for example, inventory or a ledger): hand-calculated two-step example, conservation invariants (nothing created or lost), initial/final state compared against a trusted baseline.
- API: contract example, valid/invalid response checks, idempotency under retry where required.
- Interactive UI: user flow actually exercised, critical state transitions, fallback CLI output.

## Working in a host environment
- Do **not** install third-party skills or extra services, or transmit confidential material, without permission.
- No indefinite loops, large agent fleets, or infrastructure provisioning in a timeboxed session.
- Prefer a verified end-to-end P0 over optimizations of weak or self-referential metrics.
- If verification cannot be automated, explain the residual human judgment needed.

## License

MIT; see `LICENSE`.
