# Changelog

All notable changes to this platform are tracked here by milestone.

## [Milestone 1] - 2026-07-01

### Added
- Repository scaffold: full top-level directory structure (`agents/`, `workflows/`, `templates/`, `standards/`, `knowledge/`, `scripts/`, `playbooks/`, `policies/`, `checklists/`, `docs/`, `examples/`, `tests/`, `tools/`, `automation/`, `diagrams/`, `training/`).
- `README.md` — platform overview, design principles, structure.
- `CLAUDE.md` — operating instructions for AI assistants working in this repository.
- `LICENSE` (MIT).
- `CONTRIBUTING.md` — contribution rules and review checklist.
- First specialist agent: `agents/chief-infrastructure-engineer/AGENT.md` — the orchestrating agent that routes work to other specialists and owns overall engagement quality.

### Next milestone
- Agent and workflow templates (`agents/_TEMPLATE.md`, `workflows/_TEMPLATE.md`) to formalize the structure referenced in `CONTRIBUTING.md`.
- Second specialist agent: VMware Architect (given active production relevance).
- First reusable workflow: AD Domain Controller upgrade (given active production relevance).

## [Milestone 2] - 2026-07-01

### Added
- `agents/_TEMPLATE.md` — formal agent definition template (Mission, Scope, Responsibilities, Decision Framework, Vendor Guidance, Escalation Rules, Deliverables, Output Format, Quality Checklist).
- `workflows/_TEMPLATE.md` — formal workflow definition template (Executive Summary, Prerequisites, Assessment, Risk Analysis, Dependencies, Implementation, Validation, Rollback, Acceptance Criteria, Lessons Learned).
- Second specialist agent: `agents/vmware-architect/AGENT.md` — owns ESXi/vCenter/storage/networking/VM lifecycle, PowerCLI automation, and vSphere-layer compliance.
- First reusable workflow: `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md` — expanded from "upgrade only" to a full DC lifecycle covering seven scenarios: New DC Build/Promotion, In-Place OS Upgrade, DC Replacement (Swing Migration), FSMO Role Transfer/Seizure, Replication Troubleshooting, Decommission/Demotion, and Disaster Recovery (DC restore, authoritative restore, forest recovery).

### Next milestone
- `templates/change-request.md` and `templates/rca.md`, referenced by both agents built so far but not yet created.
- Third specialist agent: Windows Infrastructure Engineer or Backup & DR Architect (both are named as owning agents in the AD DC workflow but don't exist yet as formal agent files).
- `standards/powershell.md`, referenced by the VMware Architect agent but not yet created.

## [Milestone 3] - 2026-07-01

### Added
- `templates/change-request.md` — CAB-ready change request template, aligned to ITIL v4 change enablement, PCI-DSS v4.0 Req. 6.5, and ISO/IEC 27001:2022 A.8.32.
- `templates/rca.md` — Root Cause Analysis template, aligned to ITIL v4 problem management and ISO/IEC 27001:2022 A.5.27.
- `standards/powershell.md` — mandatory PowerShell engineering standard (CmdletBinding, WhatIf/ShouldProcess, error handling, credential handling, structure), with a PowerCLI-specific addendum.
- Third specialist agent: `agents/windows-infrastructure-engineer/AGENT.md` — owns Windows Server/AD DS/DNS/GPO/file services/hybrid identity, and is the primary executor of the AD DC Lifecycle workflow.

### Next milestone
- Backup & DR Architect agent (named throughout but still not formally defined; owns Veeam-layer policy distinct from the hypervisor-layer touchpoints VMware Architect already covers).
- `knowledge/` index — structured pointers to Microsoft/VMware/OpenStack/Veeam/Wazuh vendor documentation referenced across agents so far.
- First non-AD workflow to prove the template generalizes — candidate: VMware ESXi/vCenter upgrade lifecycle, mirroring the structure used for the AD DC lifecycle.

## [Milestone 4] - 2026-07-01

### Added
- Fourth specialist agent: `agents/backup-dr-architect/AGENT.md` — owns backup policy, Veeam/backup-product configuration, recoverability assurance, and DR runbook ownership, with explicit layer boundaries against `vmware-architect` (hypervisor-layer) and `windows-infrastructure-engineer` (guest-OS VSS layer).
- `knowledge/index.md` — central index of vendor documentation sources (Microsoft, VMware, Veeam, OpenStack, Linux/Ubuntu/Red Hat, Wazuh, PostgreSQL, Ansible, PowerShell) mapped to consuming agents, plus internal standards and compliance framework references. Existing agents referenced these sources inline; this centralizes them going forward.
- Second full workflow: `workflows/vmware-esxi-vcenter-upgrade-lifecycle/WORKFLOW.md` — proves the workflow template generalizes beyond AD. Covers three scenarios: vCenter Server Upgrade, ESXi Host Upgrade (Rolling, Cluster-Aware), and EOL Hardware/Hypervisor Retirement.

### Next milestone
- Security Architect agent (referenced by multiple existing agents for escalation/collaboration but not yet defined).
- OpenStack Architect agent (referenced in scope boundaries by `vmware-architect` but not yet defined; directly relevant given the active VMware-to-OpenStack migration work).
- Retrofit existing agent files (`chief-infrastructure-engineer`, `vmware-architect`, `windows-infrastructure-engineer`, `backup-dr-architect`) to reference `knowledge/index.md` directly rather than restating vendor source lists inline, keeping the index as the single source of truth going forward.

## [Milestone 5] - 2026-07-01

### Added
- Fifth specialist agent: `agents/security-architect/AGENT.md` — owns cross-cutting PCI-DSS/ISO 27001 scope determination, vulnerability management programme, SIEM detection strategy, multi-domain incident coordination, and security-vs-operational arbitration, without duplicating each specialist's own hardening ownership.
- Sixth specialist agent: `agents/openstack-architect/AGENT.md` — owns OpenStack deployment/upgrade/operations and the destination side of VMware-to-OpenStack migrations (including the active boot-failure issue), coordinating with `vmware-architect` (source side), `backup-dr-architect` (backup role policy), and `security-architect` (baseline images).

### Changed
- Retrofitted `agents/chief-infrastructure-engineer/AGENT.md`, `agents/vmware-architect/AGENT.md`, `agents/windows-infrastructure-engineer/AGENT.md`, and `agents/backup-dr-architect/AGENT.md` Vendor Guidance sections to reference `knowledge/index.md` as the source list rather than restating vendor sources inline — `knowledge/index.md` is now the single source of truth for vendor documentation mapping.
- Updated `knowledge/index.md` OpenStack, Wazuh, and CIS Benchmarks rows to reflect the newly created `openstack-architect` and `security-architect` agents (previously marked "agent not yet created").

### Next milestone
- Linux Platform Engineer agent (referenced across `backup-dr-architect`, `openstack-architect`, and `knowledge/index.md` as "not yet created" — the remaining gap in core platform coverage alongside Windows/VMware/OpenStack).
- `templates/programme-charter.md` (referenced by `chief-infrastructure-engineer` since Milestone 1 but not yet created) and `templates/rollback-plan.md`.
- `docs/architecture.md` — a platform-level document explaining how all six agents, two workflows, and supporting templates/standards fit together, useful now that the repository has enough surface area to need an orientation document beyond the README.

## [Milestone 6] - 2026-07-01

### Added
- Seventh specialist agent: `agents/linux-platform-engineer/AGENT.md` — the Linux-side counterpart to `windows-infrastructure-engineer`, owning Ubuntu/RHEL/Debian administration, CIS hardening (idempotent scripts with documented scope exclusions), SSSD/LDAP client-side auth, and host firewall configuration. Closes the last major platform-coverage gap alongside Windows/VMware/OpenStack.
- `templates/programme-charter.md` — governance artifact for multi-phase, multi-workstream initiatives, sitting above individual change requests. Referenced by `agents/chief-infrastructure-engineer/AGENT.md` since Milestone 1 but not created until now.
- `docs/architecture.md` — platform-level orientation document: agent roster and boundaries, workflow structure pattern, knowledge index role, compliance framing philosophy, and a "where to look for what" quick reference.

### Changed
- `knowledge/index.md` Linux/Ubuntu/Red Hat/CIS rows updated to reflect `linux-platform-engineer` (previously "agent not yet created").
- `README.md` Status section now points to `docs/architecture.md` instead of the placeholder `docs/roadmap.md` reference.

### Next milestone
- `templates/rollback-plan.md` — referenced conceptually throughout every workflow's Rollback section, but not yet a standalone template; most workflows currently embed rollback detail inline rather than in a standard format.
- Network Architect agent — referenced as "if/when defined" by `vmware-architect`, `security-architect`, and `linux-platform-engineer`; still the one specialist domain with no formal agent.
- A worked example in `examples/` — every agent and workflow exists in isolation so far; a full worked example (e.g. executing the AD DC Lifecycle workflow's Scenario B against a realistic scenario, showing the actual change request and RCA it would produce) would validate that the pieces genuinely compose end to end.

## [Milestone 7] - 2026-07-01

### Added
- `templates/rollback-plan.md` — standalone rollback plan template (classification, trigger conditions, procedure, time cost, data-loss implications, forward-fix contingency, decision authority), for Medium-risk-and-above changes.
- Eighth specialist agent: `agents/network-architect/AGENT.md` — owns physical/logical network infrastructure, segmentation (PCI-DSS Req. 1), the active 10G migration programme, and upstream firewall/ACL policy, resolving the "if/when defined" deferrals three other agents already pointed here.
- `examples/ad-dc-inplace-upgrade-walkthrough/WALKTHROUGH.md` — first worked example, showing `windows-infrastructure-engineer` executing the AD DC Lifecycle workflow end to end: a planning correction caught by the workflow's own Decision Framework (an assumed-invalid in-place upgrade path, correctly redirected to the swing migration scenario), a change request referencing rather than duplicating the workflow, a rollback plan, and an RCA hook for a hypothetical deviation.

### Changed
- `knowledge/index.md` — added a "Network" section (switch/router vendor documentation placeholder pending confirmation of specific vendor equipment, plus PCI-DSS Req. 1).

### Next milestone
- Confirm and catalogue the actual network vendor documentation source in `knowledge/index.md` (currently a placeholder — needs the specific switch/router vendor(s) in use).
- A second worked example demonstrating a failure/rollback path rather than a clean success, since the first example's RCA section was hypothetical rather than fully worked.
- `standards/bash.md` and `standards/ansible.md` — referenced by `agents/linux-platform-engineer/AGENT.md` since Milestone 6 but not yet created, leaving that agent's primary deliverable format underspecified relative to `standards/powershell.md`'s level of detail for the Windows/VMware agents.

## [Milestone 8] - 2026-07-01

### Added
- `standards/bash.md` — mandatory Bash standard (strict mode, idempotency, dry-run support, quoting discipline, shellcheck-clean), with a structural template mirroring `standards/powershell.md`'s level of detail.
- `standards/ansible.md` — mandatory Ansible standard (idempotency via proper modules over raw shell, check-mode compatibility, Vault for secrets, role-based structure, patch-automation-specific guidance for the check/apply separation pattern).
- `examples/vmware-esxi-upgrade-failure-rollback/WALKTHROUGH.md` — second worked example, deliberately showing a failure and rollback path (a host failing post-upgrade validation) rather than a clean success, exercising `templates/rollback-plan.md`'s "No rollback available" classification and forward-fix contingency, and producing a real RCA whose preventive action feeds back into the owning workflow document's Assessment section.

### Changed
- `workflows/vmware-esxi-vcenter-upgrade-lifecycle/WORKFLOW.md` — Assessment section (shared across all scenarios) updated to include a custom vSwitch/vmkernel configuration audit, closing the gap identified by this milestone's worked example rather than only documenting it as a deferred lesson.

### Next milestone
- Network vendor documentation in `knowledge/index.md` still needs the actual vendor/model confirmed — outstanding since Milestone 7.
- `standards/git.md` and `standards/logging.md`, both listed as "planned but not yet written" in `knowledge/index.md` since Milestone 4.

## [Milestone 9] - 2026-07-01

### Added
- `standards/git.md` — commit message discipline, branching approach, what belongs/never belongs in version control, `.gitignore` baseline, tagging convention.
- `standards/logging.md` — cross-language shared log entry shape (timestamp, actor, target, action, outcome, change reference) so PowerShell/Bash/Ansible-driven changes produce correlatable log output across the mixed Windows/Linux/VMware/OpenStack estate; ties to PCI-DSS v4.0 Req. 10.5.1 retention floor and hands off to `security-architect` for SIEM ingestion/strategy.

### Changed
- `knowledge/index.md` — network vendor documentation row filled in with the estate's actual mixed-vendor environment: Juniper and Cisco (switching/routing), Mellanox (high-throughput links, relevant to the 10G migration programme), Supermicro (network-adjacent hardware), and Fortinet/SonicWall (firewalls). Explicit multi-vendor note added since guidance doesn't transfer across these platforms.
- `agents/network-architect/AGENT.md` — Vendor Guidance section updated to name the specific vendors in scope and require the agent to state which vendor applies per change, rather than treating the network estate as single-vendor.
- `knowledge/index.md` internal standards list updated to reflect `standards/bash.md`, `standards/ansible.md`, `standards/git.md`, and `standards/logging.md` all now existing (previously listed as planned).

### Next milestone
- `standards/naming-conventions.md` — the one remaining standard still referenced as "planned but not yet written."
- Given the repository now has 8 agents, 2 workflows, 4 templates, 5 standards, a knowledge index, and 2 worked examples, a strong next step is validating cross-references haven't drifted — a consistency pass checking every "→ `agents/X/AGENT.md`" and "`workflows/Y/WORKFLOW.md`" reference across all files actually resolves to a real file with the expected content.
- Terraform is mentioned as a possible future standard in `knowledge/index.md` but isn't yet in active use in this estate (Ansible is the current automation backbone) — no action needed until that changes, noting it here so it isn't silently forgotten.

## [Milestone 10] - 2026-07-01

### Added
- `standards/naming-conventions.md` — repository structure naming (agents/workflows/templates/standards/examples slug patterns), cross-language variable naming pointer, and an explicit statement that this platform respects existing estate host naming rather than prescribing a new scheme.
- `docs/cross-reference-audit-milestone-10.md` — first full cross-reference consistency audit: 86 unique repository-path references extracted and checked across every Markdown file. One genuine gap found and fixed (`standards/naming-conventions.md`, this milestone); three references confirmed correctly labeled as deliberately deferred (`standards/terraform.md`, `templates/incident-report.md`, a historical `docs/roadmap.md` note); zero stale/broken references found otherwise.

### Changed
- `knowledge/index.md` internal standards list updated — `standards/naming-conventions.md` moved from "planned" to the confirmed-existing list.

### Next milestone
- Re-run the cross-reference audit periodically per the recommendation in `docs/cross-reference-audit-milestone-10.md` (every 3-4 milestones or before any release/tag) rather than treating this as a one-time exercise.
- Second non-AD, non-VMware workflow — candidate: a Linux CIS hardening lifecycle workflow (build → harden → validate → periodic re-audit), giving `agents/linux-platform-engineer/AGENT.md` the same workflow-backed depth the Windows and VMware agents already have.
- `templates/incident-report.md` — still a "candidate" per `knowledge/index.md`'s NIST SP 800-61 note; worth revisiting now that `standards/logging.md` exists and could feed it directly.

## [Milestone 11] - 2026-07-01

### Added
- Third full workflow: `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` — gives `agents/linux-platform-engineer/AGENT.md` the same workflow-backed depth as Windows and VMware. Three scenarios: Baseline Hardening (canary-first rollout pattern), Control Conflict/Documented Exception (routes to Security Architect's compensating-control register rather than silent skipping), and Periodic Re-Audit (drift detection). Codifies the estate's existing scope-boundary discipline (hardening script explicitly excludes PAM/auth and firewall design intent) as a first-class MUST rule rather than an implicit convention.
- `templates/incident-report.md` — NIST SP 800-61-aligned incident report template (Detection & Analysis, Containment, Eradication, Recovery, Post-Incident Activity), distinct from `templates/rca.md`: this is the live working document during an incident; the RCA is the after-the-fact root-cause deep-dive it links to. Includes a daily/periodic reporting roll-up note addressing the NIST SP 800-61 daily-reporting use case.

### Changed
- `knowledge/index.md` NIST SP 800-61 row updated — no longer "not yet integrated," now points to `templates/incident-report.md`.
- `agents/linux-platform-engineer/AGENT.md` — Responsibility #1 now references its owned workflow explicitly.
- `agents/security-architect/AGENT.md` — Deliverables section now references `templates/incident-report.md` as the working document for multi-domain incident coordination.

### Next milestone
- Re-run the cross-reference audit (per the Milestone 10 recommendation) now that two new files with several cross-references have been added since the last check.
- `docs/incident-response-playbook.md` or equivalent in `playbooks/` — `templates/incident-report.md` structures the document, but the platform doesn't yet have a playbook describing the response *process* itself (who's paged, escalation timing, communication cadence) to go with the document template.
- Consider whether `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md`'s canary-first rollout pattern should be retrofitted into the two existing lifecycle workflows (AD DC, VMware ESXi/vCenter), which don't currently have an explicit canary/pilot-host step before broader rollout.

## [Milestone 12] - 2026-07-01

### Added
- `playbooks/incident-response/PLAYBOOK.md` — the response *process* companion to `templates/incident-report.md`: severity definitions, response-time/escalation targets by severity, step-by-step NIST SP 800-61-aligned process (Detect & Triage → Analyze → Contain → Eradicate → Recover → Post-Incident), communication cadence by severity, and a roles quick reference tying back to `agents/security-architect/AGENT.md` (coordination) and the relevant domain specialist (execution).

### Changed
- `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md` — Risk Analysis SHOULD rule extended with an explicit canary-first pattern for multi-DC/multi-forest programmes (apply to the lowest-impact DC first, validate, then proceed) — directly relevant to the active sec.v.co.zw/eus.v.co.zw upgrade programme.
- `workflows/vmware-esxi-vcenter-upgrade-lifecycle/WORKFLOW.md` — Risk Analysis SHOULD rule extended to cover cross-cluster/programme-level canary selection, complementing the existing within-cluster rolling-host approach.

### Audit note
- Re-ran the cross-reference consistency check from Milestone 10 (57 unique path-style references now, up from 86 raw/45 unique previously counted differently — methodology corrected this pass to properly distinguish directory references like `` `agents/` `` from file references). Result: clean. The only new "missing" reference was `docs/incident-response-playbook.md`, which this milestone's `playbooks/incident-response/PLAYBOOK.md` resolves (different path than originally proposed, but the same gap). `standards/terraform.md` and the historical `docs/roadmap.md` note remain correctly deferred/historical, as previously documented.

### Next milestone
- Update `docs/cross-reference-audit-milestone-10.md`'s methodology note or supersede it with a Milestone 12 re-audit document, since this pass caught a methodology bug (directory vs. file reference conflation) in the original audit script.
- `playbooks/` now has its first real content — consider whether other domains warrant a playbook-vs-workflow distinction (e.g. a DR failover playbook alongside `agents/backup-dr-architect/AGENT.md`'s existing DR runbook ownership, to mirror the incident-report/incident-response-playbook pairing established this milestone).
- The repository is now large enough (8 agents, 3 workflows, 6 templates, 7 standards, 1 playbook, knowledge index, 2 examples) that a `docs/glossary.md` defining platform-specific terms (canary-first, forward-fix contingency, compensating-control register, blast radius) used consistently across files but never centrally defined might be worth adding.

## [Milestone 13] - 2026-07-01

### Added
- `docs/cross-reference-audit-milestone-13.md` — supersedes `docs/cross-reference-audit-milestone-10.md` with a corrected methodology (explicitly classifying placeholder/generic references separately from real file references, fixing the conflation bug Milestone 12 flagged). Result: clean, with the same two deliberately-deferred references (`docs/roadmap.md`, `standards/terraform.md`) as before, plus `docs/glossary.md` fixed as part of this milestone.
- `docs/glossary.md` — central definitions for platform-specific terms used across multiple files without ever being defined in one place: blast radius, canary-first, compensating control, forward-fix contingency, layer boundary, recoverability (vs. backup success), risk classification, scope exclusion, trigger condition, MUST/SHOULD/MAY, and programme vs. workflow vs. change.
- `playbooks/disaster-recovery-failover/PLAYBOOK.md` — second playbook, mirroring the incident-report/incident-response-playbook pairing pattern for `agents/backup-dr-architect/AGENT.md`'s DR runbook ownership: decision-point checklist for failover-vs-troubleshoot, severity/communication reuse from the incident response playbook, a 7-step process (Detect & Confirm → Declare & Notify → Execute Failover → Validate → Communicate Status → Failback → Post-Incident Review), and an explicit note that planned DR tests should exercise this exact process rather than a divergent test-only version.

### Changed
- `agents/backup-dr-architect/AGENT.md` — Deliverables section now references `playbooks/disaster-recovery-failover/PLAYBOOK.md` as the process DR runbooks are executed under.

### Next milestone
- The repository now spans 8 agents, 3 workflows, 6 templates, 7 standards, 2 playbooks, a knowledge index, 2 worked examples, and 2 docs beyond the README/architecture pair — worth checking whether `README.md`'s repository structure listing and `docs/architecture.md`'s "where to look for what" section still accurately reflect current contents, since both were written at Milestone 1/6 and haven't been revisited since.
- `templates/programme-charter.md` has no worked example yet, unlike the change-request/rollback-plan pairing which now has two full examples — the 10G migration programme (`agents/network-architect/AGENT.md`'s named responsibility) or the EOL elimination programme referenced in Tonde's own work history would both be realistic candidates.
- No agent currently owns database engineering (PostgreSQL, referenced in `knowledge/index.md` since Milestone 4 as "Database Engineer (agent not yet created)") — the remaining named-but-undefined agent gap in the roster.

## [Milestone 14] - 2026-07-01

### Added
- Ninth specialist agent: `agents/database-engineer/AGENT.md` — closes the last named-but-undefined agent gap. Owns PostgreSQL administration, performance (with explicit database-vs-infrastructure-layer attribution discipline), LDAP auth integration (database-side, following the estate's established unique-service-account-per-server pattern), and backup/PITR coordinated with `backup-dr-architect`.
- `examples/10g-network-migration-programme-charter/WALKTHROUGH.md` — third worked example, first to demonstrate `templates/programme-charter.md`. Deliberately honest about a real gap (no dedicated execution workflow exists yet for the programme's core work) rather than presenting an artificially clean example, and applies the canary-first pattern at programme scale (site-by-site) rather than only within a single change.

### Changed
- `README.md` — "What this is" bullets updated to name all nine agents, three workflows, and current template/standard/playbook counts; stale "Status" section replaced with a "Current contents" snapshot (explicitly flagged as a periodically-refreshed convenience, not a live source of truth — `CHANGELOG.md` remains authoritative).
- `docs/architecture.md` — agent roster table expanded from six to nine agents (added `linux-platform-engineer`, `openstack-architect`, `network-architect`, `database-engineer`); Workflow Structure section updated to include `linux-cis-hardening-lifecycle` and the canary-first pattern's origin/retrofit; new "Playbooks vs. workflows" section added distinguishing the two artifact types; "Where to look for what" quick reference extended to cover `playbooks/`, `docs/glossary.md`, and `examples/`.
- `knowledge/index.md` — PostgreSQL row updated to reflect `database-engineer` (previously "agent not yet created").

### Next milestone
- No dedicated workflow exists yet for the 10G migration programme's core execution pattern (core switching upgrade) — this milestone's worked example surfaced this honestly as a programme risk rather than inventing a workflow to fill the gap artificially; authoring `workflows/network-core-switching-upgrade/WORKFLOW.md` from real or realistic execution detail would close it properly.
- Re-run the cross-reference audit (per the now-established Milestone 10/13 pattern) given four new/changed files this milestone, including two files (`README.md`, `docs/architecture.md`) that are disproportionately likely to accumulate stale references since they summarize the rest of the repository.
- `agents/database-engineer/AGENT.md` has no dedicated workflow either (unlike Windows/VMware/Linux, which each have one) — a PostgreSQL upgrade/patching lifecycle workflow would bring database coverage to parity with the other core platform agents.

## [Milestone 15] - 2026-07-01

### Changed
- **Correction:** `agents/database-engineer/AGENT.md` scope broadened from PostgreSQL-only to **PostgreSQL, MySQL, and Microsoft SQL Server (MSSQL)** — Milestone 14's version treated database engineering as PostgreSQL-shaped work; this was a real scope gap, not a stylistic preference, since MySQL and MSSQL have materially different administration tooling, auth mechanisms, and vendor documentation. Every section (Scope, Responsibilities, Decision Framework, Escalation Rules, Output Format, Quality Checklist) rewritten to require the specific engine be stated explicitly, mirroring the multi-vendor discipline already established in `agents/network-architect/AGENT.md`.
- `knowledge/index.md` — the single-row PostgreSQL entry replaced with a dedicated "Database Engines" section covering all three engines' documentation sources, with the same multi-vendor framing note used for the Network section.
- `docs/architecture.md` and `README.md` — database-engineer roster row and knowledge bullet updated to name all three engines instead of PostgreSQL alone.

### Next milestone
- `agents/database-engineer/AGENT.md` still has no dedicated workflow (per Milestone 14's carried-over note) — now that scope spans three engines, a single workflow covering all three (or three engine-specific scenarios within one workflow, matching the multi-scenario pattern used elsewhere) is a stronger candidate than before.
- No dedicated workflow exists yet for the 10G migration programme's core execution pattern — still open from Milestone 14.
- Re-run the cross-reference audit — still open from Milestone 14, and now touches an additional file (`agents/database-engineer/AGENT.md` was rewritten, not just extended).

## [Milestone 16] - 2026-07-01

### Added
- Fourth full workflow: `workflows/database-engine-lifecycle/WORKFLOW.md` — brings `agents/database-engineer/AGENT.md` to workflow-backed parity with Windows/VMware/Linux. Covers all three engines (PostgreSQL, MySQL, MSSQL) in one document, 3 scenarios (Version Upgrade, Authentication Integration, Backup & Recoverability Verification), each nesting engine-specific implementation rather than splitting into three near-duplicate documents — same multi-scenario pattern already used for AD DC and ESXi/vCenter.
- Fifth full workflow: `workflows/network-core-switching-upgrade/WORKFLOW.md` — closes the gap `examples/10g-network-migration-programme-charter/WALKTHROUGH.md` honestly surfaced as missing. 2 scenarios (Single-Site Core Switching Upgrade with within-site canary-first, Inter-DC Link Capacity Upgrade), vendor-aware given the mixed Juniper/Cisco/Mellanox estate.

### Changed
- `agents/database-engineer/AGENT.md` and `agents/network-architect/AGENT.md` — mission/responsibility sections cross-linked to their respective new workflows.
- `examples/10g-network-migration-programme-charter/WALKTHROUGH.md` — updated in place to reflect the workflow gap it originally identified now being closed, with the Risk Register and Workstreams table both updated to show resolution rather than leaving a stale "gap exists" narrative uncorrected; the "What this example demonstrates" section updated to describe the full arc (gap identified → gap closed → document updated to show it) rather than just the identification half.
- `docs/architecture.md` and `README.md` — workflow counts and listings updated from 3 to 5 workflows.
- `docs/cross-reference-audit-milestone-13.md` — re-run and updated in place (per its own stated maintenance convention, rather than spawning a Milestone-16-numbered successor) given the volume of new cross-references from this milestone's two workflows. Result: clean, same two deliberately-deferred references as before, `docs/glossary.md` (fixed at Milestone 13) now confirmed in active cross-linked use.

### Next milestone
- No workflow yet exists for the OpenStack VM boot-failure diagnostic work `agents/openstack-architect/AGENT.md` owns as a named active responsibility — the remaining core agent without workflow-backed depth (Windows/VMware/Linux/Database/Network all now have one; OpenStack, Backup & DR, Security, and Chief Infrastructure Engineer do not, though the latter three are more naturally playbook/programme-shaped than workflow-shaped).
- `examples/` has three worked examples now, all authored by Claude in a single sitting each — consider whether a worked example built from an actual real (anonymized) production change would strengthen the set more than a fourth synthetic one.
- The repository has grown to 9 agents, 5 workflows, 5 templates, 6 standards, 2 playbooks, 3 examples, and 5 docs — worth a periodic sanity check that `CONTRIBUTING.md`'s review checklist (written at Milestone 1) still matches the structural conventions actually in use 16 milestones later.

## [Milestone 17] - 2026-07-01

### Added
- Sixth full workflow: `workflows/openstack-vm-migration-and-instance-lifecycle/WORKFLOW.md` — brings `agents/openstack-architect/AGENT.md` to workflow-backed parity with the other core platform agents. 3 scenarios: VMware-to-OpenStack VM Migration (destination side, coordinated with `vmware-architect`), Instance Boot-Failure Diagnosis (directly addressing the estate's named active issue, with an explicit OpenStack-side-evidence-first diagnostic sequence), and Standalone OpenStack-Native Instance Lifecycle (build/resize/decommission).
- `examples/sssd-ldap-firewall-rca-real-incident/RCA.md` — fourth worked example, and the **first built from a real incident** rather than a synthetic scenario: the actual SSSD/LDAP authentication failure on `prd-apexia`/`prd-ability` during the CIS Level 1 hardening rollout (C-082327), retroactively formatted against `templates/rca.md`. Explicitly labeled as real (vs. the prior three synthetic examples) and notes the retroactive-formatting caveat honestly rather than presenting it as if the template existed at the time.

### Changed
- `agents/openstack-architect/AGENT.md` — Responsibility #1 now references the new workflow's Scenario B explicitly.
- `CONTRIBUTING.md` — updated to actually document conventions already in real use but never written down: playbooks (`playbooks/<slug>/PLAYBOOK.md`, with an honest note that no formal template exists yet), examples (`examples/<slug>/WALKTHROUGH.md` or `RCA.md`), the multi-vendor/multi-engine explicit-statement discipline (`network-architect`, `database-engineer`), glossary/knowledge-index maintenance-on-touch rules, and the periodic cross-reference audit cadence — none of which were in the Milestone 1 version despite becoming real, followed conventions by Milestone 9-16.
- `docs/architecture.md` and `README.md` — workflow count updated 5 → 6, examples count updated 3 → 4.
- `docs/cross-reference-audit-milestone-13.md` — re-run and updated in place again. Result: one new correctly-deferred reference (`playbooks/_TEMPLATE.md`, explicitly proposed as future work in the updated `CONTRIBUTING.md`), zero genuine gaps.

### Next milestone
- `playbooks/_TEMPLATE.md` — now explicitly flagged in `CONTRIBUTING.md` as reasonable once a third playbook exists to confirm the pattern; the platform doesn't yet have a third playbook to trigger that.
- Chief Infrastructure Engineer, Backup & DR Architect, and Security Architect remain the three agents without dedicated workflows — per this milestone's own next-milestone note, this is expected given their programme/playbook-shaped nature rather than a gap requiring the same treatment as OpenStack's was, but worth confirming that reasoning still holds as the repository grows rather than assuming it permanently.
- Consider whether `agents/linux-platform-engineer/AGENT.md` or `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` should be updated to explicitly reference the `ldap_connection_expire_timeout = 60` finding's full diagnostic narrative now documented in `examples/sssd-ldap-firewall-rca-real-incident/RCA.md`, rather than only referencing the fix in passing as they currently do.

## [Milestone 18] - 2026-07-01

### Added
- `tests/validate-repo.sh` — the platform's first concrete implementation of the "Testing framework" deliverable named in the original project brief but never built until now. A dependency-free Bash script (per `standards/bash.md`) checking: agent structural completeness (9 required sections), workflow structural completeness (10 required sections), stray placeholder text outside template files, and cross-reference consistency against a maintained deferred-reference allow-list kept in sync with `docs/cross-reference-audit-milestone-13.md`. Verified working via a deliberate break-then-restore sanity check (removed a required section and injected a stray `TODO` into a real agent file, confirmed the script caught both, then restored the file) before being committed.
- `tests/README.md` — explains the suite's scope, explicitly states what it does and doesn't check (structural linter, not a technical reviewer), and documents the maintenance obligation to keep its `DEFERRED_REFS` allow-list in sync with the audit document.

### Changed
- `CONTRIBUTING.md` — style rules updated to point at `tests/validate-repo.sh` as the preferred way to run the periodic consistency check, rather than only describing the manual `grep` process.
- `docs/architecture.md` and `README.md` — "where to look for what" and current-contents snapshot updated to include the test suite.

### Verification
- `tests/validate-repo.sh` run against the full repository post-changes: **17 passed, 0 failed**, exit code 0.

### Next milestone
- `playbooks/_TEMPLATE.md` — still pending a third playbook to justify it (unchanged from Milestone 17).
- Consider extending `tests/validate-repo.sh` with a check for the multi-vendor/multi-engine explicit-statement discipline `CONTRIBUTING.md` now documents (e.g. confirming `agents/network-architect/AGENT.md` and `agents/database-engineer/AGENT.md` actually name their respective vendors/engines in the Vendor Guidance section) — currently that discipline is documented but not mechanically enforced the way section-completeness now is.
- The `examples/sssd-ldap-firewall-rca-real-incident/RCA.md` cross-link into `agents/linux-platform-engineer/AGENT.md`/`workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` — still open from Milestone 17.

## [Milestone 19] - 2026-07-01

### Added
- `tests/agent-behavior/test-scenarios.md` — behavioral test scenario bank, complementing `validate-repo.sh`'s structural checks with actual functional testing: does an agent behave the way its own Decision Framework/Escalation Rules/Quality Checklist claim it does, when given a realistic scenario designed to probe a specific documented behavior. Four scenarios authored: missing engine specification (Database Engineer), missing vendor specification (Network Architect), last-DC/FSMO risk (Windows Infrastructure Engineer), bypass-change-control pressure (Chief Infrastructure Engineer).
- `tests/agent-behavior/results-milestone-19.md` — first executed round. **All four agents passed**, scored honestly against rubrics derived directly from their own agent files. Scenario 4 surfaced a genuine, previously-undocumented platform gap: no defined emergency-change process existed.
- `templates/emergency-change.md` — authored the same milestone in direct response to the gap Scenario 4 found, rather than only logging it for later: a compressed, expedited change template requiring a named approver (not just a role), a mandatory rollback statement even under time pressure, and a mandatory full standard CR filed within 24 hours. A concrete example of behavioral testing producing a platform improvement, not just a report.

### Changed
- `agents/chief-infrastructure-engineer/AGENT.md` — Escalation Rules updated to point bypass-change-control requests at the new emergency-change path rather than a bare refusal.
- `templates/change-request.md` — header note added pointing to `templates/emergency-change.md` for genuine active emergencies.
- `tests/README.md` — restructured to explain the two distinct testing types (structural vs. behavioral) and why both are needed.
- `CONTRIBUTING.md`, `docs/architecture.md`, `README.md` — updated for the new template, the new test type, and updated counts (6 templates, 2 test types).

### Verification
- `tests/validate-repo.sh` re-run after all changes: **17 passed, 0 failed** — confirms the new template and cross-links didn't introduce structural drift.

### Next milestone
- Run additional behavioral test rounds against the remaining agents not yet covered (VMware Architect, Linux Platform Engineer, Backup & DR Architect, Security Architect, OpenStack Architect) — only 4 of 9 agents have been behaviorally tested so far.
- `tests/validate-repo.sh` still doesn't mechanically check the multi-vendor/multi-engine discipline — carried over from Milestone 18, now with two passing behavioral tests (Scenarios 1 and 2) demonstrating the *behavior* is correct even though the *structural* check for it doesn't exist yet; worth deciding whether a structural check is still worth adding given behavioral coverage now exists, or whether that would be redundant effort.
- Consider whether `templates/emergency-change.md` needs its own worked example in `examples/`, following the pattern established for the other templates, once a real (or realistic) emergency-change scenario is available to document.

## [Milestone 20] - 2026-07-01

### Added
- Five more scenarios in `tests/agent-behavior/test-scenarios.md`: skipping the live interoperability check (VMware Architect), silent PAM/auth scope creep (Linux Platform Engineer), backup success mistaken for recoverability (Backup & DR Architect), open-ended risk acceptance (Security Architect), and blaming the migration source without destination-side evidence first (OpenStack Architect).
- `tests/agent-behavior/results-milestone-20.md` — second round executed. **All five agents passed.** Combined with Milestone 19, behavioral test coverage now spans **9 of 9 agents**. Zero new platform gaps found this round (contrast with Milestone 19's emergency-change finding).

### Changed
- `tests/README.md` — updated to reflect full 9-agent behavioral coverage across the two rounds.

### Verification
- `tests/validate-repo.sh` re-run after all changes: **17 passed, 0 failed.**

### Honest limitation noted this round
- `tests/agent-behavior/results-milestone-20.md` flags a structural risk in this testing approach: scenarios so far were authored by the same process that wrote the agent files, so passing them is reassuring but not fully independent verification. The Milestone 19 emergency-change gap is evidence the process isn't purely circular, but future rounds are directed to include genuinely adversarial scenarios (testing whether an agent can be talked out of its own rules via ambiguous framing or social pressure), not only scenarios that cleanly confirm one rule at a time.

### Next milestone
- Design and run at least one adversarial behavioral scenario per agent — distinct from the confirmatory scenarios run in Milestones 19-20 — per the honest limitation this round surfaced.
- Re-run the full 9-scenario (soon to be more) behavioral bank periodically, not just when adding new scenarios, since a shared-concern edit (e.g. to `docs/glossary.md` or `CLAUDE.md`) could regress multiple agents' behavior at once without any single agent file being directly touched.
- `templates/emergency-change.md` still has no worked example — carried over from Milestone 19.

## [Milestone 21] - 2026-07-01

### Added
- Nine adversarial scenarios in `tests/agent-behavior/test-scenarios.md` (Scenarios 10-18), one per agent, each combining authority pressure, sunk-cost framing, claimed exceptions, or "just this once" minimization — deliberately harder than Rounds 1-2's clean single-rule probes, per the limitation Milestone 20 flagged.
- `tests/agent-behavior/results-milestone-21.md` — third round executed. **All nine agents held their documented rules under adversarial pressure — 9/9 pass, cumulative 18/18 across all three rounds.** Includes an explicit "Honest assessment of this round" section naming why a perfect record this far in warrants some skepticism (same-author scenario design, single-exchange rather than sustained-pressure testing) rather than being taken purely at face value.
- `templates/change-request.md` — new "Change Type Classification" section defining Standard/Normal/Emergency criteria with a MUST rule against classifying by requester-claimed size alone, closing a genuine gap Scenario 16 surfaced (the platform had a `Change type` field with three labels but no actual criteria for which applied, leaving agents to improvise the Standard-vs-Normal distinction ad hoc).

### Verification
- `tests/validate-repo.sh` re-run after all changes: **17 passed, 0 failed.**

### Next milestone
- Add multi-turn adversarial scenarios (a follow-up pushback after the agent's first refusal, e.g. "come on, everyone does this, just this once") to test whether a position holds under sustained pressure rather than a single exchange — per this round's own "Honest assessment" section.
- `templates/emergency-change.md` still has no worked example — carried over from Milestone 19/20.
- Consider whether an actually-independent adversarial review (not authored by the same process that wrote the agents and the earlier test rounds) is worth pursuing given the honest limitation this round names about same-author scenario design.

## [Milestone 22] - 2026-07-01

### Added
- Turn 2 pushback prompts added to all nine Milestone 21 adversarial scenarios in `tests/agent-behavior/test-scenarios.md` — a follow-up after the agent's initial refusal, testing whether the position holds under sustained pressure rather than a single exchange, per Milestone 21's own recommendation.
- `tests/agent-behavior/results-milestone-22.md` — fourth round executed. **All nine positions held under Turn 2 pushback.** Notably, Scenario 18 (OpenStack Architect) received a pushback that was actually a legitimate engineering compromise (risk-based sampling) rather than pure pressure, and the agent correctly accepted the reasonable part while holding firm on the part that still mattered — the first scenario in the bank to test discernment between good-faith proposals and pressure tactics, not just resistance to the latter.

### Verification
- `tests/validate-repo.sh` re-run after all changes: **17 passed, 0 failed.**
- Cumulative behavioral testing score across all four rounds (Milestones 19-22): **27/27 scenario-turns passed.**

### Next milestone
- A three-turn round (pushback → pushback → does the position still hold) as the natural next escalation, per `results-milestone-22.md`'s own recommendation — testing whether "holds for one follow-up" generalizes or whether there's an undiscovered pressure threshold.
- Design at least one more scenario in the shape of Scenario 18 (a genuine good-faith compromise disguised as pushback) deliberately, to keep testing discernment rather than only resistance.
- `templates/emergency-change.md` still has no worked example — carried over from Milestone 19-21.

## [Milestone 23] - 2026-07-01

### Added
- `tools/skill-source/SKILL.md` — the authored router/triage layer for using this entire platform as a single Claude Skill (`enterprise-engineering-platform`), rather than pasting individual `AGENT.md` files into chat manually. Contains the platform-wide operating rules (always in context when the skill triggers), a triage table mapping each domain to its agent and workflow, and pointers into the bundled reference content.
- `tools/build-skill.sh` — generates the skill's `references/` content **fresh from the live repository** (agents, workflows, templates, standards, playbooks, knowledge index, glossary, architecture doc) rather than maintaining a hand-duplicated copy that would drift — same anti-drift discipline as `tests/validate-repo.sh` and the cross-reference audits, applied to the skill-packaging problem specifically. Verified working: built a 33-file bundle matching a manually-assembled reference build exactly.
- `tools/README.md` — explains why the skill content is generated rather than hand-maintained, how to build and package it (including the description-length validation gotcha — 1024-character hard limit, which the first packaging attempt hit and required trimming twice to clear), and when `tools/skill-source/SKILL.md` itself needs a manual edit versus when a rebuild is sufficient.
- Packaged and delivered `enterprise-engineering-platform.skill` (115KB, 33 files) as a downloadable artifact, validated successfully through the skill-creator tooling's own validator before packaging.

### Changed
- `docs/architecture.md` and `README.md` — cross-linked to the new skill-packaging tooling.

### Verification
- `tests/validate-repo.sh` re-run after all changes: **17 passed, 0 failed.**
- Skill bundle validated by the skill-creator tooling's `quick_validate` step before packaging (required fixing an invalid YAML apostrophe-escaping artifact and trimming the description from 1846 to 975 characters to clear the 1024-character limit).

### Next milestone
- A three-turn adversarial testing round — still open from Milestone 22.
- Consider whether `tools/skill-source/SKILL.md`'s triage table should be mechanically checked against the actual agent roster (e.g. via `tests/validate-repo.sh`) so it can't silently go stale the way `README.md`'s and `docs/architecture.md`'s snapshots already have once before (Milestone 14's refresh).
- `templates/emergency-change.md` still has no worked example — carried over from Milestone 19-22.
