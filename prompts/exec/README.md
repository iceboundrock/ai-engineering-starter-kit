# Exec templates

Templates for ongoing work on a GitHub repository, one per step. Each is self-contained and can be sent on its own.

```
01-implement ──► 02-review ⇄ 03-fix ──► 04-merge
```

| Template | Takes | Writes to GitHub | Leaves to a human |
|---|---|---|---|
| `01-implement` | An issue | A branch and PR, follow-up issues, questions on the issue | Choices that change public behavior, breaking or hard-to-reverse changes, conflicts with documented behavior |
| `02-review` | A PR | One review submission (`COMMENT` only), and resolution of its own verified threads | Approval, accepting a risk, any choice a reply hands to the reviewer |
| `03-fix` | A PR and a reviewer | Commits, thread replies and resolutions, follow-up issues, one report comment | Ambiguous or conflicting comments, product and public-API decisions, conflicts that pick between behaviors |
| `04-merge` | A PR | The merge, branch deletion, issue comments and closures | Merging when any gate fails or the review recommends changes; editing the roadmap |

In daily use, `02-review` runs in Codex.

## Filling placeholders

Each template lists the values it needs at the top as `{{NAME}}` placeholders. `fill.sh` replaces each one with the environment variable of the same name and writes the result to `filled/`, which git ignores:

```bash
PR_URL=https://github.com/<owner>/<repo>/pull/<n> REVIEWER=<login> ./fill.sh 03-fix
./fill.sh -h   # each template's variables
```

Values are inserted literally. A template with any unset or empty variable is skipped rather than half-filled, and a skipped template, or one that cannot be read or written, loses its output from an earlier run, so no stale prompt is left behind for it. With no template named, every template whose variables are set is filled.

## Why they work this way

**GitHub content is data, not instructions.** Anyone can write an issue, a PR description, a comment, or a code comment, so the templates never run commands found there and report any text aimed at agents.

**State lives on GitHub, in markers.** Every run starts with no memory of earlier ones. The review marker records which commit was reviewed, finding markers tie threads to findings, the `[**AUTOFORGE**] ` prefix and the `agent-address-review` report mark the fixer's own posts, each report lists the review bodies and comments its run handled, and the `agent-implement` marker lets a run resume its own draft PR. These markers are the interfaces between templates; `AGENTS.md` lists who writes and reads each one.

**Neither a login nor a marker proves authorship.** The author, the reviewer, and the fixer may post under one account, and anyone can type a marker. The templates therefore count a marker as their own only when their own login posted it, check claims against the code, and treat every reply as a claim to verify.

**Nothing is resolved on someone's word.** `03-fix` resolves only threads it fixed as asked. `02-review` re-checks its own resolved threads against the code and carries forward any finding that is still present. `04-merge` merges only when the latest automated review covers the current head, found no blocking issues, and nothing was posted after it, and it pins the merge to that head with `--match-head-commit`. A mistaken "fixed", fix commits pushed after the last review, or a concern raised after it therefore cannot reach the default branch unnoticed. One gap remains: a comment posted between the final check and the merge call is not seen, and branch protection narrows this gap but does not close it (see below).

**The review only comments.** `02-review` never approves or requests changes. The merge decision, and any decision to accept a High finding, stays with people.

**Checks are evidence, not targets.** No template may weaken assertions, skip tests, loosen lint rules, or edit CI to get a pass. Each records a baseline before changing code and reports only the checks it ran.

**Draft means blocked.** A PR is ready for review once its planned scope is done and verified, even when the issue needs more PRs (`Refs #<n>`). Only blocked work stays a draft.

## Merge safety and policy decisions

These policies were decided by the maintainer and recorded in [PR #1](https://github.com/iceboundrock/ai-engineering-starter-kit/pull/1). Each one says whether the templates already enforce it.

**1. No required checks is not a pass.** If a repository has no required status checks configured, automated merging is blocked by default and the merge is left to a human. A repository owner may accept merging without required checks through trusted repository configuration; once that is configured, no further approval is needed per merge. *Pending:* `04-merge` does not enforce this yet. Its "all required checks have passed" condition holds when none are configured, and no configuration mechanism for the exception exists yet.

**2. Branch protection is recommended, not required.** Recommended settings are required status checks, required conversation resolution, and no bypassing of either. The two kinds of enforcement differ:
- **GitHub enforces at merge time:** `--match-head-commit` rejects a head other than the one checked, and branch protection, where configured, enforces the settings above.
- **The agent enforces only before the merge call:** everything in `04-merge` step 1, including the marker review's SHA and verdict, the no-later-activity rule, and unresolved threads.

A time-of-check/time-of-use race remains. A comment posted between the final check and the merge call escapes the agent's gate, and branch protection does not close this race: conversation resolution covers review threads, not every top-level PR comment. A repository without branch protection allows automated merging only after its owner explicitly accepts these risks. *Implemented:* `--match-head-commit`. *Pending:* `04-merge` does not check whether protection exists or whether the owner accepted running without it.

**3. Regression tests belong in the repository.** Coverage for `fill.sh` and the `04-merge` gate is to be committed as deterministic, isolated tests on synthetic inputs. They must not write to GitHub or need write permission, and should not need a test framework or CI. *Implemented:* `tests/fill.test.sh` and `tests/gates.test.sh`; the gate tests run the check blocks from the templates against a stub `gh`.

**4. Any activity after the automated review blocks the merge.** A PR comment, inline comment, thread reply, or review with a body posted after the latest automated review blocks `04-merge` until `02-review` runs again. The only exceptions are the automated reviewer's marker reviews and their inline comments. There are no exceptions by content, such as an "LGTM" or a bot's comment, because judging relevance is review work: `02-review` interprets activity, and `04-merge` only checks eligibility. This costs an extra review run after any late comment, and frequent comments can block a PR repeatedly. *Implemented.*
