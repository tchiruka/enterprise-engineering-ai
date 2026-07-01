# Contributing

This repository is a living knowledge base for infrastructure engineering agents, workflows, templates, and standards. Contributions should keep it internally consistent and audit-ready.

## Adding or editing content

1. **Agents** (`agents/<slug>/AGENT.md`) — must include: Mission, Scope, Responsibilities, Decision Framework, Vendor Guidance, Escalation Rules, Deliverables, Output Format, Quality Checklist. See `agents/_TEMPLATE.md`.
2. **Workflows** (`workflows/<slug>/WORKFLOW.md`) — must include: Executive Summary, Prerequisites, Assessment, Risk Analysis, Dependencies, Implementation, Validation, Rollback, Acceptance Criteria, Lessons Learned. See `workflows/_TEMPLATE.md`. Where a domain has multiple related but distinct procedures (e.g. build vs. upgrade vs. decommission), use one workflow document with multiple named Scenarios sharing common Prerequisites/Assessment/Risk Analysis/Dependencies sections, rather than fragmenting into several near-duplicate documents — see `docs/architecture.md`'s "Workflow structure" section for why.
3. **Templates** (`templates/<name>.md`) — must state which agent(s)/workflow(s) use it, and which compliance frameworks it's designed to satisfy (PCI-DSS, ISO 27001, COBIT, ITIL v4).
4. **Standards** (`standards/<topic>.md`) — must be specific and testable (e.g. "all PowerShell scripts must use `[CmdletBinding()]` and `-WhatIf` support for state-changing cmdlets" rather than "write clean code").
5. **Playbooks** (`playbooks/<slug>/PLAYBOOK.md`) — for the *decision process and communication cadence* around a cross-cutting event that can span multiple agents' domains (e.g. incident response, DR failover), as distinct from a workflow's single-domain technical procedure. See `docs/architecture.md`'s "Playbooks vs. workflows" section and `docs/glossary.md` for the distinction. No fixed template exists yet for playbooks the way `workflows/_TEMPLATE.md` exists for workflows — the two existing playbooks (`playbooks/incident-response/PLAYBOOK.md`, `playbooks/disaster-recovery-failover/PLAYBOOK.md`) are the closest thing to a reference pattern; a formal `playbooks/_TEMPLATE.md` is a reasonable future addition once a third playbook confirms the pattern generalizes.
6. **Examples** (`examples/<slug>/WALKTHROUGH.md` or, for real-incident RCAs formatted against `templates/rca.md`, `examples/<slug>/RCA.md`) — worked, end-to-end demonstrations showing how an agent, a workflow or programme charter, and the platform's templates compose into an actual deliverable. Include at least some examples showing a failure/rollback path, not only clean successes, and prefer real (even if retroactively formatted) incidents over synthetic ones where a real one is available — see `examples/sssd-ldap-firewall-rca-real-incident/RCA.md` for the pattern of clearly labeling which kind an example is.

## Multi-vendor / multi-engine discipline

Where an agent's domain spans more than one vendor or engine (e.g. `agents/network-architect/AGENT.md` across Juniper/Cisco/Mellanox/Supermicro/Fortinet/SonicWall, or `agents/database-engineer/AGENT.md` across PostgreSQL/MySQL/MSSQL), the agent must require the specific vendor/engine be stated explicitly in any output, and must not present guidance for one as if it transfers to another. State this explicitly in the agent's Vendor Guidance and Decision Framework sections rather than leaving it implied.

## Style rules

- Markdown only for documentation; fenced code blocks with language hints for all code/config.
- No placeholder text (`TODO`, `[insert]`, `lorem ipsum`) in anything presented as a finished artifact.
- Every workflow step that changes production state must have a corresponding validation and rollback step.
- Reference the specific standard/control where a requirement originates (e.g. "PCI-DSS v4.0 Req. 10.2" rather than "for compliance").
- If a new file introduces a platform-specific term intended for reuse elsewhere (e.g. a new named pattern like "canary-first"), add it to `docs/glossary.md` in the same change — don't let terminology accumulate undefined.
- If a new file references a vendor documentation source not already catalogued, add it to `knowledge/index.md` in the same change, per that document's own maintenance note.
- Periodically (every 3-4 milestones, or before any release/tag) re-run the cross-reference consistency check described in `docs/cross-reference-audit-milestone-13.md` and update that document in place rather than spawning a new numbered successor, unless the audit methodology itself changes — or, preferably, run `tests/validate-repo.sh`, which automates this check plus agent/workflow structural validation and placeholder-text scanning. See `tests/README.md`.

## Versioning

This repo uses semantic-ish versioning by milestone, tracked in `CHANGELOG.md`. Each milestone that adds or materially changes an agent, workflow, or standard should get a `CHANGELOG.md` entry.

## Review checklist before merging

- [ ] Follows the relevant template structure exactly (no missing sections).
- [ ] No placeholder content.
- [ ] Assumptions and risks stated explicitly.
- [ ] Rollback path present (or explicitly justified as not applicable).
- [ ] Cross-links added (agent references the templates/workflows it uses, and vice versa).
- [ ] `CHANGELOG.md` updated.
