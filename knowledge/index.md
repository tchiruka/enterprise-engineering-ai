# Knowledge Index

This is the platform's central pointer to authoritative external (vendor) documentation and internal organizational standards. Agents reference this index rather than each restating vendor source lists independently — when a vendor documentation set moves or a new authoritative source should be added, it's updated once, here.

## How this is organized

Each entry: which agent(s) rely on it, what it's authoritative for, and where to find it. This index does **not** attempt to mirror or cache vendor documentation content — it points to it, because vendor docs change and this platform must not silently go stale by copying content that then diverges from the source of truth.

## Vendor documentation

### Microsoft

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| Microsoft Learn — Active Directory Domain Services | AD DS design, DC lifecycle, replication, FSMO | `windows-infrastructure-engineer` |
| Microsoft Learn — Windows Server | OS-level administration, supported upgrade paths | `windows-infrastructure-engineer` |
| Microsoft's documented Windows Server supported in-place upgrade matrix | Which OS version jumps support in-place upgrade vs. requiring migration | `windows-infrastructure-engineer` |
| Microsoft AD Forest Recovery Guidance | Forest-wide DR/recovery sequencing | `windows-infrastructure-engineer`, `chief-infrastructure-engineer` (escalation) |
| Microsoft Security Compliance Toolkit / security baselines | Windows Server hardening | `windows-infrastructure-engineer` |
| Microsoft Learn — Entra ID / Entra Connect | Hybrid identity, sync scope/filtering | `windows-infrastructure-engineer` |
| Microsoft VSS documentation | Application-consistent backup prerequisites (guest-OS side) | `windows-infrastructure-engineer`, `backup-dr-architect` (collaboration) |

### VMware

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| VMware vSphere Documentation (version-specific) | ESXi/vCenter configuration, administration, upgrade guides | `vmware-architect` |
| VMware Product Interoperability Matrix | Cross-product version compatibility (vSphere ↔ backup software ↔ plugins) — **must be checked live**, not assumed from a documentation snapshot | `vmware-architect`, `backup-dr-architect` |
| VMware Configuration Maximums | Per-version scale limits | `vmware-architect` |
| VMware Compatibility Guide (HCL) | Hardware/storage compatibility | `vmware-architect` |
| VMware Security Hardening Guides | vSphere-layer hardening | `vmware-architect` |
| VMware CBT/snapshot documentation | Backup mechanics at the hypervisor layer | `vmware-architect`, `backup-dr-architect` (collaboration) |

### Veeam

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| Veeam Backup & Replication Best Practices Guide / User Guide (version-specific) | Job design, sizing, repository architecture | `backup-dr-architect` |
| Veeam sizing guidance (proxies, repositories, WAN acceleration) | Capacity planning | `backup-dr-architect` |

### Network

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| Juniper Networks TechLibrary (Junos OS documentation) | Juniper switch/router configuration and administration | `network-architect` |
| Cisco documentation (Cisco IOS/IOS-XE/NX-OS, per platform in use) | Cisco switch/router configuration and administration | `network-architect` |
| NVIDIA/Mellanox documentation (Cumulus Linux / Onyx, per switch OS in use) | Mellanox switch configuration, high-throughput/low-latency networking | `network-architect` |
| Supermicro documentation | Supermicro network hardware configuration (where used for switching or as network-adjacent server hardware) | `network-architect` |
| Fortinet documentation (FortiOS — FortiGate firewalls) | Fortinet firewall configuration, policy, and hardening | `network-architect`, `security-architect` (policy strategy) |
| SonicWall documentation (SonicOS) | SonicWall firewall configuration, policy, and hardening | `network-architect`, `security-architect` (policy strategy) |
| PCI-DSS v4.0 Requirement 1 | Network security controls / segmentation | `network-architect`, `security-architect` |

**Multi-vendor note:** this estate runs a mixed network vendor environment (Juniper and Cisco for switching/routing, Mellanox for high-throughput links — relevant to the 10G migration programme, Supermicro for adjacent hardware, and Fortinet/SonicWall for firewalls). `agents/network-architect/AGENT.md` should state explicitly which vendor's equipment is in scope for any given change, since configuration syntax, supported feature sets, and hardening guidance differ meaningfully across these platforms — do not assume guidance from one vendor's documentation applies to another's equipment.

### OpenStack

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| OpenStack official documentation (per-release) | Deployment, upgrade, operations | `openstack-architect` |
| OpenStack release notes and upgrade guides | Supported version-jump paths | `openstack-architect` |

### Linux / Ubuntu / Red Hat

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| Ubuntu Server documentation | Ubuntu-specific administration | `linux-platform-engineer` |
| Red Hat documentation | RHEL-family administration | `linux-platform-engineer` |
| CIS Benchmarks (Ubuntu/RHEL) | Hardening baselines | `linux-platform-engineer` (implementation), `security-architect` (strategy) |

### Database Engines

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| PostgreSQL official documentation (version-specific) | Configuration, performance tuning, replication, backup/PITR, `pg_hba.conf` LDAP auth | `database-engineer` |
| MySQL Reference Manual (and MariaDB documentation where MariaDB is specifically in use) | Configuration, performance tuning, replication (binlog-based and Group Replication), backup/PITR, LDAP/PAM auth plugins | `database-engineer` |
| Microsoft SQL Server documentation (Microsoft Learn) | Configuration, performance tuning, Always On Availability Groups/failover clustering, native backup/PITR, Windows Authentication/AD integration | `database-engineer` |

**Multi-engine note:** this estate runs three relational database engines (PostgreSQL, MySQL, MSSQL) — `agents/database-engineer/AGENT.md` should state explicitly which engine's documentation applies for any given piece of guidance, since administration tooling, authentication mechanisms, and backup approaches differ meaningfully across the three, in the same way `network-architect`'s mixed-vendor network guidance must state which vendor applies.

### Other platform vendors

| Source | Authoritative for | Primary consuming agent(s) |
|---|---|---|
| Wazuh documentation | SIEM agent configuration, rule/decoder authoring, detection coverage strategy | `security-architect` (strategy), relevant platform agent (agent-level config) |
| Ansible documentation | Playbook/role design, automation standards | Automation Engineer (agent not yet created) |
| PowerShell documentation (Microsoft Learn) | Language reference underlying `standards/powershell.md` | `windows-infrastructure-engineer`, `vmware-architect` |

## Internal organizational standards

Internal standards sit in `standards/` and are the house-specific complement to vendor guidance above — vendor docs establish what's *possible and supported*; internal standards establish what's *required in this environment*. Current internal standards:

- `standards/powershell.md` — mandatory PowerShell engineering rules.
- `standards/bash.md` — mandatory Bash engineering rules.
- `standards/ansible.md` — mandatory Ansible playbook/role rules.
- `standards/git.md` — commit message, branching, and repository hygiene rules.
- `standards/logging.md` — cross-language shared log entry shape for state-changing actions, complementing the language-specific logging requirements in the standards above.
- `standards/naming-conventions.md` — repository structure and cross-language naming pointer standard.

Planned but not yet written: `standards/terraform.md` (if/when Terraform usage grows beyond the current Ansible-centric automation approach).

## Compliance framework references

These aren't vendor documentation but are treated with equivalent authority for control language:

| Framework | Used for | Where referenced |
|---|---|---|
| PCI-DSS v4.0 | Cardholder data environment controls | `templates/change-request.md`, `templates/rca.md`, most agents |
| ISO/IEC 27001:2022 | ISMS controls (Annex A) | `templates/change-request.md`, `templates/rca.md`, most agents |
| COBIT 2019 | Governance (esp. BAI06 change management) | `agents/chief-infrastructure-engineer/AGENT.md` |
| ITIL v4 | Change enablement, problem management, service management practices | Platform-wide |
| NIST SP 800-61 | Incident handling (referenced for daily reporting use, per Tonde's stated interest) | `templates/incident-report.md` structures around its four-phase lifecycle (Preparation, Detection & Analysis, Containment/Eradication/Recovery, Post-Incident Activity); owned by `agents/security-architect/AGENT.md` for coordination |

## Maintenance note

When a new agent or workflow references a vendor source not yet listed here, add it in the same change rather than leaving it as an implicit, uncited reference — this index exists specifically to prevent vendor guidance claims from floating free of a checkable source.
