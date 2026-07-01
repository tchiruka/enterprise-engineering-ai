# Standard: Naming Conventions

Applies platform-wide: repository paths, agent/workflow slugs, script and playbook names, and — where this platform's guidance extends to the estates it documents — host, VM, and object naming in the environments themselves.

## Repository structure naming

- **Agent directories:** `agents/<kebab-case-role>/AGENT.md` — the slug should be the role, not a person or team (`vmware-architect`, not `tondes-vmware-agent`).
- **Workflow directories:** `workflows/<kebab-case-subject>-lifecycle/WORKFLOW.md` where the workflow spans a full lifecycle with multiple scenarios (established pattern: `active-directory-domain-controller-lifecycle`, `vmware-esxi-vcenter-upgrade-lifecycle`); drop `-lifecycle` for a workflow that's genuinely single-procedure rather than multi-scenario.
- **Templates:** `templates/<kebab-case-document-type>.md` — name the document type, not the use case (`change-request.md`, not `ad-change-request.md` — templates are cross-domain by design).
- **Standards:** `standards/<kebab-case-topic>.md` — name the language/tool/topic directly (`powershell.md`, `git.md`).
- **Examples:** `examples/<kebab-case-scenario-summary>/WALKTHROUGH.md` — the slug should describe the scenario walked through, including whether it's a success or failure case where that's the point (`vmware-esxi-upgrade-failure-rollback`, not just `vmware-esxi-upgrade-2`).

## Script and playbook naming

Already stated in the language-specific standards — repeated here as the canonical cross-reference:
- PowerShell: `Verb-Noun.ps1` using approved verbs (`standards/powershell.md`).
- Bash: `verb-noun.sh`, lowercase-hyphenated (`standards/bash.md`).
- Ansible roles: `verb-noun` or `noun-purpose`, lowercase-hyphenated, matching the role's primary function (`standards/ansible.md`).

## Git naming

Commit message and branch naming conventions are owned by `standards/git.md` — not duplicated here.

## Host and object naming in documented environments

This platform's workflows and agents reference existing host naming already in use in the estate (e.g. `PRD-DC03`, `PRD-ERIN`, `agave.sec.v.co.zw`) rather than prescribing a new scheme — retrofitting a naming convention onto an existing production estate is a separate, larger initiative than this platform's current scope. Where this platform's own worked examples (`examples/`) use fictional hostnames, they follow a `PRD-<ROLE><NUMBER>` pattern for production-tier fictional hosts, to stay legible and clearly distinguishable from any real hostname in the actual estate.

If a future initiative does establish or reform host naming conventions for the estate itself, document it here as a distinct section (e.g. "## Estate Host Naming Convention (adopted YYYY-MM-DD)") rather than retrofitting this document's structure.

## Variable and identifier naming (cross-language summary)

This is a summary pointer, not a restatement — see the authoritative language standard for full detail:
- PowerShell: `$PascalCase` script-scope, `$camelCase` local — `standards/powershell.md`.
- Bash: `UPPER_CASE` constants, `lower_case` local — `standards/bash.md`.
- Ansible variables: `snake_case`, matching Ansible community convention.

## Why this standard is thin

Naming conventions are already embedded in each language-specific standard where they need engineering precision (approved verbs, casing rules). This document exists to cover the *cross-cutting* layer — repository structure and the boundary between "prescribe a new scheme" versus "respect what's already in production" — rather than duplicating detail that's already correctly owned elsewhere. If this document starts accumulating language-specific detail, that's a sign it belongs in the relevant `standards/<language>.md` file instead.
