# Cross-Reference Consistency Audit — Milestone 13

Supersedes `docs/cross-reference-audit-milestone-10.md`. That document's methodology conflated directory references (`` `agents/` ``, used when a sentence lists categories generically) with file references (`` `agents/backup-dr-architect/AGENT.md` ``), which Milestone 12's re-audit caught as a bug. This document uses the corrected method and is the current source of truth for cross-reference health; the Milestone 10 document is retained for its own historical narrative (why the audit pattern exists) but its specific numbers are superseded by this one.

## Method

```bash
grep -rEo '`(agents|workflows|templates|standards|knowledge|examples|docs|playbooks|checklists|policies|scripts|automation|tests|tools|training|diagrams)/[a-zA-Z0-9_./-]+`' \
  --include="*.md" . | sed 's/^[^:]*://' | tr -d '`' | sort -u
```

Each extracted reference is then classified before being checked:
- **Placeholder/generic pattern** (e.g. `agents/X/AGENT.md`, `workflows/Y/WORKFLOW.md`, or a bare `agents/...` used mid-sentence to mean "the agents directory generically") — not a real path, excluded from the missing-file check.
- **Real file reference** — checked against the filesystem directly (`test -f`).

This distinction is what Milestone 10's script got wrong; a bare `` `agents/` `` or an ellipsis-truncated `` `agents/...` `` was previously being treated as a candidate file path and either silently ignored inconsistently or miscounted, which is how the two audits produced different totals (86 raw extractions previously vs. the classified breakdown below) without either being actually wrong about the *content* — just inconsistent about what counted as a checkable reference.

## Result

**43 unique raw extractions. 12 correctly classified as placeholder/generic (not real paths). 31 real file references checked. 29 resolve cleanly. 2 are deliberately deferred/historical (not gaps).**

| Reference | Status | Disposition |
|---|---|---|
| `docs/roadmap.md` | Referenced only in a historical `CHANGELOG.md` note describing its own replacement by `docs/architecture.md` | Correct as-is — documents a past correction, not a live pointer |
| `standards/terraform.md` | Referenced in `knowledge/index.md` as conditional on future Terraform adoption | Correctly deferred — no action needed while Ansible remains the automation backbone |
| `docs/glossary.md` | Was missing at the start of this milestone | **Fixed this milestone** — see `docs/glossary.md` |
| `docs/incident-response-playbook.md` | Appears only inside historical `CHANGELOG.md` notes (Milestone 11 "next milestone" and Milestone 12 "audit note") explaining that the actual deliverable landed at a different path (`playbooks/incident-response/PLAYBOOK.md`) | Correct as-is — same pattern as `docs/roadmap.md`, a historical note about its own resolution, not a live dangling pointer |

All other 27 real file references (agents, workflows, templates, standards, knowledge index, examples, playbooks, and this document's own predecessor) resolve cleanly.

## Why the numbers differ from Milestone 10/12's counts

This is worth stating plainly rather than leaving three different numbers (86, 57, and now 43) unexplained across the CHANGELOG: each pass used a slightly different extraction/counting convention. Rather than trying to reconcile the historical numbers retroactively, this document fixes the methodology going forward — the classification table above (placeholder vs. real, and real-resolved vs. real-deferred vs. real-missing) is the durable, re-runnable structure. Future audits should report against these same three buckets so counts are comparable milestone to milestone.

## Recommendation for future milestones

Continue the Milestone 10 recommendation to re-run this periodically (every 3-4 milestones, or before any release/tag). Use this document's classification table structure rather than a single raw count, and update this document in place (rather than creating a Milestone-N-numbered successor each time) unless the methodology itself changes again — the numbered-per-milestone pattern (10 → 13) was useful for narrating the methodology fix but isn't necessary to repeat indefinitely for routine re-runs with no methodology change.
