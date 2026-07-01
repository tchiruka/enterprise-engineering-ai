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
