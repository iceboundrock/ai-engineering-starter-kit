# Engineering Instructions

## Mission
Deliver the smallest correct, demonstrable solution to the actual task.
Treat these instructions as defaults; explicit task requirements and existing repository conventions take precedence.

## Start with evidence
- Read the task and inspect the relevant repository files, tests, and existing project instructions before proposing changes.
- Identify confirmed requirements, assumptions, non-goals, and acceptance criteria. Ask only about ambiguities that materially change the solution.
- Determine the actual build, run, and test commands from the repository. Do not invent commands or claim they succeeded before running them.
- Prefer the existing language, frameworks, dependencies, and architecture.

## Deliver in small steps
- Propose a minimal vertical slice that connects real input to meaningful output, then implement it first.
- Keep the application runnable. Work in reviewable changes; avoid unrelated refactors.
- Separate core domain logic from I/O and UI where doing so makes testing easier. Avoid speculative abstractions.
- Use AI to accelerate exploration and implementation, not to decide requirements or silently expand scope.
- If time is running short, simplify optional features before compromising correctness or the ability to demonstrate the result.

## Verify and report
- Run the smallest relevant test after each meaningful change; perform integration checks before declaring completion.
- Test important invalid inputs, boundary cases, and failure modes. Check invariants and units where relevant.
- Inspect the final diff; distinguish passing tests from untested assumptions.
- Never assert tests, builds, demos, or external actions succeeded unless their results were actually observed.
- Report: implemented behavior, actual test commands/results, how to run the demo, limitations, and next steps.

## Collaboration and safety
- Explain major decisions and trade-offs briefly; surface blockers promptly.
- Ask before adding dependencies, installing tools/plugins, altering permissions, changing external APIs, making destructive changes, or sending code/data to external services.
- Never expose credentials or private data. Do not upload the host's repository, prompts, outputs, or confidential inputs to a personal GitHub repository.
- Do not override existing team instructions or install third-party agents without permission.
