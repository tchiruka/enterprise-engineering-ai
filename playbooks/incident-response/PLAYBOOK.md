# Playbook: Incident Response

**Owning agent:** `agents/security-architect/AGENT.md` (coordination); every specialist agent executes response actions within its own domain during an incident.
**Companion document:** `templates/incident-report.md` — this playbook describes the *process*; that template is the *document* produced and updated as the process runs. Use them together.

## Purpose

A template tells you what to write down. This playbook tells you what to actually *do*, in what order, and who's involved — the part that matters most in the first minutes of an incident, when there's no time to reconstruct process from a document template alone.

## Severity Definitions

Consistent severity classification drives everything else in this playbook (paging, escalation timing, communication cadence) — get this right first.

| Severity | Definition | Examples |
|---|---|---|
| **Critical** | Active harm, confirmed unauthorized access, or domain/estate-wide outage with security implication | Confirmed intrusion in progress; ransomware detonation; last-DC-in-domain compromise |
| **High** | Confirmed security incident with contained but significant impact, or high-confidence indicator of compromise | Single-host compromise confirmed and contained; PCI-scoped system with confirmed unauthorized access |
| **Medium** | Suspected incident under investigation, not yet confirmed, or confirmed low-impact incident | Anomalous auth pattern under investigation; policy violation with no evidence of data exposure |
| **Low** | Informational — policy violation or anomaly with no indication of compromise, tracked for pattern awareness | Single failed-login anomaly, isolated and explained |

## Response Timeline by Severity

| Severity | Initial response target | Handler assigned | Human escalation |
|---|---|---|---|
| Critical | Immediate | Security Architect + relevant platform agent(s) simultaneously | Immediate — per the platform-wide escalation rule that active unauthorized access requires human-led response, not continued AI-assisted documentation alone |
| High | Within 1 hour | Security Architect + relevant platform agent(s) | Within the response window, before containment actions with broader-than-single-host impact |
| Medium | Within 4 hours (business hours) | Relevant platform agent, Security Architect notified | If investigation confirms escalation to High/Critical |
| Low | Next business day, batched into periodic reporting | Relevant platform agent | Only if a pattern emerges across multiple Low incidents |

## Step-by-Step Process

### 1. Detect and Triage
- Confirm the detection source (Wazuh alert, Nagios check, user report) and classify initial severity per the table above — err toward the higher severity when genuinely uncertain, and downgrade once evidence supports it, rather than the reverse.
- Open `templates/incident-report.md`, populate the Incident Header immediately — this starts the timeline record from the earliest possible point.
- Assign a handler. For anything Medium or above, notify `agents/security-architect/AGENT.md` even if that agent isn't the handler, so cross-domain coordination is possible from the start rather than only after the situation has grown.

### 2. Analyze
- Establish scope: what's confirmed affected, suspected, and confirmed unaffected — populate the Incident Report's Detection & Analysis section as this develops, not just at the end.
- Determine whether this is genuinely security-relevant or a false positive / benign anomaly — if the latter, downgrade and close with a brief note rather than running the full playbook to completion for something that didn't need it.
- **Do not skip evidence preservation** if there's any chance of follow-up investigation, disciplinary action, or legal process — capture logs/state before containment actions might alter or destroy them.

### 3. Contain
- Choose short-term (stop active harm immediately) vs. long-term (sustainable containment while investigation continues) containment, and state which explicitly in the incident report.
- Containment actions execute within the relevant specialist agent's domain (e.g. `agents/windows-infrastructure-engineer/AGENT.md` disabling a compromised AD account, `agents/linux-platform-engineer/AGENT.md` isolating a host at the network level in coordination with `agents/network-architect/AGENT.md`) — Security Architect coordinates but does not bypass the domain specialist's own judgment about how to safely execute the containment action on their platform.
- For Critical/High severity, containment actions with impact broader than a single host require the human escalation point from the timeline table above before execution, not after.

### 4. Eradicate
- Remove the actual cause, not just its symptoms — confirm eradication is complete before moving to recovery, since a premature "all clear" that misses residual compromise is worse than a slower, confirmed-clean recovery.

### 5. Recover
- Validate cleanliness/security before returning systems to production traffic — specific checks, not just "it's back up," per the incident report template's Recovery section.
- Apply an enhanced monitoring period post-recovery, duration proportional to severity (Critical/High: minimum 14 days elevated monitoring; Medium: 7 days; Low: routine monitoring sufficient).

### 6. Post-Incident
- Complete an RCA (`templates/rca.md`) for anything Medium severity or above — link it from the incident report's Post-Incident Activity checklist.
- Feed preventive actions and any workflow gaps discovered back into the relevant `workflows/` document, per the pattern already established in this platform (see `examples/vmware-esxi-upgrade-failure-rollback/WALKTHROUGH.md` for a worked example of this feedback loop in a non-security context).
- Record any compensating control or risk acceptance in Security Architect's compensating-control register.

## Communication Cadence

| Severity | Stakeholder update frequency |
|---|---|
| Critical | Continuous during active response; formal update at least every 2 hours until contained |
| High | At least every 4 hours until contained, then daily until resolved |
| Medium | Daily until resolved |
| Low | Included in routine periodic reporting only |

State explicitly in the incident report who the stakeholders are for a given incident — this varies by affected system (e.g. a PCI-scoped system incident has different notification stakeholders than an internal-only tooling incident).

## Roles Quick Reference

- **Handler:** owns driving the incident to resolution and keeping the incident report current.
- **`agents/security-architect/AGENT.md`:** coordinates when more than one domain is involved, owns the compliance-scope and notification-obligation determination, arbitrates any conflicting containment recommendations between domain specialists.
- **Domain specialist agent(s):** execute detection, containment, eradication, and recovery actions within their own platform, using their own domain expertise — the playbook coordinates them, it doesn't replace their judgment.
- **`agents/chief-infrastructure-engineer/AGENT.md`:** engaged if the incident's scope genuinely spans beyond what Security Architect's coordination role covers (e.g. an incident that also requires programme-level resequencing of unrelated planned work).

## What this playbook does not cover

- Legal/regulatory notification decisions — this platform provides the technical facts (scope, data potentially affected, timeline); the notification decision itself needs legal input beyond any agent's scope, per every relevant agent's escalation rules.
- Law enforcement engagement — a human decision, not one this playbook or any agent should make autonomously.
