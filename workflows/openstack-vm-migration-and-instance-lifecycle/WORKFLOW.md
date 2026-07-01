# Workflow: OpenStack VM Migration and Instance Lifecycle

**Owning agent(s):** OpenStack Architect (primary); VMware Architect (source-side coordination for migration scenarios); Backup & DR Architect (backup role integration); Security Architect (baseline image hardening)
**Applies to:** OpenStack Nova/Neutron/Cinder/Glance instances, and VMs migrating from VMware into OpenStack
**Compliance frameworks referenced:** ITIL v4 (change enablement), PCI-DSS v4.0 (Req. 6.3 where migrated workloads are in scope), COBIT 2019 (BAI06)

## Executive Summary

`agents/openstack-architect/AGENT.md` names VMware-to-OpenStack boot-failure diagnostic work as a core responsibility, and this workflow gives it (and the rest of the OpenStack VM lifecycle) a documented procedure to follow. It covers three scenarios: **VMware-to-OpenStack VM Migration** (the destination-side import, coordinated with `agents/vmware-architect/AGENT.md` for the source side), **Instance Boot-Failure Diagnosis** (a common, well-understood issue class in this kind of migration, not specific to any one client), and standalone OpenStack-native instance lifecycle work that isn't migration-related.

## Prerequisites

- Administrative access to the OpenStack control plane (Horizon/CLI/API credentials with sufficient project-level or admin scope for the operation).
- For migration scenarios: confirmed coordination with `agents/vmware-architect/AGENT.md` on source-side VM state (powered off cleanly, no pending snapshots to consolidate, VMware Tools status known) before export begins.
- Target Nova compute host capacity confirmed sufficient (CPU/RAM/storage) before starting an import.
- Neutron network mapping planned in advance — the source VMware port group's VLAN/subnet must have a confirmed corresponding Neutron network before cutover, not discovered as a gap during the migration itself.
- Change record raised in the client's ITSM/CMDB platform (e.g. iTop, ServiceNow, or equivalent), validated against the client's own change-control validation criteria before CAB submission.
- Current backup of the source VM (VMware-side) confirmed before migration begins — if migration fails destructively, the source should still be recoverable.

## Assessment

Before starting any scenario, establish baseline health of the OpenStack control plane and the specific compute host in question:

```bash
# Control plane service health
openstack service list
openstack compute service list
openstack network agent list

# Target compute host capacity
openstack hypervisor show <hostname> -f json

# Existing instance inventory on target host (avoid unexpected contention)
openstack server list --host <hostname> --all-projects
```

Baseline "healthy" = all Nova/Neutron/Cinder/Glance services reporting `up`, no compute/network agents down, target host showing sufficient free capacity for the planned instance. Resolve any service-level issues before proceeding — importing a VM onto a control plane with a degraded Neutron agent, for instance, is a common way to convert a migration task into a much harder mixed migration-plus-outage incident.

## Risk Analysis

- **Blast radius:** a single-instance migration failure is typically scoped to that instance (low-to-medium, assuming the source VM remains available as a fallback per Prerequisites). A control-plane-level issue (Keystone, Neutron) during a migration batch has estate-wide blast radius — per `agents/openstack-architect/AGENT.md`'s own escalation rules, this should stop the migration and escalate rather than pushing through.
- **Failure modes:** boot failures from missing/incorrect drivers (VirtIO vs. the source hypervisor's driver expectations) or incorrect boot device order surviving the conversion; network connectivity failure from a Neutron network mapping mismatch (the VM boots but can't reach anything, which is easy to mistake for a boot failure proper); image format/conversion issues (VMDK → QCOW2/RAW) producing subtly corrupted disk images that boot partially or fail intermittently rather than cleanly; data integrity risk if a conversion step silently truncates or corrupts data — this is the escalation-worthy failure mode per `agents/openstack-architect/AGENT.md`'s own rules, distinct from a simple boot-configuration problem.
- **MUST:** never delete or decommission the source VMware VM until the migrated instance is confirmed fully functional (application-level validation, not just power-on) — mirrors the swing-migration pattern's burn-in principle used in the AD DC workflow. Never proceed with a migration batch if the Assessment step shows Keystone or Neutron degraded.
- **SHOULD:** migrate a single low-criticality VM first as a canary before batch-migrating a group of similar VMs, per the canary-first pattern (`docs/glossary.md`) already established elsewhere in this platform — this is exactly the kind of repeated-pattern work canary-first is designed for.

## Dependencies

- `agents/vmware-architect/AGENT.md`: source-side VM state and export.
- `agents/backup-dr-architect/AGENT.md`: confirms the client's OpenStack backup role/automation (versioned per the client's own convention) covers the newly migrated instance once it's live — a migrated instance with no backup coverage is a silent gap that's easy to miss amid migration-focused validation.
- `agents/linux-platform-engineer/AGENT.md` or `agents/windows-infrastructure-engineer/AGENT.md`: guest-OS-level validation post-migration, depending on the migrated VM's OS.
- `agents/security-architect/AGENT.md`: if the migrated workload is PCI-scoped, confirm the OpenStack-side network segmentation and baseline image hardening meet the same bar the VMware-side environment did.

---

## Scenario A: VMware-to-OpenStack VM Migration

### Implementation
1. Confirm source VM prerequisites with `agents/vmware-architect/AGENT.md` (clean power-off, no pending snapshots, known VMware Tools status).
2. Export/convert the source disk image (VMDK → an OpenStack-compatible format, typically QCOW2 or RAW) using the estate's established conversion tooling.
3. Import the converted image into Glance: `openstack image create --disk-format qcow2 --file <converted-image> <name>`.
4. Confirm Neutron network mapping is correctly configured for the target network before instance creation — do not discover a missing network mapping after the instance is already created.
5. Create the instance from the imported image, explicitly specifying boot parameters (do not rely on Nova's defaults matching what the source VM needs) — this is the step most connected to the boot-failure issue class Scenario B below addresses, so treat boot device/driver configuration as a first-class step requiring explicit verification, not an assumption.
6. Boot the instance and immediately capture console output for review before declaring success: `openstack console log show <instance>`.

### Validation
- Instance reaches `ACTIVE` status with console log showing a clean boot sequence, not just a power state check.
- Network connectivity confirmed from the instance (not just "instance has an IP assigned" — an actual connectivity test).
- Application-level validation: whatever the workload actually does, confirm it does that, not just that the OS booted.
- Data integrity spot-check: for the specific concern named in `agents/openstack-architect/AGENT.md`'s escalation rules, confirm a representative sample of data on the migrated instance matches the source (checksum comparison on a few critical files, or an application-level record count check) before considering the migration validated.

### Rollback
- Source VM remains powered off but intact until burn-in completes (per the MUST rule above) — rollback is simply powering the source VM back on and deleting/investigating the failed migrated instance. **Clean rollback available**, classified per `templates/rollback-plan.md`, contingent entirely on the MUST rule being followed (source VM not yet decommissioned).

---

## Scenario B: Instance Boot-Failure Diagnosis

This scenario directly addresses the boot-failure issue class named in `agents/openstack-architect/AGENT.md` Responsibility #1. Use this when Scenario A's Step 6 validation fails, or when investigating a previously-migrated instance retroactively found to have boot issues.

### Implementation — diagnostic sequence (in order, per `agents/openstack-architect/AGENT.md`'s Decision Framework: diagnose from OpenStack-side evidence first)
1. **Console log first** — `openstack console log show <instance>` is the fastest signal for boot failures. Look specifically for: missing driver messages (indicates a VirtIO driver mismatch from the conversion), boot device errors (indicates incorrect boot order surviving conversion), filesystem mount failures (can indicate image format/conversion corruption).
2. **Nova/Libvirt logs on the hosting compute node** — cross-check the console log against `/var/log/nova/nova-compute.log` and libvirt's own logs for errors at the hypervisor-management layer that wouldn't appear in the guest console (e.g. a failure to attach a Cinder volume).
3. **Image metadata verification** — confirm the Glance image's declared properties (`hw_disk_bus`, `hw_vif_model`, etc.) actually match what the converted image needs; a mismatch here is a common, specific cause of the "missing driver" boot failure pattern.
4. **Only after Steps 1-3**, if evidence doesn't point to a destination-side configuration issue, loop in `agents/vmware-architect/AGENT.md` to check whether the source-side export itself was clean — per the Decision Framework, don't default to blaming the source without destination-side evidence pointing that way first.

### Validation
- Root cause identified and stated explicitly (driver mismatch / boot order / image corruption / source-side export issue / other), not left as "fixed, cause unclear."
- Corrected instance boots cleanly and passes the same validation as Scenario A.
- If the root cause is a systemic image-conversion issue (not specific to this one instance), flag it as affecting the migration process itself — this should feed back into Scenario A's Implementation steps as a Lessons Learned update, not just fix the one instance in front of you.

### Rollback
- Not generally applicable — this scenario is itself a diagnostic/remediation exercise on an already-failed instance. If remediation attempts risk further corrupting the instance, fall back to Scenario A's rollback (source VM still available) and re-attempt migration once the systemic cause is understood, rather than continuing to patch a specific broken instance indefinitely.

### Escalation reminder
Per `agents/openstack-architect/AGENT.md`'s own escalation rules: if diagnosis at any point suggests the root cause implies **data integrity risk during conversion** (as opposed to a fixable boot-configuration issue), stop and escalate — verify no data was silently corrupted before considering any instance "successfully migrated" on the strength of a fixed boot process alone.

---

## Scenario C: Standalone OpenStack-Native Instance Lifecycle (Build / Resize / Decommission)

For instance lifecycle work not related to VMware migration — new OpenStack-native workloads.

### Implementation
1. **Build:** `openstack server create` from an existing, already-hardened Glance image (per `agents/security-architect/AGENT.md`-aligned baseline images, not an ad hoc image) with explicit flavor/network/security-group parameters.
2. **Resize:** `openstack server resize` — confirm target flavor capacity exists on some eligible host before initiating, and confirm the application tolerates the brief downtime resize requires.
3. **Decommission:** confirm no other system depends on the instance (check Neutron floating IP associations, any load balancer pool membership) before `openstack server delete`.

### Validation
- Build: instance reaches `ACTIVE`, passes the same console-log and connectivity checks as Scenario A.
- Resize: instance returns to `ACTIVE` at the new flavor, application validated functional post-resize.
- Decommission: confirm no orphaned Cinder volumes, floating IPs, or security group references remain after deletion.

### Rollback
- Build: delete the failed instance, no data loss risk since nothing depended on it yet.
- Resize: `openstack server resize revert` if within the revert window Nova provides; otherwise treat as no-rollback and re-resize.
- Decommission: not reversible once storage is reclaimed — confirm backup coverage (per Dependencies) before decommissioning anything with retained data value.

---

## Acceptance Criteria (all scenarios)

- [ ] Console log reviewed and confirmed clean for any instance boot/migration, not just power-state checked.
- [ ] Network connectivity and application-level function validated, not just OS-level boot success.
- [ ] For migrations: source VM retained until burn-in complete; data integrity spot-check performed.
- [ ] For boot-failure diagnosis: root cause stated explicitly, and systemic findings fed back into Scenario A as a process improvement, not just fixed locally.
- [ ] Backup coverage confirmed for any new/migrated instance with `agents/backup-dr-architect/AGENT.md`.
- [ ] Change record closed in the client's ITSM/CMDB platform with before/after evidence attached.

## Lessons Learned

To be populated after first production execution of each scenario — Scenario B in particular should feed confirmed systemic findings back into Scenario A's Implementation steps directly, per the pattern already established when Milestone 8's worked example fed a real gap back into the VMware ESXi workflow's Assessment section.
