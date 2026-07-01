# Template: Root Cause Analysis (RCA)

> Copy this into a new RCA document. Written to satisfy ITIL v4 problem management practice and to serve as audit evidence for ISO/IEC 27001:2022 A.5.27 (learning from incidents) and PCI-DSS v4.0 Req. 10 (where the incident involved logging/monitoring gaps).

## Incident Summary

| Field | Value |
|---|---|
| Incident/Problem Record ID | |
| Date/time of incident | |
| Date/time of detection | |
| Detection method | Monitoring alert / user report / other — specify |
| Duration of impact | |
| Severity | |
| Affected system(s)/CI(s) | |
| Author | |
| Date of RCA | |

## Impact

What broke, for whom, for how long. Quantify where possible (number of users affected, transactions failed, SLA breach if applicable). State business impact, not just technical impact.

## Timeline

Chronological, timestamped sequence of events from first anomaly through detection, diagnosis, remediation, and resolution confirmation. Include what was *tried* and didn't work, not just the eventual fix — this is often the most useful part of an RCA for future responders.

| Time | Event |
|---|---|
| | |

## Root Cause

The actual underlying cause — not the symptom. Distinguish clearly between:
- **Symptom:** what was observed (e.g. "SSSD authentication failures on prd-apexia and prd-ability")
- **Root cause:** the actual mechanism (e.g. "stateful firewall silently dropping idle LDAP TCP connections after timeout")

State the evidence that supports this being the root cause, not just a plausible explanation — the diagnostic steps and their output.

## Contributing Factors

Secondary factors that made the incident more likely, more severe, or harder to detect/diagnose (e.g. monitoring gap that delayed detection, missing documentation, a compensating control that was known-accepted but not tracked).

## Resolution

What was actually done to resolve the incident. Include the specific commands/configuration changes, not just a narrative description.

## Validation

How resolution was confirmed. Specific checks and their results.

## Preventive Actions

Concrete, owned, dated actions to prevent recurrence — not vague statements like "improve monitoring." Each item should have an owner and target date.

| Action | Owner | Target Date | Status |
|---|---|---|---|
| | | | |

## Detection Gap Analysis

Was this detected as fast as it should have been? If detection relied on a user report rather than monitoring, that's a finding in itself — note whether a monitoring/alerting gap contributed to time-to-detection and whether it should be closed.

## Lessons Learned / Workflow Feedback

If this incident traces back to a gap in an existing workflow document (`workflows/`), reference it here and note the specific update needed. RCAs should feed back into the platform's documented procedures, not just live as standalone records.
