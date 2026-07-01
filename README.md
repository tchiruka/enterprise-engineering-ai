# Enterprise Engineering AI Platform

An AI-powered internal consulting platform for senior infrastructure and systems engineering teams. This repository defines a set of specialist AI agents, reusable workflows, documentation templates, and engineering standards that together behave like an in-house consulting practice: consistent, vendor-aligned, audit-ready, and safe for production use.

## What this is

This is not a single prompt. It is a structured knowledge and agent repository:

- **Agents** — role-scoped specialist personas (Chief Infrastructure Engineer, VMware Architect, Windows/AD engineer, Backup & DR Architect, Security Architect, etc.), each with a defined mission, scope, decision framework, and output standards.
- **Workflows** — step-by-step, reusable procedures for common high-risk infrastructure tasks (AD migration, ESXi lifecycle, DR testing, patching, decommissioning, etc.), each following a fixed lifecycle: assessment → risk → implementation → validation → rollback → lessons learned.
- **Templates** — standard formats for change requests, RCAs, runbooks, risk assessments, executive summaries, and CAB documentation.
- **Standards** — engineering conventions for scripting languages (PowerShell, Bash, Python, Ansible, Terraform), Git usage, logging, error handling, and naming.
- **Knowledge** — a structured index pointing to authoritative vendor documentation (Microsoft, VMware, OpenStack, Red Hat, Ubuntu, Veeam, Wazuh, PostgreSQL, Ansible), with a defined place for internal organizational standards to sit alongside it.
- **Playbooks / Checklists / Policies** — operational, repeatable guidance for recurring engineering and governance tasks.

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

## Status

This repository is being built incrementally, one milestone at a time. See `CHANGELOG.md` for progress and `docs/roadmap.md` (once created) for what's next.

## Getting started

Each agent in `agents/` is self-contained: read its `AGENT.md` for mission, scope, and how to invoke it. Each workflow in `workflows/` is designed to be followed end-to-end by the relevant specialist agent, producing artifacts that map directly to the templates in `templates/`.
