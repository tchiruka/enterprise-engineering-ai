# Tests

This directory holds the platform's structural validation test suite — the concrete implementation of the "Testing framework" deliverable named in the project's original brief, which had no actual content until Milestone 18.

## What's here

`validate-repo.sh` — a dependency-free Bash script (per `standards/bash.md`) that checks:

1. **Agent structure** — every `agents/*/AGENT.md` (except `_TEMPLATE.md`) has all 9 sections required by `agents/_TEMPLATE.md`.
2. **Workflow structure** — every `workflows/*/WORKFLOW.md` (except `_TEMPLATE.md`) has all 10 sections required by `workflows/_TEMPLATE.md`.
3. **No stray placeholder text** — `TODO`, `[insert ...]`, `lorem ipsum` anywhere outside files that are themselves templates (where that syntax is correct, not a defect).
4. **Cross-reference consistency** — every backtick-quoted repository path resolves to a real file, except a maintained allow-list of deliberately deferred/historical references (kept in sync with `docs/cross-reference-audit-milestone-13.md`).

## Running it

```bash
./tests/validate-repo.sh
```

Exits `0` if everything passes, `1` if any genuine structural issue is found. Output lists every check performed (`PASS`/`FAIL`) followed by a summary count.

## What this replaces (and what it doesn't)

This formalizes the manual cross-reference audit process used at Milestones 10, 13, 16, and 17 (`docs/cross-reference-audit-milestone-13.md`) into something scriptable and repeatable, plus extends it with the structural section checks that were previously only verified by eye during each milestone's own work.

**This is a structural linter, not a technical reviewer.** It confirms an agent or workflow file *has* a Decision Framework section, not that the decisions in it are sound; it confirms a workflow *has* a Rollback section, not that the rollback procedure would actually work if executed. Technical accuracy remains the responsibility of whichever agent or human authored/reviewed the content — this script exists to catch the structural drift and dangling-reference problems that are otherwise easy to introduce silently across many milestones, per the reasoning already laid out in `docs/cross-reference-audit-milestone-13.md`.

## Maintaining this test suite

- If a new required section is added to `agents/_TEMPLATE.md` or `workflows/_TEMPLATE.md`, add it to the corresponding `REQUIRED_*_SECTIONS` array in `validate-repo.sh` in the same change.
- If a new deliberately-deferred reference is introduced (following the pattern in `CONTRIBUTING.md`'s style rules), add it to the `DEFERRED_REFS` array here **and** to `docs/cross-reference-audit-milestone-13.md`'s table — the two should never drift apart, since this script's allow-list existing without a matching documented justification would itself be an undocumented exception, which is exactly what this platform's discipline is meant to avoid.
- Run this script as part of the periodic cross-reference audit cadence already established in `CONTRIBUTING.md` (every 3-4 milestones, or before any release/tag), not only when adding new content — structural drift can be introduced by edits to existing files, not just new ones.

## Recommended future extension

This script currently runs locally, on demand. A natural next step, once/if this repository moves to a hosted Git platform with CI capability, would be running it automatically on every push or pull request rather than relying on a maintainer remembering to run it — noted here rather than acted on now, since introducing CI/CD tooling is outside this platform's current scope (see `standards/git.md`'s "What this standard does not cover").
