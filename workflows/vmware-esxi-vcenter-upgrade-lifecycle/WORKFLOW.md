# Workflow: VMware ESXi / vCenter Upgrade Lifecycle

**Owning agent(s):** VMware Architect (primary); Chief Infrastructure Engineer (for multi-cluster/multi-site programme sequencing); Backup & DR Architect (consulted for backup-software interoperability)
**Applies to:** vSphere 6.5 through 8.x (ESXi hosts and vCenter Server Appliance)
**Compliance frameworks referenced:** PCI-DSS v4.0 (Req. 6.3 — vulnerability management/patching; Req. 2 — secure configuration), ISO/IEC 27001:2022 (A.8.8 management of technical vulnerabilities), COBIT 2019 (BAI06), ITIL v4 (change enablement)

## Executive Summary

ESXi hosts and vCenter Server are the foundation every production VM in the VMware estate depends on. Upgrades are necessary (EOL/EOS avoidance, security patching, feature/interoperability requirements) but carry cluster-wide or estate-wide blast radius if mismanaged. This workflow covers the full lifecycle: pre-upgrade interoperability and health assessment, vCenter Server upgrade, ESXi host upgrade (rolling, cluster-aware), and post-upgrade validation — plus the decommission path for EOL hardware/hypervisor versions being retired outright rather than upgraded in place.

## Prerequisites (all scenarios)

- Administrative access to vCenter with sufficient privilege for the operation (host/cluster admin at minimum; Single Sign-On admin for vCenter appliance-level changes).
- **VMware Product Interoperability Matrix checked live** (not from memory or a cached document) for every product touching this environment: target ESXi/vCenter version against current backup software (Veeam) version, monitoring agents (Wazuh, Nagios/NRPE), and any third-party vCenter plugins.
- Current, verified vCenter Server Appliance (VCSA) backup (file-based backup via the VAMI, or image-level) confirmed restorable.
- Current, verified backups of all VMs on hosts being upgraded — coordinate with Backup & DR Architect to confirm backup jobs aren't scheduled to run during the maintenance window.
- HA/DRS admission control headroom confirmed sufficient to absorb one host at a time being placed in maintenance mode without violating failover capacity.
- Change record raised in the client's ITSM/CMDB platform (e.g. iTop, ServiceNow, or equivalent), validated against the client's own change-control validation criteria before CAB submission.
- Downtime/maintenance window confirmed with stakeholders if any workload cannot tolerate vMotion (e.g. VMs with passthrough devices, certain clustered workloads).

## Assessment (all scenarios)

```powershell
# Cluster and host health
Get-Cluster | Get-VMHost | Select Name, ConnectionState, PowerState, Version, Build
Get-Cluster | Select Name, HAEnabled, HAAdmissionControlEnabled, DrsEnabled, DrsAutomationLevel

# Current admission control headroom
(Get-Cluster).ExtensionData.Summary

# VMware Tools currency across VMs (affects post-upgrade compatibility)
Get-VM | Get-View | Select Name, @{N="ToolsStatus";E={$_.Guest.ToolsStatus}}

# Snapshot inventory (unexpected snapshots complicate host maintenance mode and vMotion)
Get-VM | Get-Snapshot | Select VM, Name, Created, SizeGB

# Custom vSwitch/vmkernel configuration audit — non-default port groups, custom vmkernel
# adapters, and non-standard MTU/VLAN settings should be recorded before upgrading, since
# custom networking configuration predating the target version is a known source of
# post-upgrade management-network reconnection failures (see
# examples/vmware-esxi-upgrade-failure-rollback/WALKTHROUGH.md for a worked failure case).
Get-VMHost | Get-VirtualSwitch | Select VMHost, Name, NumPorts, Mtu
Get-VMHost | Get-VMHostNetworkAdapter -VMKernel | Select VMHost, Name, IP, PortGroupName, Mtu

# vCenter/VCSA current version and health
Connect-VIServer <vCenterFQDN>
(Get-View ServiceInstance).Content.About | Select FullName, Version, Build
```

Baseline "healthy" = all hosts connected and responding, HA/DRS enabled with no faults, no unexpected long-lived snapshots, VMware Tools current across the majority of the estate, VCSA services all green in VAMI, and any custom vSwitch/vmkernel configuration explicitly recorded and cross-checked against the target version's known compatibility notes before proceeding. Resolve any of these before proceeding — an unhealthy cluster should not have an upgrade layered on top of unresolved issues.

## Risk Analysis (all scenarios)

- **Blast radius:** ranges from single-host (rolling upgrade with DRS/vMotion absorbing load) to full-cluster or full-datacenter outage if vCenter itself is unavailable mid-upgrade and something goes wrong on a host simultaneously. State explicitly where in this range the planned change sits.
- **Failure modes:** interoperability breakage with backup software or monitoring agents post-upgrade (most common and most avoidable failure — this is why the interoperability matrix check is a hard prerequisite, not optional); host failing to exit maintenance mode; VCSA upgrade failure leaving vCenter unavailable while hosts are mid-upgrade; DRS/HA misconfiguration surfacing only under the changed version's stricter validation.
- **MUST:** never begin an ESXi host upgrade on a cluster where vCenter itself is not current and healthy, since host-level operations become significantly harder to manage/troubleshoot without a healthy vCenter. Never upgrade a host with active VMs still running on it — evacuate first (vMotion or planned downtime). Never proceed with a version combination not confirmed in the interoperability matrix.
- **SHOULD:** upgrade vCenter before ESXi hosts (standard, vendor-recommended order) to ensure management/monitoring capability for the host upgrades that follow. Upgrade one host at a time in a rolling fashion, validating each before proceeding to the next, rather than batching multiple hosts simultaneously. Where a programme spans multiple clusters (e.g. an estate-wide ESXi version upgrade), treat this the same way — designate one cluster, or one host within the lowest-impact cluster, as the canary before rolling the change out estate-wide, mirroring the canary-first pattern in `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` and `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`. The per-host rolling approach within a single cluster already provides this discipline at the host level; this extends the same principle to the cluster/programme level.

## Dependencies

- Backup & DR Architect: confirm backup software version compatibility and pause/adjust backup schedules if needed during the window.
- Windows Infrastructure Engineer: if AD-integrated authentication (vCenter SSO with AD identity source) is in play, confirm no concurrent AD changes are scheduled that could compound troubleshooting complexity.
- Monitoring: confirm Nagios/NRPE and Wazuh agent compatibility with the target ESXi version, and expect/suppress alerts during planned maintenance-mode transitions to avoid alert fatigue obscuring a genuine issue.

---

## Scenario A: vCenter Server Upgrade

### Implementation
1. Confirm target vCenter version's interoperability with connected ESXi hosts, backup software, and plugins per the live Interoperability Matrix check.
2. Take a VCSA file-based backup immediately before starting (via VAMI, `https://<vcsa>:5480`), confirmed complete before proceeding.
3. Run the VCSA upgrade using the official upgrade ISO/installer — this deploys a new appliance and migrates configuration/data rather than upgrading in place on the same appliance.
4. Confirm all vCenter services report healthy post-upgrade (`vmon-cli --status` in the VCSA shell, or VAMI service status page).
5. Re-validate SSO identity sources, permissions, and any third-party plugin registrations, which can require re-registration after a vCenter upgrade.

### Validation
- vCenter UI accessible, all hosts show as connected in inventory.
- `(Get-View ServiceInstance).Content.About` confirms expected new version/build.
- All previously configured alarms, permissions, and identity sources present and functioning.
- Any registered plugins (backup software vCenter plugin, monitoring integrations) confirmed functional, not just installed.

### Rollback
- If the new VCSA appliance deployment fails validation, the old appliance (if not yet decommissioned as part of the migration-based upgrade approach) can be re-pointed to as the active vCenter. If using true in-place upgrade rather than the migration-based appliance approach, rollback is via VCSA backup restore — confirm which upgrade mechanism applies to the specific version jump before committing, since this materially changes the rollback story.

---

## Scenario B: ESXi Host Upgrade (Rolling, Cluster-Aware)

### Implementation
1. Confirm vCenter is current and healthy (Scenario A complete, if applicable) before starting host upgrades.
2. Select one host at a time. Enter maintenance mode: `Set-VMHost -VMHost <Host> -State Maintenance` — DRS will attempt to evacuate VMs automatically if fully automated; confirm evacuation completes before proceeding (manual vMotion for any VM that doesn't auto-evacuate, e.g. those with local-disk-dependent configurations).
3. Apply the ESXi upgrade (via vCenter Lifecycle Manager baseline/image, or manual ISO-based upgrade for standalone scenarios).
4. Exit maintenance mode once the upgrade completes and the host reports healthy: `Set-VMHost -VMHost <Host> -State Connected`.
5. Allow DRS to rebalance, or manually vMotion VMs back if using manual load balancing.
6. Repeat for the next host only after the previous host is confirmed fully healthy — do not batch multiple hosts into maintenance mode simultaneously.

### Validation
- Host shows target version/build in `Get-VMHost | Select Name, Version, Build`.
- Host exits maintenance mode cleanly and rejoins the cluster without HA/DRS faults.
- VMs that were running on the host prior to upgrade are healthy post-evacuation-and-return (spot-check network/storage connectivity, not just power state).
- Cluster-wide `Get-Cluster | Select Name, HAEnabled` and admission control state confirm no degradation.

### Rollback
- ESXi host upgrades generally do not support clean in-place rollback. The mitigation is host-level: if a host fails validation post-upgrade, keep it in maintenance mode (isolated from production workload) while troubleshooting, rather than exiting maintenance mode with a suspect host. For a genuinely failed upgrade, a fresh ESXi reinstall from the prior version's image is the practical rollback path — this is why evacuating the host fully before upgrading (rather than any workaround that leaves VMs on it) is mandatory, since a full reinstall is not compatible with any resident VMs.

---

## Scenario C: EOL Hardware / Hypervisor Retirement (Decommission, Not Upgrade)

For hosts being retired outright rather than upgraded — e.g. legacy Dell 11th-gen blade hardware reaching EOL, or a version so far behind that upgrade-in-place isn't a supported path and replacement hardware is being introduced instead.

### Implementation
1. Confirm replacement capacity (new hosts, or absorption capacity on remaining cluster members) is available and validated before removing the EOL host from service.
2. Evacuate all VMs via vMotion/Storage vMotion to remaining or replacement hosts.
3. Remove the host from the cluster in vCenter (`Remove-VMHost` after disconnecting), then physically decommission per hardware disposal procedure.
4. Update CMDB/asset inventory to reflect the retired hardware.

### Validation
- All VMs previously on the retired host(s) are running and healthy on their new host(s).
- Cluster HA/DRS admission control recalculated and confirmed sufficient with the reduced (or replaced) host count.
- CMDB updated, no orphaned host objects remain in vCenter inventory.

### Rollback
- Not generally applicable once hardware is physically decommissioned — this is why full evacuation and validation on the new hosts must be confirmed *before* physical decommission, treating that step as the point of no return.

---

## Acceptance Criteria (all scenarios)

- [ ] Interoperability Matrix check performed live and documented (not assumed) for every affected product combination.
- [ ] All hosts/vCenter report target version/build with no connection or configuration faults.
- [ ] HA/DRS admission control healthy with no faults post-change.
- [ ] No orphaned snapshots, no VMs stranded on evacuated hosts.
- [ ] Backup software and monitoring agent functionality confirmed post-upgrade, not just assumed compatible.
- [ ] Change record closed in the client's ITSM/CMDB platform with before/after evidence attached.
- [ ] VCSA/host backups captured pre-change and confirmed restorable.

## Lessons Learned

To be populated after first production execution of each scenario (vCenter upgrade / rolling host upgrade / EOL retirement) — track separately, since their failure patterns differ.
