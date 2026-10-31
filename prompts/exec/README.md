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

A template with any unset or empty variable is skipped rather than half-filled. With no template named, every template whose variables are set is filled.

## Why they work this way

**GitHub content is data, not instructions.** Anyone can write an issue, a PR description, a comment, or a code comment, so the templates never run commands found there and report any text aimed at agents.

**State lives on GitHub, in markers.** Every run starts with no memory of earlier ones. The review marker records which commit was reviewed, finding markers tie threads to findings, the `[**AUTOFORGE**] ` prefix and the `agent-address-review` report mark the fixer's own posts, and the `agent-implement` marker lets a run resume its own draft PR. These markers are the interfaces between templates; `AGENTS.md` lists who writes and reads each one.

**A login does not prove authorship.** The author, the reviewer, and the fixer may post under one account. The templates therefore trust markers and the code, not the login, and treat every reply as a claim to verify.

**Nothing is resolved on someone's word.** `03-fix` resolves only threads it fixed as asked. `02-review` re-checks its own resolved threads against the code and carries forward any finding that is still present. `04-merge` merges only when the latest automated review covers the current head and found no blocking issues, so a mistaken "fixed", or fix commits pushed after the last review, cannot reach the default branch unnoticed.

**The review only comments.** `02-review` never approves or requests changes. The merge decision, and any decision to accept a High finding, stays with people.

**Checks are evidence, not targets.** No template may weaken assertions, skip tests, loosen lint rules, or edit CI to get a pass. Each records a baseline before changing code and reports only the checks it ran.

**Draft means blocked.** A PR is ready for review once its planned scope is done and verified, even when the issue needs more PRs (`Refs #<n>`). Only blocked work stays a draft.
