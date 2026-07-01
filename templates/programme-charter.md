# Template: Programme Charter

> Copy this for any multi-phase, multi-workflow initiative (e.g. an EOL elimination programme spanning several remediation streams). A single change request (`templates/change-request.md`) is the wrong artifact for this scope — a programme charter sits above individual changes and ties them together under one governance structure. Owned by `agents/chief-infrastructure-engineer/AGENT.md`.

## Programme Header

| Field | Value |
|---|---|
| Programme name | |
| Sponsor | |
| Programme owner | |
| Start date | |
| Target completion / hard deadline | If tied to an external deadline (e.g. vendor extended-support end date), state it explicitly and cite the source. |
| Status | Planning / Active / At Risk / Complete |

## Business Driver

Why this programme exists. Tie to a specific, citable driver — an EOL/EOS date, an audit finding, a regulatory deadline — not a general "improve infrastructure" statement. If there's a hard external deadline (e.g. Windows Server Extended Support end date), state the consequence of missing it.

## Scope

### In scope
What this programme covers — list the remediation streams/workstreams.

### Out of scope
What's explicitly excluded, and why (e.g. "physical network refresh is tracked as a separate programme").

## Workstreams

Each workstream should map to one or more workflows in `workflows/` and name its owning specialist agent. This is the core structure of the charter — it's what turns a business driver into executable work.

| Workstream | Owning agent | Workflow(s) used | Target completion | Status |
|---|---|---|---|---|
| | | | | |

## Dependencies Between Workstreams

Explicitly call out where one workstream blocks or informs another (e.g. "AD DC upgrade must complete in a given site before the OpenStack migration workstream can proceed there, due to authentication dependency"). A programme charter's main value over a flat list of independent changes is surfacing these cross-workstream dependencies before they cause a scheduling collision.

## Risk Register

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|
| | | | | |

Include programme-level risks distinct from any single workstream's own risk analysis (which lives in that workstream's change requests) — e.g. "insufficient engineering capacity to run two workstreams concurrently," "hard deadline leaves no slack for a failed change requiring rollback and retry."

## Governance

- **Reporting cadence:** how often and to whom progress is reported.
- **Change approval:** which changes within this programme go through standard CAB versus any expedited path agreed for programme work, and why.
- **Escalation path:** who resolves cross-workstream conflicts (default: `agents/chief-infrastructure-engineer/AGENT.md` per its arbitration responsibility).

## Milestones

| Milestone | Target date | Dependent workstreams | Status |
|---|---|---|---|
| | | | |

## Compliance Framework Alignment

Which PCI-DSS/ISO 27001/COBIT/ITIL v4 requirements this programme addresses or is constrained by, cited specifically rather than generally (e.g. "Workstream 3 closes ISO/IEC 27001:2022 A.8.8 finding from the most recent internal audit").

## Post-Programme Review

Completed once the programme reaches target completion or is formally closed:
- [ ] All workstreams closed or explicitly descoped with justification.
- [ ] Hard deadline met, or documented reason if missed.
- [ ] Risk register reviewed — any risks that materialized, and what was learned.
- [ ] Lessons learned fed back into the relevant workflow documents in `workflows/`.
