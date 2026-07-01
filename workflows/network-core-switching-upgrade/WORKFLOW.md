# Workflow: Network Core Switching Upgrade

**Owning agent(s):** Network Architect (primary); Chief Infrastructure Engineer (programme-level sequencing across DCs); Security Architect (PCI-DSS segmentation impact); Backup & DR Architect and OpenStack Architect (dependent traffic scheduling)
**Applies to:** Core switching infrastructure across Baines DC, Pegasus DC, and Telone DC — this workflow is vendor-aware given the estate's mixed environment (Juniper, Cisco, Mellanox), with vendor-specific implementation detail nested inside the relevant scenario steps
**Compliance frameworks referenced:** PCI-DSS v4.0 (Req. 1 — network security controls/segmentation), ITIL v4 (change enablement), COBIT 2019 (BAI06)

## Executive Summary

This workflow was identified as a genuine gap by `examples/10g-network-migration-programme-charter/WALKTHROUGH.md`, which honestly surfaced that the 10G migration programme's core execution pattern had no dedicated workflow behind it — this document closes that gap. It covers the site-level core switching upgrade procedure (the per-DC unit of work inside the broader 10G migration programme), applying the same canary-first discipline used elsewhere in this platform, and the same explicit multi-vendor framing `agents/network-architect/AGENT.md` requires given the estate runs Juniper, Cisco, and Mellanox switching.

## Prerequisites

- Administrative access to the target switching platform (Juniper Junos, Cisco IOS/IOS-XE/NX-OS, or Mellanox/NVIDIA switch OS, depending on the site/link in question — **state which explicitly**).
- Current running/startup configuration backed up and confirmed retrievable (not just assumed backed up by a general config-management tool — verify a specific, timestamped copy exists for this specific change).
- Confirmed maintenance window coordinated with `agents/backup-dr-architect/AGENT.md` (avoid backup replication job schedules) and `agents/openstack-architect/AGENT.md` (avoid active cross-site migration traffic windows), per the Dependencies section of `examples/10g-network-migration-programme-charter/WALKTHROUGH.md`.
- Change record raised in iTop, validated against `zss-change-validator` criteria before CAB submission.
- Physical hardware (new 10G-capable switching hardware, optics, cabling) confirmed on-site and pre-validated (power-on self-test, firmware version check) before the maintenance window — do not discover a DOA unit during the change window itself.

## Assessment

Before touching production switching, establish current-state baseline:

```text
# Juniper (Junos)
show interfaces terse
show vlans
show spanning-tree bridge
show lacp interfaces

# Cisco (IOS/IOS-XE)
show interfaces status
show vlan brief
show spanning-tree summary
show etherchannel summary

# Mellanox (per switch OS in use — Cumulus Linux or Onyx)
net show interface     # Cumulus
show interfaces        # Onyx
```

Record current port-to-VLAN mapping, spanning-tree role/state per port, and LACP/port-channel membership for every port that will be affected — this mapping is what the post-cutover validation checks against, and reconstructing it after the fact if not captured beforehand is far harder than capturing it up front.

Baseline "healthy" = no unexpected spanning-tree topology changes in recent history, no interfaces in an unexpected error-disabled state, LACP bundles fully up on all expected member links. Resolve any pre-existing instability before layering a hardware change on top of it.

## Risk Analysis

- **Blast radius:** ranges from a single non-critical access port (low) to core/distribution switching serving an entire DC (very high — potentially isolates every host at that site simultaneously). State explicitly which applies for the specific change; **core switching replacement is presumptively high blast radius unless proven otherwise**, not the reverse.
- **Failure modes:** spanning-tree reconvergence causing a transient (or, if misconfigured, sustained) loop or blackhole; VLAN/trunk misconfiguration on the new hardware silently dropping traffic for a subset of VLANs while others work (the most dangerous failure mode, since partial failure is often not immediately obvious); LACP/port-channel mismatch between the new switch and connected hosts/hypervisors causing degraded (not down) throughput that's easy to miss in a quick post-change check.
- **MUST:** never cut over core switching for an entire DC in a single step without first proving the pattern on a lower-impact site or a specific low-criticality link — this is the canary-first pattern (`docs/glossary.md`) applied at the network-hardware level, mirroring the retrofit already applied to the AD DC and VMware workflows. Never proceed without the pre-capture of current VLAN/spanning-tree/LACP state described in Assessment, since validation without a baseline to compare against is unreliable.
- **SHOULD:** stage and pre-configure the new switch's full intended configuration (VLANs, trunk/access ports, LACP, spanning-tree priority) before the maintenance window, so the window itself is primarily a physical cutover and verification exercise rather than live configuration authoring under time pressure.

## Dependencies

- `agents/backup-dr-architect/AGENT.md`: backup replication traffic scheduling, per the 10G programme charter's stated driver.
- `agents/openstack-architect/AGENT.md`: cross-site VM/data migration traffic scheduling.
- `agents/vmware-architect/AGENT.md` and `agents/windows-infrastructure-engineer/AGENT.md`: any DC-level maintenance already scheduled that this change should avoid colliding with (per the general principle of not running multiple major changes against the same site simultaneously without explicit coordination).
- `agents/security-architect/AGENT.md`: confirm no PCI-DSS-scoped segment's VLAN/trunk configuration is inadvertently altered during the cutover.

---

## Scenario A: Single-Site Core Switching Upgrade (the canary site)

### Implementation
1. Stage and pre-configure the new switch(es) offline against the recorded baseline (VLANs, trunking, LACP, spanning-tree priority matching or deliberately superseding the old configuration — state which and why).
2. Physically cable the new switch in parallel where feasible (i.e. don't disconnect the old switch until the new one's basic connectivity is confirmed), enabling a faster abort path if something is wrong before traffic is cut over.
3. Migrate one link/port-group at a time where the topology allows a phased cutover, validating each phase before proceeding to the next — this is the within-site application of the same canary-first discipline used at the site level across the programme.
4. Once all links are migrated and validated, decommission/remove the old switch from active service (but do not physically remove it from the rack until the burn-in period below completes).

### Validation
- Every VLAN/trunk present on the old switch confirmed present and correctly tagged on the new switch, checked against the Assessment-phase baseline capture, not just spot-checked.
- Spanning-tree topology stable (no unexpected topology change events) for a sustained period post-cutover, not just immediately after.
- LACP/port-channel bundles confirmed fully up on all expected member links — a bundle showing partial membership (e.g. 1 of 2 links up) is a failure even though it may not show as fully down.
- End-to-end connectivity tests from representative hosts on each affected VLAN, not just switch-level interface status.
- 10G throughput actually validated (e.g. an iperf test between hosts on the new links), not just link-speed negotiation status — a link negotiating at 10G is not the same as actually passing 10G-capable throughput without errors.

### Rollback
- If the parallel-cabling approach from Step 2 was followed, rollback is reconnecting hosts/links back to the old switch, which remains physically present and powered until burn-in completes — mirroring the swing-migration and DC-replacement pattern's inherent lower risk compared to a single-step, no-fallback cutover.
- **Time cost:** should be minutes (re-patching cables) if parallel cabling was used, versus potentially hours if the old switch was already decommissioned/removed — this is the concrete argument for why Step 4's "do not physically remove until burn-in completes" instruction matters operationally, not just as a formality.

---

## Scenario B: Inter-DC Link Capacity Upgrade

Follows Scenario A's site-level upgrade being complete and validated at both ends, per the Dependencies section of `examples/10g-network-migration-programme-charter/WALKTHROUGH.md` — this scenario should not be attempted against a site whose core switching upgrade (Scenario A) hasn't already been validated, since the link upgrade depends on both endpoints being ready.

### Implementation
1. Confirm both endpoint sites have completed Scenario A and are stable (post-burn-in).
2. Coordinate a joint maintenance window across both sites (not just one), since testing a link upgrade meaningfully requires both ends validated together.
3. Cut over the inter-DC link to the new capacity/hardware, following the same parallel-path-where-feasible principle as Scenario A if the physical topology allows a secondary path during cutover.
4. Validate throughput and latency across the upgraded link under representative load (backup replication traffic and/or migration traffic, coordinated with the relevant dependent agent per the Dependencies section).

### Validation
- Link throughput validated under real dependent traffic (backup replication or migration traffic), not just a synthetic test — this directly closes the loop on the programme's stated business driver (capacity for exactly this kind of traffic).
- No increase in latency or packet loss compared to pre-upgrade baseline for any traffic that was already flowing acceptably on the old link.

### Rollback
- Depends entirely on whether a secondary/redundant path exists during cutover. If it does, rollback is reverting to that path. If the link being upgraded is the only path between the two sites (a genuine risk worth flagging explicitly if true), this is a **No rollback available** classification per `templates/rollback-plan.md`, requiring an explicit forward-fix contingency defined before starting — do not discover this classification question during the maintenance window itself.

---

## Acceptance Criteria (all scenarios)

- [ ] Vendor platform (Juniper/Cisco/Mellanox) stated explicitly throughout the change record.
- [ ] Pre-change VLAN/spanning-tree/LACP baseline captured and used as the actual comparison point for validation, not just referenced generically.
- [ ] Canary-first applied: this is not the first site/link in the programme to receive this change, or if it is, that's stated explicitly as the deliberate canary with extra validation rigor applied.
- [ ] Throughput validated under real or representative load, not just link-speed negotiation.
- [ ] Old hardware/path retained until burn-in period completes, not decommissioned immediately at cutover.
- [ ] Change record closed in iTop with before/after evidence attached, including the captured baseline comparison.

## Lessons Learned

To be populated after the first production execution (expected to be the canary site under the 10G migration programme) — track any vendor-specific gotchas (Juniper vs. Cisco vs. Mellanox) separately, since a lesson learned on one platform may not transfer to another, per this workflow's own multi-vendor framing.
