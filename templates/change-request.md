# Template: Change Request (CR)

> Copy this into a new change record (iTop or equivalent ITSM). Every field must be completed with specifics — no "TBD" fields go to CAB. This template is designed to satisfy ITIL v4 change enablement practice and to hold up as evidence under PCI-DSS v4.0 Req. 6.5 (change control) and ISO/IEC 27001:2022 A.8.32 (change management).
>
> **If this is a genuine active-emergency situation** (production down or severe impact right now, not just business urgency), use `templates/emergency-change.md` instead — it's a compressed, expedited variant of this template with mandatory retroactive follow-up, not a bypass of change control.

## Change Record Header

| Field | Value |
|---|---|
| CR Number | |
| Title | Short, specific — not "Server maintenance" but "In-place OS upgrade: PRD-DC03 (sec.v.co.zw) Server 2016 → 2022" |
| Requested by | |
| Change owner / implementer | |
| Change type | Standard / Normal / Emergency — see classification criteria below |
| Risk classification | Low / Medium / High — with justification |
| Affected system(s)/CI(s) | Reference the CMDB CI IDs |
| Proposed date/time | |
| Maintenance window duration | |
| CAB approval required? | Yes/No — and why |

## Change Type Classification

> Added following `tests/agent-behavior/results-milestone-21.md` (Scenario 16), which found this platform had a `Change type` field with three labels but no defined criteria for which applies — leaving agents to improvise the distinction ad hoc.

- **Standard** — pre-approved, low-risk, repeatable change with a documented, unchanging procedure (e.g. a routine firewall rule between two already-mutually-trusted internal hosts with no PCI-DSS segmentation relevance, following an exact pattern used before). Requires: confirmation the change matches an established Standard-change pattern exactly (no deviation), and confirmation it does not touch PCI-DSS-scoped systems or segmentation. Does **not** require full CAB review each time, but still requires this record to be filed and does **not** exempt the change from `templates/rollback-plan.md` if state-changing. If any doubt exists about whether a change truly matches an established low-risk pattern, classify it as Normal instead — Standard is earned by a track record of a specific, narrow, repeatable pattern, not claimed because a change sounds small.
- **Normal** — the default classification for anything that doesn't meet Standard's narrow criteria and isn't a genuine active emergency. Full CAB review applies.
- **Emergency** — active, material production impact right now, where waiting for standard CAB timing would materially worsen that impact. Use `templates/emergency-change.md` instead of this template, not this template with "Emergency" written in the Change type field — the emergency path has its own compressed structure with mandatory retroactive full-CR follow-up.

**MUST:** "the requester says it's small" is not sufficient justification for Standard classification on its own — confirm against the two criteria above (exact pattern match, no PCI-DSS scope touch) explicitly before applying it, per the precedent in `tests/agent-behavior/results-milestone-21.md`.

## Overview

What is changing and why. 2-4 sentences, written so a non-specialist CAB member understands the business reason for the change, not just the technical mechanics.

## Scope

Explicitly what is and is not included in this change. If this change is one step in a larger programme (e.g. one DC in a multi-forest upgrade programme), say so and reference the programme.

## Business Justification

Why this change is needed now — tie to a specific driver: EOL/EOS deadline, security finding, audit finding, capacity constraint, incident remediation.

## Risk Assessment

- **Blast radius:** what fails, and for whom, if this goes wrong.
- **Likelihood:** based on prior similar changes, testing performed, vendor-documented issues for this operation.
- **Impact if it fails:** service downtime, data loss potential, compliance exposure.
- **Risk classification justification:** why Low/Medium/High given the above.

## Pre-Implementation Checklist

- [ ] Backup taken and verified restorable (attach evidence or reference).
- [ ] Change tested in non-production where applicable, or justification given for why not.
- [ ] Rollback plan documented below and confirmed executable within the maintenance window.
- [ ] Stakeholders/downstream system owners notified.
- [ ] Required approvals obtained (list who/when).

## Implementation Plan

Numbered, step-by-step. Reference the specific workflow document this follows (e.g. `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`, Scenario B) rather than duplicating full procedural detail here — the CR should show *what* will happen and *when*, with the authoritative how-to living in the workflow doc.

## Validation Plan

Specific, objective checks to confirm success — commands, expected output, thresholds. Not "confirm it's working" but "`dcdiag /v` returns zero errors; `repadmin /replsummary` shows 0 fails across all partners."

## Rollback Plan

Explicit steps to revert if validation fails. State the time cost of rollback and confirm it fits within the approved maintenance window. If rollback is not possible (e.g. certain in-place upgrades), state this explicitly and describe the forward-fix contingency instead.

## Communication Plan

Who is notified before, during (if there's user-visible impact), and after the change. Include the specific notification channel and timing.

## Post-Implementation Review

Completed after the change:
- [ ] Validation plan executed — attach evidence.
- [ ] Any deviation from plan documented.
- [ ] Incident raised? (if the change caused an unplanned issue, link it)
- [ ] Change closed with outcome: Successful / Successful with issues / Failed / Rolled back.
- [ ] Lessons learned fed back into the owning workflow document if applicable.
