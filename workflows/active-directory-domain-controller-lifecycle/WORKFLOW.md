# Workflow: Active Directory Domain Controller Lifecycle Management

**Owning agent(s):** Windows Infrastructure Engineer (primary); Chief Infrastructure Engineer (for multi-DC/multi-forest programme sequencing); Security Architect (for hardening/escalation scenarios)
**Applies to:** Windows Server 2012 R2 through 2022 domain controllers, single or multi-domain/multi-forest environments
**Compliance frameworks referenced:** PCI-DSS v4.0 (Req. 8 — identity/authentication; Req. 10 — logging), ISO/IEC 27001:2022 (A.8.2 privileged access, A.8.16 monitoring), COBIT 2019 (BAI06 — change management), ITIL v4 (change enablement, incident management)

## Executive Summary

Domain Controllers are the authentication and identity backbone of the environment — every downstream system that trusts AD (file services, VPN, applications, PCI-scoped systems requiring Req. 8 compliance) depends on their availability and integrity. This workflow covers the **full DC lifecycle**, not a single procedure: building a new DC, assessing DC health, upgrading a DC's OS in place, replacing a DC (swing migration), transferring or seizing FSMO roles, troubleshooting replication, decommissioning a DC, and recovering a DC or the directory itself after failure or corruption. Each scenario shares a common risk posture (DC failure has domain-wide blast radius) but has distinct procedures, so this document is organized as one framework with scenario-specific implementation paths.

## Prerequisites (all scenarios)

- Administrative access: Domain Admins (or delegated equivalent) for the target domain; Enterprise Admins required for forest-wide operations (schema changes, cross-domain FSMO seizure).
- Current, verified backup of System State (or full VM-level backup with application-consistent quiescing) for every DC in the affected domain, confirmed restorable — not just "job completed successfully."
- Documented current AD topology: forest/domain structure, site topology, FSMO role holders, DNS configuration (AD-integrated zone scope, forwarders), replication schedule.
- Change record raised in iTop, validated against `zss-change-validator` criteria before submission to CAB.
- Confirmation of maintenance window, with downstream-system owners notified if the change carries any authentication-availability risk.
- `dcdiag`, `repadmin`, and (for OS upgrades) the target OS media/ISO available and its hash verified.

## Assessment (all scenarios — run before selecting a scenario-specific path)

Before doing anything, establish baseline DC and replication health. This determines whether it's safe to proceed with *any* of the scenarios below — a DC with existing replication failures should not be upgraded, demoted, or have roles transferred onto it until the underlying issue is understood.

```powershell
# Overall DC health
dcdiag /v /c /d /e /s:<DCName> > dcdiag_<DCName>_<date>.log

# Replication status across all DCs in the domain
repadmin /replsummary
repadmin /showrepl * /csv > replsummary_<date>.csv

# FSMO role holders
netdom query fsmo

# AD Sites and Services topology sanity check
Get-ADReplicationSite -Filter *
Get-ADReplicationSubnet -Filter *

# SYSVOL replication health (FRS or DFSR)
dfsrmig /getmigrationstate   # if DFSR
```

Baseline "healthy" = zero errors in `dcdiag`, `repadmin /replsummary` showing 0 fails across all partners, SYSVOL replication current. Any failures found here must be root-caused and resolved (or explicitly risk-accepted with compensating controls documented) before proceeding to implementation.

## Risk Analysis (all scenarios)

- **Blast radius:** DC-level issues can range from single-site authentication slowness (one DC down, others absorbing load) to domain-wide outage (last DC in a domain, or FSMO role holder unavailable with no standby). Always state which end of this range applies before proceeding.
- **Failure modes common across scenarios:** replication failure post-change, DNS resolution breakage (especially if the DC is also a DNS server — verify client resolver settings before removing any DC from service), Kerberos ticket issues following time sync or FSMO disruption, SYSVOL/GPO replication divergence.
- **MUST:** never demote or decommission the last DC in a domain without an explicit, separately-approved domain-retirement plan. Never let the PDC Emulator role sit on an unhealthy or soon-to-be-decommissioned DC. Never proceed with any state-changing step while `repadmin /replsummary` shows active failures, unless the change itself is the remediation for that failure.
- **SHOULD:** maintain at least two DCs per domain per site with WAN connectivity for redundancy; keep FSMO roles on infrastructure with headroom for planned maintenance elsewhere.

## Dependencies

- Downstream systems relying on this DC as an authentication or DNS source (check `Get-DnsServerResourceRecord` on client-facing DNS scopes and any statically configured DNS entries pointing at the DC's IP).
- Time sync hierarchy — the PDC Emulator is normally the domain's authoritative time source; any FSMO transfer affecting the PDC Emulator role has a time-sync dependency to account for.
- Certificate Services, if AD CS is co-hosted or dependent on this DC for enrollment.
- Any workflow already in flight against the same forest/domain (e.g. do not run a schema-affecting operation concurrently with another DC's OS upgrade).

---

## Scenario A: New DC Build / Promotion

### Implementation
1. Provision the server (VM or physical) per `standards/` baseline image, patched to current baseline before promotion.
2. Statically configure IP, and set DNS to point to an existing healthy DC first, itself second (never itself-only on a fresh promotion).
3. Install the AD DS role: `Install-WindowsFeature AD-Domain-Services -IncludeManagementTools`.
4. Promote: `Install-ADDSDomainController` with explicit `-SiteName`, `-DatabasePath`, `-LogPath`, `-SysvolPath`, `-InstallDns` as appropriate — never accept implicit defaults for a production build.
5. Confirm the correct AD site is assigned (misassignment causes clients to authenticate cross-site unnecessarily).

### Validation
- `dcdiag /v` clean on the new DC.
- `repadmin /showrepl` confirms inbound/outbound replication with all expected partners within one replication cycle.
- New DC appears correctly in `Get-ADDomainController -Filter *` and in the correct AD site.
- SYSVOL/GPO content matches other DCs (`robocopy /L` comparison or DFSR health check).

### Rollback
- If promotion fails partway, `Uninstall-ADDSDomainController -DemoteOperationMasterRole -Force` (or manual metadata cleanup via `ntdsutil` if the object is orphaned) before retrying. Do not leave a partially-promoted DC in the environment.

---

## Scenario B: In-Place OS Upgrade (e.g. Server 2016 → 2022)

### Implementation
1. Confirm forest/domain functional level supports the target OS as a DC (check Microsoft's supported upgrade matrix for the specific version pair — do not assume all upgrade paths are supported in-place; some require a swing migration instead).
2. Transfer any FSMO roles held by this DC to another healthy DC *before* the upgrade, unless the upgrade path is confirmed safe with roles in place — prefer moving them off regardless, to reduce blast radius (see Scenario D).
3. Verified System State + VM-level backup immediately before the maintenance window.
4. Run OS upgrade (in-place setup.exe upgrade, or `Get-WindowsFeature`/DISM-based path depending on version pair).
5. Post-upgrade: confirm AD DS and DNS Server roles reactivated correctly, `dcdiag` clean.

### Validation
- Same checks as Scenario A validation, plus explicit confirmation the DC functional level metadata is correct post-upgrade (`Get-ADDomainController | Select OperatingSystem, OperatingSystemVersion`).

### Rollback
- In-place OS upgrades on DCs have **no clean rollback** once committed — this is why FSMO evacuation and verified backups are mandatory prerequisites, not recommendations. If the upgrade fails or produces instability, the forward path is restoring from the pre-upgrade VM snapshot/backup, not attempting to downgrade in place.

---

## Scenario C: DC Replacement (Swing Migration)

Used when in-place upgrade isn't supported for the OS version pair, or when replacing underlying hardware/VM platform simultaneously (e.g. migrating a DC from VMware to OpenStack).

### Implementation
1. Build a new DC on the target OS/platform per Scenario A.
2. Allow full replication convergence (verify via `repadmin /showrepl`) before touching the old DC.
3. Transfer FSMO roles from the old DC to the new one (see Scenario D) once the new DC is confirmed healthy.
4. Update DNS/DHCP scope options, statically configured clients, and any application configuration pointing at the old DC's IP/hostname.
5. Demote the old DC (Scenario F) only after a burn-in period confirming no dependency was missed (monitor authentication logs and DNS query patterns against the old DC's IP during this window).

### Validation
- No unexpected authentication failures or DNS query volume against the retiring DC's IP during the burn-in window.
- New DC carries all previously-held FSMO roles, confirmed via `netdom query fsmo`.

### Rollback
- Because the old DC is kept running and untouched until burn-in completes, rollback is simply: do not demote the old DC, redirect clients back if issues surface. This scenario is inherently lower-risk than in-place upgrade for exactly this reason — prefer it when the OS jump is large or the upgrade path is unsupported.

---

## Scenario D: FSMO Role Transfer / Seizure

### Implementation — Transfer (source DC healthy and available)
```powershell
Move-ADDirectoryServerOperationMasterRole -Identity <TargetDC> -OperationMasterRole SchemaMaster,DomainNamingMaster,PDCEmulator,RIDMaster,InfrastructureMaster
```
Transfer roles individually or in a planned group depending on maintenance scope — do not move all five roles as a reflex if only one needs to move for the task at hand.

### Implementation — Seizure (source DC unavailable/failed)
**MUST** only be used when the source DC is confirmed unrecoverable — a seized role must never be brought back online on the original holder, or USN rollback/duplicate-role corruption results.
```powershell
Move-ADDirectoryServerOperationMasterRole -Identity <TargetDC> -OperationMasterRole <Role> -Force
```
Follow with metadata cleanup (`ntdsutil` → `metadata cleanup`) to remove the failed DC's object from AD, and manual DNS record cleanup if it was also a DNS server.

### Risk Analysis specific to this scenario
- Seizing the RID Master or PDC Emulator without confirming the original holder is truly gone risks two DCs believing they hold the same role — this is a severe, hard-to-reverse corruption scenario. Escalate to a human decision-maker (see platform-wide escalation rules) before seizing if there is any ambiguity about the original holder's true state.

### Validation
- `netdom query fsmo` confirms expected holder for every role.
- Post-transfer replication check to confirm the change propagated.

### Rollback
- Transfers can be reversed by transferring back. Seizures cannot be safely "rolled back" by bringing the old holder online — the rollback path for a seizure is metadata cleanup plus monitoring, not restoration of the prior state.

---

## Scenario E: Replication Troubleshooting

### Implementation
1. Identify the failing partnership: `repadmin /showrepl * /csv` and filter for non-zero fail counts.
2. Common root causes to check in order: DNS resolution between DCs (`nslookup` each DC's DNS records from the other), network connectivity/firewall (AD requires a specific port set — RPC dynamic range, LDAP 389/636, Kerberos 88, SMB 445 — verify none are being silently dropped, matching the pattern seen previously with stateful firewalls dropping idle LDAP connections), time skew (Kerberos tolerates a default 5-minute skew — check `w32tm /monitor`), USN rollback (check event log for Event ID 2095), lingering objects (if replication has been broken longer than tombstone lifetime).
3. Apply the specific fix for the identified root cause rather than a generic `repadmin /replicate` retry, which will not fix an underlying connectivity or DNS issue.

### Validation
- `repadmin /replsummary` returns to zero fails across all partnerships, sustained across at least two full replication cycles (not just an immediate manual-trigger success).

### Rollback
- Not generally applicable — this scenario is itself a remediation. If a specific fix (e.g. a firewall rule change) doesn't resolve the issue, revert that specific change and continue diagnosis rather than leaving speculative changes in place.

---

## Scenario F: DC Decommission / Demotion

### Implementation
1. Confirm this is not the last DC in the domain (see MUST rule above) and does not hold any FSMO role (transfer first — Scenario D).
2. Confirm no static DNS/DHCP/application configuration still points at this DC.
3. `Uninstall-ADDSDomainController -DemoteOperationMasterRole -RemoveDNSDelegation` (or equivalent parameters for the topology).
4. Confirm metadata cleanup completed automatically; if not, manual `ntdsutil` cleanup.
5. Decommission the underlying VM/hardware only after confirming AD object removal and DNS record cleanup are both complete.

### Validation
- DC no longer appears in `Get-ADDomainController -Filter *`.
- No orphaned objects in AD Sites and Services or DNS.
- `repadmin /replsummary` clean across remaining DCs.

### Rollback
- If demotion fails partway, do not force-remove the underlying VM — resolve the demotion failure first (commonly a replication or connectivity issue) or fall back to forced metadata cleanup with the DC treated as failed (see Scenario D seizure path) if it's genuinely unrecoverable.

---

## Scenario G: Disaster Recovery — Restoring a Failed DC or the Directory

### Implementation
- **Single DC lost, others healthy:** do not restore — simply build a replacement (Scenario A) and clean up the failed DC's metadata (Scenario D seizure-path cleanup) if it can't be gracefully demoted.
- **Authoritative restore needed** (e.g. a container of OUs/objects deleted domain-wide and must be restored across all DCs): restore System State on one DC in Directory Services Restore Mode (DSRM), mark the relevant subtree authoritative with `ntdsutil` (`authoritative restore` context), then allow replication to propagate the restored state outward. Never mark a restore authoritative unless the deletion genuinely needs to be reversed domain-wide — a non-authoritative restore is sufficient for simply recovering a failed DC's own database.
- **Full forest/domain loss:** follow a forest recovery sequence starting from the most recent verified System State backup of a DC holding the Schema Master role, in strict order per Microsoft's forest recovery guidance — this is the highest-severity scenario in this workflow and should trigger escalation to a human decision-maker before execution, not proceed autonomously.

### Validation
- `dcdiag` and `repadmin` clean post-restore.
- Spot-check that restored objects (in an authoritative restore) are present and correctly replicated to all DCs.
- Confirm SYSVOL/GPO content consistency post-restore.

### Rollback
- DSRM restores are inherently a rollback action already. If an authoritative restore is later found to be wrong in scope (too much or too little marked authoritative), the corrective action is a further, more precisely scoped restore — not a reversal of the first.

---

## Acceptance Criteria (all scenarios)

- [ ] `dcdiag /v` clean on all DCs in the affected domain.
- [ ] `repadmin /replsummary` shows zero failures, sustained across at least two replication cycles.
- [ ] FSMO role holders confirmed and documented (`netdom query fsmo`).
- [ ] No orphaned AD or DNS objects remain from the change.
- [ ] Downstream-system owners confirm no authentication/DNS disruption observed.
- [ ] Change record closed in iTop with evidence attached (before/after `dcdiag`/`repadmin` output).
- [ ] Backup of post-change state captured and verified restorable.

## Lessons Learned

To be populated after first production execution of each scenario. Track separately per scenario (Build / Upgrade / Swing / FSMO / Replication / Decommission / DR) since they have distinct failure patterns — do not merge into one undifferentiated notes section.
