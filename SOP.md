# SOP — From Kickoff to Demo

The main line for a timeboxed start. Each step says what to do, what to say to the team, which prompt to send to which agent, and when to move on. Times assume a five-hour session; scale them to the real schedule.

| Step | Time | Agent and prompt | What the team sees |
|---|---|---|---|
| 0. Before the session | Beforehand | — | — |
| 1. Clarify | 0–20 min | None | Agreed goal, oracle, and P0 |
| 2. Set up and scope | 20–35 min | Claude Code, plan mode: `01-scope` | `SCOPE.md`, with the decisions you made |
| 3. Build ⇄ verify | 35–255 min | Claude Code: `02-build`; Codex: `03-verify` | Evidence for each slice; `SCOPE.md` status |
| 4. Checkpoints | ~60, ~135, ~205 min | None | A one-minute status from `SCOPE.md` |
| 5. Freeze and demo | Final ~45 min | Codex: `03-verify`; Claude Code: `04-demo` | A rehearsed demo with real output |

## 0. Before the session

- Ask the host team which agents are available and under whose account. This SOP assumes Claude Code and Codex. Also confirm what may be installed, which external services may be used, and what data may leave the machine.
- Expect to work on the host's machine with nothing of your own installed. Copy prompts from this repository's raw files in a browser; don't sign in to personal accounts on the host's machine.
- Rehearse one slice end to end on a toy problem: plan mode in Claude Code, `03-verify` in Codex, the `git diff` check, and a commit.
- If Codex is unavailable, run `03-verify` in a fresh Claude Code session, and say so when presenting: the reviewer has a separate context but is the same model.

## 1. Clarify (0–20 min, no agent)

**Purpose:** Align with the engineering team on a small solution that is possible to implement, independently validate, and demonstrate. Do not attempt to eliminate every ambiguity.

### 0–3 min — Restate the problem
- Who is the user and what business outcome matters?
- What inputs and observable outputs are required?
- Say: “My understanding is that we're solving [problem] for [user] by producing [output]. Is that right?”

### 3–7 min — Establish a success oracle
- Ask: “Could we agree on one concrete example of correct input and expected output?”
- Identify one **reference case** (provided result, hand calculation, trusted baseline), one **critical invariant**, and one **end-to-end observable behavior**.
- Ask what the most important failure/invalid case is.
- If no reliable oracle exists, explicitly label the outcome as *exploratory* or *qualitative*; do not invent a correctness claim.

### 7–11 min — Clarify constraints and executable environment
- Which domain/time/unit/resource constraints change the implementation?
- Is there an existing repo, test suite, sample data or benchmark?
- What exact commands can run the app and tests? Can the AI agent run and observe them?
- What installs, external services, AI plugins, or data transfers are allowed?
- When will the final demo happen? Is CLI/API acceptable or is interactive UI essential?

### 11–15 min — Propose P0/P1/P2
- P0: smallest end-to-end behavior that proves the requested value.
- P1: useful enhancements only after P0 is verified.
- P2: explicitly deferred features.
- Highlight an assumption only if it could invalidate P0, correctness, or demo.

### 15–18 min — Plan the first feedback loop
- Choose first representative input, expected output and quick check.
- Describe the smallest runnable vertical slice.
- Define a fallback if there is no progress by the first checkpoint.
- Preserve a meaningful window for independent verification and a live demo.

### 18–20 min — Confirm team alignment
Say: “I plan to deliver [P0], using [assumptions]. We'll consider it successful if [observable checks]. I'll start with [first runnable slice], defer [P1/P2], and demonstrate [format]. Does that match your expectations?”

### Exit checklist
- [ ] Business goal, P0 scope and demo format are clear
- [ ] At least one trustworthy check or clearly acknowledged verification gap
- [ ] Critical invariant, sample input and expected output identified
- [ ] Actual tool/test/run path and permissions understood
- [ ] Risks, assumptions and deferred scope recorded
- [ ] Team alignment obtained on the consequential choices

**Rule:** If an unanswered question could change the correctness of P0, ask now. Otherwise make a documented, reversible assumption and build.

## 2. Set up and scope (20–35 min)

1. **Check the environment.** Confirm that both agents start in the repository and that the run and test commands work, with output the agents can observe. Ask whether you may add `SCOPE.md` to the repository, and `AGENTS.md` and `CLAUDE.md` from `templates/` if they would help. If not, keep `SCOPE.md` outside the repository or gitignored. Never overwrite the host's own agent instructions.
2. **Create `SCOPE.md`** from `templates/SCOPE.template.md` and fill in what step 1 agreed.
3. **Send `01-scope`** to Claude Code in plan mode, so it cannot edit files. Say: “I'll have the agent check what we agreed for gaps. It proposes; we decide.”
4. **Decide with the team.** Go through its questions and options aloud and choose. Then tell the agent what you chose; it updates `SCOPE.md` with the agreed scope and records each decision with who made it.

**Move on when** every P0 requirement in `SCOPE.md` has an acceptance check and an oracle, or a stated verification gap, and the first slice is chosen.

## 3. Build ⇄ verify (35–255 min)

One slice at a time:

1. **Say** which slice is next and how you will know it works.
2. **Build:** send `02-build` to Claude Code, with the slice as its task.
3. **Check the agent's work yourself.** Read the actual check output, not the agent's summary of it. Run `git diff --stat` and confirm that tests, fixtures, and expected outputs changed only where you agreed.
4. **Commit** the slice once its check passes, so the review targets a fixed commit and you can roll back.
5. **Verify:** send `03-verify` to Codex for that commit. Let the review finish before starting the next slice.
6. **Triage the findings with the team.** Decide what to fix now, defer, or reject, and send the accepted findings to Claude Code as the `02-build` task.
7. **Update `SCOPE.md`:** `02-build` fills in the slice and its check results; you add the commit, the review result, and the triage decisions.

**When stuck:** after two attempts that don't improve the same failure, stop the agent and ask: “What is the biggest blocker to the next verified runnable milestone? Show the evidence, the smallest experiment, and what you need from me.” Then remove the blocker yourself, change the approach, or cut scope.

## 4. Checkpoints (~60, ~135, ~205 min)

| Time | Target |
|---|---|
| ~60 min | Representative input produces observable output |
| ~135 min | Core P0 behavior implemented and tested |
| ~205 min | End-to-end demo path exists |

At each checkpoint, give a status from `SCOPE.md` in under a minute. Say: “Verified so far: [...]. Next: [...]. Biggest risk: [...]. I need you to decide: [...].” If a target is missed, propose a scope cut on the spot instead of pushing on.

## 5. Freeze and demo (final ~45 min)

1. **Freeze scope.** No new features. A demo-blocking bug still goes through build, your own check, and verify.
2. **Final verify:** send `03-verify` to Codex for the head commit.
3. **Prepare:** send `04-demo` to Claude Code. Run the demo once from a clean state and keep the real output.
4. **Present.** Answer “How do you know it's correct?” from the Acceptance checks table and its evidence. Use the Decisions table to separate what the agents did from what you decided.

## Throughout

- Agents propose and gather evidence; you decide, aloud. Every consequential decision goes into `SCOPE.md`.
- Before sending a prompt, say in one sentence why you are sending it and what you expect back.
- Accept no PASS without evidence you have seen yourself. Mark anything you could not observe as NOT VERIFIED.
