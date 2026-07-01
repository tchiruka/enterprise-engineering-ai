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
