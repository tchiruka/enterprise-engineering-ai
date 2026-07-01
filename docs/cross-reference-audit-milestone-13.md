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

**49 unique raw extractions (up from 43 at Milestone 13, reflecting the two new workflows and their cross-links added in Milestone 16). 13 correctly classified as placeholder/generic. 36 real file references checked. 34 resolve cleanly. 2 are deliberately deferred/historical (not gaps) — the same two as Milestone 13.**

| Reference | Status | Disposition |
|---|---|---|
| `docs/roadmap.md` | Referenced only in a historical `CHANGELOG.md` note describing its own replacement by `docs/architecture.md` | Correct as-is |
| `standards/terraform.md` | Referenced in `knowledge/index.md` as conditional on future Terraform adoption | Correctly deferred — no action needed while Ansible remains the automation backbone |
| `docs/incident-response-playbook.md` | Appears only inside historical `CHANGELOG.md` notes explaining the actual deliverable landed at a different path (`playbooks/incident-response/PLAYBOOK.md`) | Correct as-is — historical note about its own resolution |

**Milestone 13's fixed item (`docs/glossary.md`) now resolves cleanly and is used extensively across the new Milestone 16 workflows and the updated programme-charter example.** No new gaps introduced by Milestone 14, 15, or 16's work — `workflows/database-engine-lifecycle/WORKFLOW.md` and `workflows/network-core-switching-upgrade/WORKFLOW.md` are both correctly cross-linked from their owning agents and from the programme-charter example that originally identified the second one as a gap.

*(Original Milestone 13 result, retained for history: 43 unique raw extractions, 12 placeholder, 31 real references, 29 resolved, 2 deferred.)*

## Why the numbers differ from Milestone 10/12's counts

This is worth stating plainly rather than leaving three different numbers (86, 57, and now 43) unexplained across the CHANGELOG: each pass used a slightly different extraction/counting convention. Rather than trying to reconcile the historical numbers retroactively, this document fixes the methodology going forward — the classification table above (placeholder vs. real, and real-resolved vs. real-deferred vs. real-missing) is the durable, re-runnable structure. Future audits should report against these same three buckets so counts are comparable milestone to milestone.

## Recommendation for future milestones

Continue the Milestone 10 recommendation to re-run this periodically (every 3-4 milestones, or before any release/tag). Use this document's classification table structure rather than a single raw count, and update this document in place (rather than creating a Milestone-N-numbered successor each time) unless the methodology itself changes again — the numbered-per-milestone pattern (10 → 13) was useful for narrating the methodology fix but isn't necessary to repeat indefinitely for routine re-runs with no methodology change.
