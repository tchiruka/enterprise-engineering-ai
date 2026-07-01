# Platform Architecture

This document explains how the pieces of this repository fit together — useful once there's enough surface area that the README's structural listing isn't sufficient orientation on its own.

## The core model: agents own domains, workflows encode procedures, templates standardize output

Three kinds of artifact do almost all the work in this repository:

- **Agents** (`agents/`) are *who* — a specialist's mission, scope, decision-making judgment, and quality bar for one technical domain.
- **Workflows** (`workflows/`) are *how* — the actual step-by-step procedure for a specific recurring task, with built-in risk analysis, validation, and rollback.
- **Templates** (`templates/`) are *what gets produced* — the standard shape of a change request, RCA, or programme charter, regardless of which agent or workflow generated it.

An agent executes a workflow and produces output in a template's format. This separation exists so that, for example, the change-request format stays consistent whether it's the VMware Architect or the Windows Infrastructure Engineer filling it out — the reader doesn't have to relearn document structure per specialist.

## Agent roster and boundaries

Six specialist agents exist so far, each with a deliberately scoped domain and explicit "out of scope, routes to X" boundaries so responsibilities don't silently overlap or fall through gaps:

| Agent | Owns | Explicitly defers to |
|---|---|---|
| `chief-infrastructure-engineer` | Cross-domain triage, sequencing, arbitration, programme-level artifacts | Every specialist for domain-specific technical depth |
| `vmware-architect` | ESXi/vCenter, VM lifecycle, vSphere storage/networking, PowerCLI | `windows-infrastructure-engineer` / Linux Platform Engineer for guest-OS; `backup-dr-architect` for backup policy; `openstack-architect` for the other virtualization platform |
| `windows-infrastructure-engineer` | Windows Server, AD DS, DNS, GPO, hybrid identity | `vmware-architect`/`openstack-architect` for the hypervisor layer; `backup-dr-architect` for backup policy |
| `backup-dr-architect` | Backup policy, Veeam configuration, recoverability assurance, DR runbooks | `vmware-architect` for hypervisor-layer backup mechanics (CBT, quiescing); `windows-infrastructure-engineer`/`linux-platform-engineer` for guest-OS application-consistency |
| `security-architect` | PCI-DSS/ISO 27001 scope, vulnerability management programme, SIEM strategy, cross-domain incident coordination | Each specialist for domain-specific hardening implementation |
| `openstack-architect` | OpenStack services (Nova/Neutron/Cinder/Glance/Keystone), VMware-to-OpenStack migration (destination side) | `vmware-architect` for migration source side; `linux-platform-engineer` for underlying host OS; `backup-dr-architect` for backup policy |
| `linux-platform-engineer` | Ubuntu/RHEL/Debian administration, CIS hardening, SSSD/LDAP client-side auth | `windows-infrastructure-engineer` for AD/LDAP server-side; `openstack-architect` for the service layer running on top |

This table is itself a simplification — each agent's own `AGENT.md` "Scope" section is the authoritative boundary definition. When two agents' responsibilities seem to overlap on a specific task, `chief-infrastructure-engineer`'s arbitration role exists precisely for that ambiguity.

## Workflow structure

Every workflow in `workflows/` follows the same ten-part lifecycle (`workflows/_TEMPLATE.md`): Executive Summary, Prerequisites, Assessment, Risk Analysis, Dependencies, Implementation, Validation, Rollback, Acceptance Criteria, Lessons Learned. Two workflows exist so far:

- `active-directory-domain-controller-lifecycle` — 7 scenarios (Build, In-Place Upgrade, Swing Migration, FSMO Transfer/Seizure, Replication Troubleshooting, Decommission, DR).
- `vmware-esxi-vcenter-upgrade-lifecycle` — 3 scenarios (vCenter Upgrade, Rolling ESXi Host Upgrade, EOL Hardware Retirement).

Where a domain has several related but distinct procedures (as both of the above do), the pattern is **one workflow document with multiple scenarios sharing common Prerequisites/Assessment/Risk Analysis/Dependencies sections**, rather than fragmenting into many near-duplicate documents — this keeps the shared risk context (e.g. "never touch the last DC in a domain") visible once rather than repeated and potentially drifting across separate files.

## Knowledge index as single source of truth

`knowledge/index.md` centralizes which vendor documentation source backs which agent's guidance. Agent files reference this index rather than restating vendor source lists inline (retrofitted in Milestone 5) — when a vendor documentation location changes or a new authoritative source is added, it's updated once.

## Compliance framing runs through everything, not as a bolt-on

PCI-DSS v4.0, ISO/IEC 27001:2022, COBIT 2019, and ITIL v4 references appear in agent decision frameworks, workflow risk analysis sections, and template structures — not as a separate "compliance" document disconnected from the technical work. This mirrors how the platform is meant to be used: compliance-aware judgment embedded in the actual engineering decision, not a checklist applied after the fact.

## Growth pattern

The repository has grown by this consistent milestone pattern: identify a gap (a referenced-but-undefined agent, a workflow scoped too narrowly, a dangling template reference), build the smallest coherent unit that closes it, cross-link it into what already exists, and record the *next* gap that unit's existence reveals in `CHANGELOG.md`. This is deliberate — it's what keeps the repository internally consistent rather than accumulating disconnected artifacts. Anyone extending this repository (human or AI) should follow the same pattern: check `CONTRIBUTING.md` for the structural rules, check this document for how the piece being added relates to what exists, and update `CHANGELOG.md` with what the new piece reveals as the next gap.

## Where to look for what

- **"I need to know if X is the right agent for this task"** → that agent's `AGENT.md` Scope section, or `chief-infrastructure-engineer` if genuinely cross-domain.
- **"I need the actual step-by-step procedure for Y"** → `workflows/`, check if a workflow already exists before improvising.
- **"I need to know what format this document should be in"** → `templates/`.
- **"I need to know what vendor documentation backs this claim"** → `knowledge/index.md`.
- **"I need to know the engineering rules for this script"** → `standards/`.
- **"I need to know what's been built and what's next"** → `CHANGELOG.md`.
