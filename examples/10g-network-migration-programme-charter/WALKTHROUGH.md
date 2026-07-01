# Worked Example: 10G Network Migration Programme Charter

This is a fictionalized but realistic worked example completing `templates/programme-charter.md` for the 10G network migration programme referenced throughout this platform (`agents/network-architect/AGENT.md`'s named responsibility, spanning Baines DC, Pegasus DC, and Telone DC). It's the third worked example, and the first to demonstrate the programme-charter artifact specifically — the first two examples (AD DC swing migration, ESXi upgrade failure/rollback) both operated at the single-change scale; this one shows the scale above that, per the `docs/glossary.md` distinction between change, workflow, and programme.

---

## Programme Header

| Field | Value |
|---|---|
| Programme name | 10G Network Migration |
| Sponsor | CIO |
| Programme owner | `agents/network-architect/AGENT.md` |
| Start date | 2026-07-01 (fictional) |
| Target completion / hard deadline | No externally-imposed hard deadline (unlike the EOL elimination programme's Windows Server 2016 Extended Support date) — driven by capacity/performance need rather than a vendor support cutoff. State this explicitly rather than inventing urgency that isn't there. |
| Status | Planning |

## Business Driver

Current 1G inter-DC and intra-DC links are approaching capacity limits as VM density and backup replication traffic (Veeam backup copy jobs between sites) grow — this is a capacity-driven programme, not a compliance-driven one, which changes how it should be sequenced relative to genuinely deadline-bound work like the EOL elimination programme.

## Scope

### In scope
- Core switching upgrade to 10G at Baines DC, Pegasus DC, and Telone DC.
- Inter-DC link upgrades where current links are the binding capacity constraint.
- Coordination with dependent workstreams whose traffic patterns this capacity increase is meant to serve (backup replication, VM migration/vMotion traffic, OpenStack migration traffic).

### Out of scope
- End-host NIC upgrades (tracked separately, as a dependency rather than in-programme scope — see Dependencies below).
- Firewall/security appliance replacement (Fortinet/SonicWall estate) — not part of this specific capacity programme unless a specific appliance is found to be a bottleneck, in which case it would be raised as a programme risk, not silently absorbed into scope.

## Workstreams

| Workstream | Owning agent | Workflow(s) used | Target completion | Status |
|---|---|---|---|---|
| Baines DC core switching upgrade | `agents/network-architect/AGENT.md` | No dedicated network-hardware-upgrade workflow exists yet in `workflows/` — this programme's execution would itself be a strong candidate to produce one, per the pattern established elsewhere in this platform of building workflows from real recurring work | TBD | Planning |
| Pegasus DC core switching upgrade | `agents/network-architect/AGENT.md` | (as above) | TBD | Planning |
| Telone DC core switching upgrade | `agents/network-architect/AGENT.md` | (as above) | TBD | Planning |
| Inter-DC link capacity upgrade | `agents/network-architect/AGENT.md` | (as above) | TBD | Planning |

*Note on the missing workflow reference above: this is left visible deliberately rather than papering over it, since it demonstrates something real — not every programme starts with its execution workflow already built. This is itself a finding this example surfaces: see "What this example demonstrates" below.*

## Dependencies Between Workstreams

- Inter-DC link capacity upgrade should follow at least one DC's core switching upgrade being complete and validated, rather than upgrading the link and the endpoint switching simultaneously — mirrors the canary-first pattern (`docs/glossary.md`) already established elsewhere in this platform: prove the pattern works at one site before committing to the link upgrade that depends on both ends being ready.
- Coordinate scheduling with `agents/backup-dr-architect/AGENT.md` — backup replication traffic is one of the drivers for this programme, so switching maintenance windows should avoid colliding with backup job schedules, not just avoid business-hours impact generally.
- Coordinate with `agents/openstack-architect/AGENT.md` — the active VMware-to-OpenStack migration work also depends on inter-DC bandwidth for any cross-site migration traffic; sequencing should avoid both major programmes contending for the same link capacity during their respective critical windows.

## Risk Register

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|
| Core switching upgrade at a DC causes an unplanned outage affecting hosted production workloads | Medium | High | Canary-first: complete and validate Baines DC (lowest apparent risk site, fictional assumption for this example) before proceeding to Pegasus/Telone | `network-architect` |
| No dedicated workflow exists for this programme's core execution pattern, increasing risk of inconsistent execution across the three DCs | Medium | Medium | Author a `workflows/network-core-switching-upgrade/WORKFLOW.md` (or equivalent) after or during the first DC's execution, capturing what was actually done, per this platform's established growth pattern | `network-architect` |
| Programme timeline contention with the EOL elimination programme and VMware-to-OpenStack migration for shared engineering capacity | Medium | Medium | Explicit capacity conversation with `agents/chief-infrastructure-engineer/AGENT.md` before committing target dates, rather than assuming all three programmes can run at full pace simultaneously | `chief-infrastructure-engineer` |

## Governance

- **Reporting cadence:** Monthly to CIO given no hard external deadline; would shift to more frequent if a workstream becomes blocking for a deadline-bound programme (EOL elimination, OpenStack migration).
- **Change approval:** Standard CAB for each DC's switching upgrade window, per `templates/change-request.md`.
- **Escalation path:** `agents/chief-infrastructure-engineer/AGENT.md` for cross-workstream/cross-programme conflicts, particularly capacity contention with other active programmes.

## Milestones

| Milestone | Target date | Dependent workstreams | Status |
|---|---|---|---|
| Baines DC switching upgrade complete and validated | TBD | Baines DC workstream | Planning |
| First inter-DC link upgrade complete | TBD | Baines DC workstream (dependency) | Planning |
| All three DCs complete | TBD | All workstreams | Planning |

## Compliance Framework Alignment

No specific PCI-DSS/ISO 27001 control is the direct driver here (this is capacity-driven, not compliance-driven, per the Business Driver section) — but any switching change touching segments in PCI-DSS scope should still be checked against Req. 1 segmentation requirements before execution, per `agents/network-architect/AGENT.md`'s standing responsibility, even though it's not the programme's originating driver.

## Post-Programme Review

Not yet applicable — programme is in Planning status in this fictional example.

---

## What this example demonstrates

1. **Not every programme charter starts with all its supporting workflows already built** — the Workstreams table above honestly shows "no dedicated workflow exists yet" rather than inventing one for the sake of a clean-looking example. This is itself the more useful demonstration: it shows the charter surfacing a real gap (missing execution workflow) as a programme risk, which is exactly what the Risk Register is for.
2. **Programme-level canary-first**: the Dependencies section applies the same canary-first pattern (`docs/glossary.md`) used at the change level elsewhere in this platform, but at programme scale — complete one site fully before the next, rather than parallelizing all three DCs immediately.
3. **Cross-programme capacity contention** is treated as a first-class programme risk, not an afterthought — this programme, the EOL elimination programme, and the OpenStack migration all compete for the same engineering capacity and site-level network capacity, and the charter says so explicitly rather than planning each programme as if it existed in isolation.
4. **Not every programme is compliance-driven** — this one is capacity-driven, and the charter states that plainly rather than reaching for a PCI-DSS/ISO 27001 justification that isn't the actual reason the work exists. `templates/programme-charter.md`'s Compliance Framework Alignment section correctly returns "not the driver, but still relevant to specific in-scope changes" rather than being forced into a compliance-first narrative.
