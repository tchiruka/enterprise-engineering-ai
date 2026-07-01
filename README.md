# Enterprise Engineering AI Platform

An AI-powered internal consulting platform for senior infrastructure and systems engineering teams. This repository defines a set of specialist AI agents, reusable workflows, documentation templates, and engineering standards that together behave like an in-house consulting practice: consistent, vendor-aligned, audit-ready, and safe for production use.

## What this is

This is not a single prompt. It is a structured knowledge and agent repository:

- **Agents** — role-scoped specialist personas (Chief Infrastructure Engineer, VMware Architect, Windows Infrastructure Engineer, Linux Platform Engineer, Backup & DR Architect, Security Architect, OpenStack Architect, Network Architect, Database Engineer), each with a defined mission, scope, decision framework, and output standards.
- **Workflows** — step-by-step, reusable procedures for common high-risk infrastructure tasks (AD DC lifecycle, ESXi/vCenter upgrade lifecycle, Linux CIS hardening lifecycle, etc.), each following a fixed lifecycle: assessment → risk → implementation → validation → rollback → lessons learned.
- **Templates** — standard formats for change requests, RCAs, rollback plans, incident reports, and programme charters.
- **Standards** — engineering conventions for scripting languages (PowerShell, Bash, Ansible), Git usage, logging, and naming conventions.
- **Knowledge** — a structured index (`knowledge/index.md`) pointing to authoritative vendor documentation (Microsoft, VMware, Veeam, OpenStack, Linux/Ubuntu/Red Hat, Network vendors, PostgreSQL/MySQL/MSSQL, Ansible), with a defined place for internal organizational standards to sit alongside it.
- **Playbooks** — operational, repeatable process guidance for recurring cross-cutting events (incident response, DR failover), distinct from workflows in that a playbook covers the *decision process and communication cadence* around an event, while a workflow covers a specific technical procedure.
- **Examples** — worked, end-to-end demonstrations showing how an agent, a workflow (or programme charter), and the platform's templates compose into an actual deliverable — including at least one deliberately showing a failure/rollback path, not just clean successes.

## Design principles

1. **Production-ready by default.** No placeholder text, no unexplained TODOs. Every artifact this platform produces should be usable as-is in a regulated enterprise environment.
2. **Vendor-aligned.** Guidance traces back to official vendor documentation and recognized frameworks (ITIL v4, COBIT, ISO/IEC 27001, PCI-DSS, NIST).
3. **Risk-aware.** Every workflow separates mandatory steps from recommendations, states assumptions explicitly, and includes rollback guidance.
4. **Composable.** Agents and workflows are independent units that can be invoked individually or chained together for larger engagements.
5. **Auditable.** Documentation formats are built to survive a CAB review, an ISO 27001 audit, or a PCI-DSS assessment without rework.

## Repository structure

```text
enterprise-engineering-ai/
│
├── README.md            # This file
├── CLAUDE.md             # How an AI assistant should operate within this repo
├── LICENSE
├── CONTRIBUTING.md
├── CHANGELOG.md
│
├── agents/               # Specialist agent definitions
├── workflows/            # Reusable step-by-step procedures
├── templates/            # Document templates (CR, RCA, runbook, etc.)
├── standards/            # Engineering/scripting/documentation standards
├── knowledge/            # Vendor documentation index + internal standards
├── scripts/              # Reference/utility scripts
├── playbooks/            # Operational playbooks (incident, DR, etc.)
├── policies/             # Governance and compliance policies
├── checklists/           # Quick-reference validation checklists
├── docs/                 # Platform documentation (architecture, usage)
├── examples/             # Worked examples using agents + workflows
├── tests/                # Validation/test cases for workflows and templates
├── tools/                # Supporting tooling (e.g. doc generation, linting)
├── automation/           # Automation framework (Ansible/CI glue)
├── diagrams/             # Architecture and workflow diagrams
└── training/             # Onboarding material for using the platform
```

## Current contents

This repository is being built incrementally, one milestone at a time — see `CHANGELOG.md` for the full history and `docs/architecture.md` for how the pieces below fit together. As of the most recent milestone:

- **9 specialist agents** (`agents/`): Chief Infrastructure Engineer, VMware Architect, Windows Infrastructure Engineer, Linux Platform Engineer, Backup & DR Architect, Security Architect, OpenStack Architect, Network Architect, Database Engineer.
- **3 full workflows** (`workflows/`): AD Domain Controller Lifecycle (7 scenarios), VMware ESXi/vCenter Upgrade Lifecycle (3 scenarios), Linux CIS Hardening Lifecycle (3 scenarios).
- **5 templates** (`templates/`): Change Request, RCA, Rollback Plan, Incident Report, Programme Charter.
- **6 standards** (`standards/`): PowerShell, Bash, Ansible, Git, Logging, Naming Conventions.
- **2 playbooks** (`playbooks/`): Incident Response, Disaster Recovery Failover.
- **3 worked examples** (`examples/`): a clean multi-step change (AD DC swing migration), a failure/rollback path (ESXi upgrade), and a programme-level artifact (10G migration programme charter).
- **1 knowledge index** (`knowledge/index.md`) and **1 glossary** (`docs/glossary.md`) tying the above together.

This snapshot will drift out of date the moment the next milestone lands — treat `CHANGELOG.md` as the authoritative record and this section as a periodically-refreshed convenience, not a live-updating source of truth.

## Getting started

Each agent in `agents/` is self-contained: read its `AGENT.md` for mission, scope, and how to invoke it. Each workflow in `workflows/` is designed to be followed end-to-end by the relevant specialist agent, producing artifacts that map directly to the templates in `templates/`.
