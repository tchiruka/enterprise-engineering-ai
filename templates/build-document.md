# Template: Build Document / As-Built

> Use for a definitive record of how a specific system, server, or service was built and configured — detailed enough to rebuild from, and defensible enough to stand as audit evidence. Produced by `agents/documentation-standards-architect/AGENT.md`, drawing on the relevant domain specialist agent for the actual build steps and hardening detail. Consult `templates/framework-alignment-guide.md` before completing the Standards Alignment section — this template is designed to satisfy NIST SP 800-53 / SP 800-123 configuration-control framing, with a COBIT 2019 BAI10 (Managed Configuration) governance line where relevant.

## Document Control

| Field | Value |
|---|---|
| Document ID | BD-[System]-[NNN] |
| Version | |
| Status | Draft / Approved / As-Built (final) |
| Author | |
| Date build completed | |
| Related change record | CR/RFC number, if this build was driven by a change (see `templates/change-request.md`) |
| Classification | Per the client's information classification policy |

## 1. Purpose and Overview

What this system/service is, what it does, and the business/technical justification for building it.

## 2. Architecture Summary

High-level description, with a diagram reference if available. Where this system sits in the estate — which domain/cluster/network segment/site.

## 3. System Specifications

| Attribute | Value |
|---|---|
| Hostname | |
| IP address(es) | |
| OS/platform + version | |
| CPU / RAM / storage | |
| Environment | Production / UAT / Dev |
| Hypervisor/host | |
| Datastore/storage backend | |

Mark any field not yet known as `[TO BE CONFIRMED]` rather than leaving it blank without comment — a blank cell in an as-built document reads as an oversight, an explicit marker reads as a known gap.

## 4. Build Steps

Numbered, atomic, in the order actually performed. Include exact commands/settings where practical, and the verification for each.

```text
1. [Step]
   Configuration applied: [exact setting/command]
   Verification: [how confirmed — output, screenshot reference, log check]
2. [Next step]
```

## 5. Security Configuration / Hardening

CIS baseline applied, firewall rules, service accounts, encryption at rest/in transit, patch level at build time. This is the section most likely to need NIST alignment — see `templates/framework-alignment-guide.md`.

## 6. Integration Points

What this system talks to — directory services, monitoring, backup, ITSM/CMDB, other services. Include ports/protocols where security-relevant.

## 7. Backup and Recovery

Backup job/schedule, RPO/RTO if defined, and a pointer to the relevant SOP/Runbook for the restore procedure rather than duplicating it here.

## 8. Monitoring and Alerting

What's monitored, thresholds, and where alerts route to.

## 9. Known Deviations from Standard Build

Anything that doesn't match the client's baseline image/standard, and why. This section matters most at audit time — undocumented deviations are a common finding.

## 10. Post-Build Validation

Checklist of what was tested/confirmed before sign-off — connectivity, service functionality, security scan, backup test.

## 11. Standards Alignment

2-5 lines. Example: "Hardening aligned to NIST SP 800-53 Rev. 5 CM-6 (Configuration Settings) and the applicable CIS Benchmark. Supports COBIT 2019 BAI10 (Managed Configuration)." Verify control IDs via search before finalizing — see `templates/framework-alignment-guide.md`.

## 12. Sign-off

| Role | Name | Date |
|---|---|---|
| Built by | | |
| Reviewed by | | |
| Approved by | | |

## 13. Revision History

| Version | Date | Author | Change summary |
|---|---|---|---|
| | | | Initial as-built |
