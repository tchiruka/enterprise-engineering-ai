# Playbook: Disaster Recovery Failover

The response *process* companion to `agents/backup-dr-architect/AGENT.md`'s DR runbook ownership, mirroring the incident-report/incident-response-playbook pairing established in Milestones 11-12 (`templates/incident-report.md` structures the document; `playbooks/incident-response/PLAYBOOK.md` structures the process). This playbook covers the decision process and communication cadence around *invoking* a DR failover; the technical step-by-step for any specific system's failover lives in that system's own DR runbook (a deliverable of `agents/backup-dr-architect/AGENT.md`, scenario-specific and not duplicated here).

**Owning agent:** `agents/backup-dr-architect/AGENT.md` (process ownership and execution); `agents/chief-infrastructure-engineer/AGENT.md` (cross-domain coordination if failover spans multiple systems); `agents/security-architect/AGENT.md` (if the DR event stems from or overlaps with a security incident — coordinate with `playbooks/incident-response/PLAYBOOK.md` in that case rather than running two uncoordinated processes).

## When this playbook applies

- A primary system/site is unavailable and DR failover is being considered as the response (as distinct from a standard incident response for a recoverable fault — see the decision point below).
- A planned DR test/failover exercise, which should follow this same process to keep the tested process identical to the real one.

## Decision point: failover vs. continue troubleshooting forward

Before invoking failover, confirm:
- [ ] The primary system/site is confirmed unavailable or degraded beyond an acceptable threshold, not just suspected.
- [ ] Estimated time to restore the primary exceeds the documented RTO for this system — if primary restoration is faster than failover, do not fail over.
- [ ] The DR target is confirmed healthy and its last successful replication/backup point is known (state the actual RPO being accepted, not an assumed one).
- [ ] Failover has been tested for this system within the last [interval defined per system's own DR runbook] — if failover has never been tested, treat this as a higher-risk action and escalate the decision rather than proceeding on an unvalidated assumption that it will work.

This decision follows the same trigger-condition discipline as `templates/rollback-plan.md`: it should be made against pre-agreed, objective criteria, not improvised under pressure. If a system's DR runbook doesn't yet state its RTO/RPO and failover-test currency, that's a gap to flag before relying on it in a live event, not something to discover mid-failover.

## Severity and response targets

Reuse the severity definitions from `playbooks/incident-response/PLAYBOOK.md` rather than maintaining a second, potentially inconsistent scale — a DR-triggering event is, at minimum, a high-severity incident under that playbook's classification, and the two processes should run in parallel (incident response handling detection/communication/timeline, this playbook handling the specific failover decision and execution) rather than as competing processes.

## Process

### 1. Detect & Confirm
Confirm primary unavailability per the Decision Point checklist above. Do not invoke failover on a single unconfirmed signal — cross-check via at least one independent monitoring source (per the estate's Wazuh/Nagios coverage) before treating this as real.

### 2. Declare & Notify
Declare a DR event explicitly (this is a deliberate, named decision, not something that happens silently) and notify per the communication cadence in `playbooks/incident-response/PLAYBOOK.md` for the corresponding severity. Explicitly state: what's failing over, to where, the accepted RPO (data loss window, stated in concrete time), and the estimated time to complete failover.

### 3. Execute Failover
Follow the system-specific DR runbook (owned by `agents/backup-dr-architect/AGENT.md`, or the relevant platform agent for that system) — this playbook does not duplicate that technical detail. Log every step per `standards/logging.md`, since a DR event's log trail is exactly the kind of evidence that matters most for the post-incident review and for any compliance reporting obligation.

### 4. Validate
Confirm the failed-over system is genuinely serving traffic/load correctly, not just powered on — application-level validation, not just infrastructure-level power/network state. Confirm data currency matches the RPO stated in Step 2 (no silent additional data loss beyond what was communicated).

### 5. Communicate Status
Update stakeholders per the incident response playbook's cadence: failover complete, current known data-loss window, any functionality operating in a degraded/DR-specific mode, and estimated timeline for failback to primary (if applicable and known).

### 6. Failback (when primary is restored)
Failback is not simply the reverse of failover — data written to the DR target during the outage window must be reconciled back to primary before or during failback, per the system's own DR runbook. Treat failback with the same rigor as the original failover decision: confirm primary is genuinely healthy and stable (not just briefly reachable) before committing to it, and confirm the reconciliation/replication-back process has actually completed rather than assuming it based on elapsed time.

### 7. Post-Incident Review
A DR event always produces both: an RCA (`templates/rca.md`) for why the primary failed, owned by whichever agent's layer the root cause traces to, and a DR-process-specific review answering: was the actual RTO/RPO achieved close to what the runbook documented, or was there a material gap between tested/theoretical figures and what actually happened? Per `agents/backup-dr-architect/AGENT.md`'s own decision framework, an untested or now-proven-inaccurate RTO/RPO figure is itself a finding requiring the DR runbook to be corrected and re-tested, not just noted.

## Roles quick reference

| Role | Responsibility |
|---|---|
| DR decision authority | Confirms the Decision Point checklist and formally declares the DR event — named individual per system criticality tier, not just a role, mirroring `templates/rollback-plan.md`'s Decision Authority field |
| `agents/backup-dr-architect/AGENT.md` | Owns the system-specific DR runbook, executes/coordinates the technical failover and failback |
| Relevant platform specialist (`vmware-architect`, `windows-infrastructure-engineer`, `openstack-architect`, `linux-platform-engineer`) | Executes platform-layer actions within the failover (e.g. bringing up replicated VMs, confirming guest-OS health post-failover) |
| `agents/chief-infrastructure-engineer/AGENT.md` | Coordinates if failover spans multiple systems/domains simultaneously |
| `agents/security-architect/AGENT.md` | Involved if the triggering event has security implications, or if failover itself creates a temporary compliance-scope question (e.g. DR site's own PCI-DSS scope status) |

## Relationship to DR testing

Planned DR tests should execute this exact process (Steps 1-6, with Step 1 replaced by "scheduled test" rather than a real detected outage) so the tested process and the real process never diverge — a DR playbook that's only ever exercised differently in testing than in a real event isn't actually validated. Test outcomes feed the same Post-Incident Review structure in Step 7, specifically the RTO/RPO-achieved-vs-documented comparison.
