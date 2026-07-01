# Worked Example: ESXi Host Upgrade — Failure and Rollback Path

This is a fictionalized but realistic worked example showing what happens when a change doesn't go cleanly — deliberately chosen to stress-test the platform's rollback and RCA templates against a genuine failure, complementing `examples/ad-dc-inplace-upgrade-walkthrough/WALKTHROUGH.md`, which showed a clean success. It follows `agents/vmware-architect/AGENT.md` executing Scenario B ("ESXi Host Upgrade, Rolling, Cluster-Aware") of `workflows/vmware-esxi-vcenter-upgrade-lifecycle/WORKFLOW.md`.

**Scenario:** A fictional cluster `PRD-CLUSTER-01` (3 hosts: `ESXI-01`, `ESXI-02`, `ESXI-03`) is being rolled from ESXi 7.0 to 8.0, one host at a time.

---

## Step 1 — Prerequisites and Assessment (per the workflow)

`vmware-architect` checks the Interoperability Matrix live: ESXi 8.0 confirmed compatible with the current Veeam Backup & Replication version and the Wazuh agent version in use — **this check passes**. HA/DRS admission control headroom confirmed sufficient to absorb one host at a time. VCSA is already on a compatible version (Scenario A completed in a prior change). Assessment: cluster healthy, safe to proceed.

## Step 2 — Change Request and Rollback Plan produced upfront

**Risk classification:** Medium — rolling upgrade with DRS absorbing load, one host at a time, cluster has spare capacity.

**Rollback Plan (`templates/rollback-plan.md`) classification, decided before implementation began:** *No rollback available* for the host itself, per the workflow's own Rollback section ("ESXi host upgrades generally do not support clean in-place rollback... mitigation is host-level: keep it in maintenance mode while troubleshooting"). **Forward-fix contingency stated explicitly in advance:** "If a host fails validation, it remains in maintenance mode (isolated from production workload) while troubleshooting continues; if unresolvable, a fresh ESXi 7.0 reinstall from the prior image restores the host, followed by a retry once the underlying issue is understood."

*This is the point worth noticing: the rollback plan's "No rollback available" classification, and its forward-fix contingency, were both decided and documented before anything went wrong — not improvised afterward under pressure.*

## Step 3 — Implementation begins, `ESXI-01` upgrades cleanly

`ESXI-01` enters maintenance mode, DRS evacuates its VMs to `ESXI-02`/`ESXI-03` successfully, upgrade to 8.0 completes, host exits maintenance mode, rejoins cluster healthy. Validation passes. Proceed to `ESXI-02`.

## Step 4 — `ESXI-02` upgrade fails validation

`ESXI-02` enters maintenance mode, DRS evacuates successfully, upgrade begins — but post-upgrade, the host fails to reconnect to vCenter cleanly; `Get-VMHost` shows it in a "Not Responding" state, and management network connectivity is intermittent.

**Trigger condition met** (per the Rollback Plan's own "Trigger Conditions" field, filled in during Step 2: *"If the host does not reach Connected state within 30 minutes of exiting upgrade, or shows management network instability, do not exit maintenance mode or attempt to return VM load to this host."*). The agent does not force the host into service.

## Step 5 — Forward-fix contingency executed

Per the pre-agreed contingency: `ESXI-02` remains in maintenance mode (isolated — no production workload at risk). Diagnosis identifies a management vmkernel port configuration that didn't correctly migrate during the upgrade (a known category of issue when custom vSwitch configurations predate the upgrade). Rather than a blind reinstall, the specific network configuration is corrected, and the host is re-tested.

**If that correction had not worked:** the pre-documented fallback — fresh ESXi 7.0 reinstall from the prior image — would have been executed, and `ESXI-02` would have re-entered the cluster at the prior version, with the upgrade for that specific host rescheduled after root cause is fully understood, not retried blind.

**In this example, the network configuration fix resolves it.** `ESXI-02` reconnects cleanly, exits maintenance mode, DRS rebalances. Validation now passes.

## Step 6 — RCA produced (`templates/rca.md`)

| Field | Value |
|---|---|
| Symptom | `ESXI-02` failed to reconnect to vCenter after ESXi 8.0 upgrade; management network intermittent |
| Root cause | Custom vmkernel port configuration (predating the upgrade) did not correctly migrate during the 7.0 → 8.0 upgrade process |
| Contributing factor | The pre-upgrade Assessment step confirmed cluster/HA/DRS health but did not specifically audit custom vSwitch/vmkernel configurations for upgrade compatibility — this is a genuine gap, not just bad luck |
| Resolution | Corrected vmkernel port configuration manually; host re-tested and passed validation |
| Preventive action | **Update `workflows/vmware-esxi-vcenter-upgrade-lifecycle/WORKFLOW.md` Scenario B Assessment step** to explicitly include an audit of custom vSwitch/vmkernel configurations against the target version's known compatibility notes, before beginning host upgrades — owner: `vmware-architect`, target: before next production ESXi upgrade cycle |

## Step 7 — Lessons Learned fed back into the workflow (per the standard pattern)

This is the step that closes the loop and is why RCAs in this platform explicitly reference back to the owning workflow document rather than living as standalone records: the workflow's Assessment section was found to have a real gap, and the fix belongs in the workflow itself so the *next* engineer running this procedure benefits, not just this one.

---

## What this example demonstrates

1. A "No rollback available" classification isn't a gap in planning — it's a valid, explicit classification with its own required forward-fix contingency, decided and documented *before* execution, exactly as `templates/rollback-plan.md` requires.
2. Trigger conditions defined in advance ("if the host doesn't reconnect within 30 minutes...") meant the decision to stop and not force the host into service was mechanical, not an improvised judgment call made under pressure during the incident.
3. The RCA's preventive action targets the workflow document itself, not just a one-off note — this is how the platform is meant to improve over real executions rather than repeating the same gap on the next similar change.
4. Contrasted with the first worked example (clean swing migration success), this shows the platform's templates hold up under an actual failure, not just the easy path.
