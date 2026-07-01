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
