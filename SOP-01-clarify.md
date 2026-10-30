# SOP 01 — Clarify Goal, Success, Constraints (20 minutes)

**Purpose:** Align with the engineering team on a small solution that is possible to implement, independently validate, and demonstrate. Do not attempt to eliminate every ambiguity.

## 0–3 min — Restate the problem
- Who is the user and what business outcome matters?
- What inputs and observable outputs are required?
- Say: “My understanding is that we're solving [problem] for [user] by producing [output]. Is that right?”

## 3–7 min — Establish a success oracle
- Ask: “Could we agree on one concrete example of correct input and expected output?”
- Identify one **reference case** (provided result, hand calculation, trusted baseline), one **critical invariant**, and one **end-to-end observable behavior**.
- Ask what the most important failure/invalid case is.
- If no reliable oracle exists, explicitly label the outcome as *exploratory* or *qualitative*; do not invent a correctness claim.

## 7–11 min — Clarify constraints and executable environment
- Which domain/time/unit/resource constraints change the implementation?
- Is there an existing repo, test suite, sample data or benchmark?
- What exact commands can run the app and tests? Can the AI agent run and observe them?
- What installs, external services, AI plugins, or data transfers are allowed?
- When will the final demo happen? Is CLI/API acceptable or is interactive UI essential?

## 11–15 min — Propose P0/P1/P2
- P0: smallest end-to-end behavior that proves the requested value.
- P1: useful enhancements only after P0 is verified.
- P2: explicitly deferred features.
- Highlight an assumption only if it could invalidate P0, correctness, or demo.

## 15–18 min — Plan the first feedback loop
- Choose first representative input, expected output and quick check.
- Describe the smallest runnable vertical slice.
- Define a fallback if there is no progress by the first checkpoint.
- Preserve a meaningful window for independent verification and a live demo.

## 18–20 min — Confirm team alignment
Say: “I plan to deliver [P0], using [assumptions]. We'll consider it successful if [observable checks]. I'll start with [first runnable slice], defer [P1/P2], and demonstrate [format]. Does that match your expectations?”

## Exit checklist
- [ ] Business goal, P0 scope and demo format are clear
- [ ] At least one trustworthy check or clearly acknowledged verification gap
- [ ] Critical invariant, sample input and expected output identified
- [ ] Actual tool/test/run path and permissions understood
- [ ] Risks, assumptions and deferred scope recorded
- [ ] Team alignment obtained on the consequential choices

**Rule:** If an unanswered question could change the correctness of P0, ask now. Otherwise make a documented, reversible assumption and build.
