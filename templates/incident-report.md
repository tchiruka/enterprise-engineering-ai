# Template: Incident Report

> Copy this for security incident handling and daily/periodic incident reporting, structured around the NIST SP 800-61 incident response lifecycle (Preparation, Detection & Analysis, Containment/Eradication/Recovery, Post-Incident Activity). This is distinct from `templates/rca.md`: an RCA is written after resolution to document root cause and prevention; this template is written *during* an incident (and updated as it progresses) to drive and record the response itself. A closed incident report should typically produce a linked RCA using `templates/rca.md` for the root-cause deep-dive, referenced in this document's Post-Incident Activity section rather than duplicated here.

## Incident Header

| Field | Value |
|---|---|
| Incident ID | |
| Report status | Open / Contained / Resolved / Closed |
| Date/time detected | |
| Date/time reported | |
| Reported by | |
| Incident handler | |
| Severity | Critical / High / Medium / Low — with justification |
| Affected system(s)/CI(s) | |
| PCI-DSS / ISO 27001 scope implication | Yes/No — if yes, `agents/security-architect/AGENT.md` must be looped in per its escalation rules |

## Detection & Analysis (NIST SP 800-61 Phase 2)

### Detection source
Monitoring alert (specify: Wazuh rule ID, Nagios check, etc.) / user report / third-party notification / other.

### Initial indicators
What was observed that triggered classification as an incident rather than routine noise — be specific (log entries, alert content, anomalous behavior described).

### Category
Use a consistent taxonomy across reports (adapt to the estate's actual incident types, e.g.): Unauthorized Access, Malware, Denial of Service, Data Exposure, Policy Violation, Availability/Outage-with-security-implication, Other (specify).

### Scope determination
What is confirmed affected, what is suspected but unconfirmed, and what has been confirmed *not* affected (explicitly ruling things out is as valuable as confirming what's in scope, and prevents both under- and over-reaction).

### Timeline

| Time | Event | Source of evidence |
|---|---|---|
| | | |

## Containment (NIST SP 800-61 Phase 3a)

### Containment strategy
Short-term (immediate, to stop active harm) vs. long-term (sustainable while investigation continues) — state which is being applied and why.

### Actions taken

| Time | Action | Taken by | Systems affected |
|---|---|---|---|
| | | | |

### Evidence preservation
What was preserved before remediation altered system state (log exports, disk images, memory captures) — necessary if any follow-up investigation, disciplinary action, or legal process might depend on it. If nothing was preserved and something arguably should have been, state that explicitly as a gap rather than omitting it.

## Eradication (NIST SP 800-61 Phase 3b)

What was removed/fixed to eliminate the cause of the incident (as distinct from just containing its spread) — malware removed, vulnerability patched, unauthorized access revoked, misconfiguration corrected.

## Recovery (NIST SP 800-61 Phase 3c)

### Recovery actions
Steps taken to restore affected systems to normal operation.

### Validation before returning to production
Specific checks confirming the system is genuinely clean/secure before being trusted with production traffic again — not just "it's back up."

### Monitoring period
Enhanced monitoring applied post-recovery, and for how long, to catch any sign the incident wasn't fully eradicated.

## Post-Incident Activity (NIST SP 800-61 Phase 4)

- [ ] Root Cause Analysis completed — link to `templates/rca.md`-based document: _____
- [ ] Preventive actions identified in the RCA tracked to completion.
- [ ] Lessons learned fed back into the relevant workflow document(s) in `workflows/`, if applicable.
- [ ] Compensating controls or risk acceptances (if any) recorded in the compensating-control register owned by `agents/security-architect/AGENT.md`.
- [ ] Stakeholder notification completed, if required (specify who and when).
- [ ] Regulatory/contractual notification obligations assessed (specify determination — this platform provides the technical facts; the notification decision itself may need legal input beyond this document's scope).

## Daily/Periodic Reporting Roll-Up Note

For daily incident reporting purposes (rather than a single incident's full lifecycle document), a roll-up should summarize: incidents opened/closed in the period, current open incidents by severity and age, any incident nearing or exceeding its response SLA, and any emerging pattern across multiple incidents worth flagging to `agents/security-architect/AGENT.md` even if no single incident individually warrants escalation.
