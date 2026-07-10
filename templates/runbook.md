# Template: Runbook

> Use for condition-triggered, time-pressured operational response — incident-style, not a steady-state process. Produced by `agents/documentation-standards-architect/AGENT.md`. Optimize for someone reading this under pressure: front-load the decision, keep steps short, branch explicitly rather than forcing a linear read when the root cause isn't yet known. Consult `templates/framework-alignment-guide.md` before completing the Standards Alignment section — this template is designed to satisfy ITIL v4 Incident Management practice framing. Distinct from `templates/incident-report.md`: this document is the pre-written response plan invoked *during* an incident; the incident report is the live record of a specific occurrence.

## Document Control

| Field | Value |
|---|---|
| Document ID | RB-[System]-[NNN] |
| Version | |
| Status | Draft / Approved |
| Owner | |
| Last reviewed | |

## Trigger Condition

Exactly what condition/alert/symptom causes this runbook to be invoked. Be specific — alert name, threshold, or symptom description, not "if something seems wrong."

## Severity / Priority

How urgent this is — tie to the client's incident priority matrix if one exists.

## Immediate Actions (first 5 minutes)

```text
1. [First thing to check/do]
2. [...]
```

## Diagnostic Steps

Branch clearly — a runbook is a decision tree, not a linear list, when the root cause isn't yet known.

```text
1. [Check X]
   If X confirms the issue -> go to Resolution Step [N]
   If X does not confirm -> go to Diagnostic Step [N+1]
```

## Resolution Steps

### Scenario A: [Root cause A]

```text
1. [Step]
   Verification: [...]
```

### Scenario B: [Root cause B]

```text
1. [Step]
   Verification: [...]
```

## Escalation Path

| Condition | Escalate to | Contact method |
|---|---|---|
| Not resolved within [X] minutes | | |
| Requires vendor support | | |

## Rollback

If the resolution steps themselves need to be undone — reference `templates/rollback-plan.md` if the resolution is state-changing enough to warrant the full template rather than an inline summary.

## Post-Incident

Link to the client's Problem Management process or `templates/rca.md` — a runbook resolves the symptom; the RCA addresses root cause, per ITIL v4 Problem Management practice.

## Standards Alignment

Usually just: "Aligned to ITIL v4 Incident Management practice." Add NIST only if the incident is security-specific (link to the Respond/Recover functions of CSF 2.0 — verify via search). See `templates/framework-alignment-guide.md`.

## Revision History

| Version | Date | Author | Change summary |
|---|---|---|---|
| | | | Initial version |
