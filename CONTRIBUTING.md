# Contributing

This repository is a living knowledge base for infrastructure engineering agents, workflows, templates, and standards. Contributions should keep it internally consistent and audit-ready.

## Adding or editing content

1. **Agents** (`agents/<slug>/AGENT.md`) — must include: Mission, Scope, Responsibilities, Decision Framework, Vendor Guidance, Escalation Rules, Deliverables, Output Format, Quality Checklist. See `agents/_TEMPLATE.md`.
2. **Workflows** (`workflows/<slug>/WORKFLOW.md`) — must include: Executive Summary, Prerequisites, Assessment, Risk Analysis, Dependencies, Implementation, Validation, Rollback, Acceptance Criteria, Lessons Learned. See `workflows/_TEMPLATE.md`.
3. **Templates** (`templates/<name>.md`) — must state which agent(s)/workflow(s) use it, and which compliance frameworks it's designed to satisfy (PCI-DSS, ISO 27001, COBIT, ITIL v4).
4. **Standards** (`standards/<topic>.md`) — must be specific and testable (e.g. "all PowerShell scripts must use `[CmdletBinding()]` and `-WhatIf` support for state-changing cmdlets" rather than "write clean code").

## Style rules

- Markdown only for documentation; fenced code blocks with language hints for all code/config.
- No placeholder text (`TODO`, `[insert]`, `lorem ipsum`) in anything presented as a finished artifact.
- Every workflow step that changes production state must have a corresponding validation and rollback step.
- Reference the specific standard/control where a requirement originates (e.g. "PCI-DSS v4.0 Req. 10.2" rather than "for compliance").

## Versioning

This repo uses semantic-ish versioning by milestone, tracked in `CHANGELOG.md`. Each milestone that adds or materially changes an agent, workflow, or standard should get a `CHANGELOG.md` entry.

## Review checklist before merging

- [ ] Follows the relevant template structure exactly (no missing sections).
- [ ] No placeholder content.
- [ ] Assumptions and risks stated explicitly.
- [ ] Rollback path present (or explicitly justified as not applicable).
- [ ] Cross-links added (agent references the templates/workflows it uses, and vice versa).
- [ ] `CHANGELOG.md` updated.
