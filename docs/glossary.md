# Glossary

Platform-specific terms used consistently across agents, workflows, templates, and examples, but never centrally defined until now. If a term below is used in a file with a meaning that drifts from this definition, that's a documentation bug — fix the usage or fix this glossary, but don't let them diverge silently.

## Blast radius

The scope of impact if a change goes wrong — stated as a concrete range (single host → cluster → domain/site → estate-wide), never left implicit. Every workflow's Risk Analysis section and every agent's Decision Framework requires blast radius to be stated explicitly before proceeding, because it's the single factor that most determines how much rollback/validation rigor a change needs. See `docs/architecture.md` and any `workflows/*/WORKFLOW.md` Risk Analysis section for usage in context.

## Canary-first (pattern)

Introduced in `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` (Milestone 11) and retrofitted into the AD DC and VMware ESXi/vCenter workflows (Milestone 12): applying a change to the lowest-impact instance of a repeated pattern first (one DC in a multi-DC programme, one host in a cluster, one server in a fleet-wide hardening rollout), validating it fully, and only then proceeding to the remainder — rather than rolling a change out broadly on the first attempt. Distinct from the within-cluster rolling-host approach already present in the VMware workflow (which is itself a form of canary-first, just at a finer grain); the retrofit specifically added *programme-level* canary selection (e.g. pick the lowest-impact site/domain first across a multi-forest AD upgrade programme) on top of the *within-change* rolling approach that already existed.

## Compensating control

A control implemented in place of a primary control that can't currently be applied, reducing risk without fully closing the gap — tracked explicitly with a remediation deadline rather than treated as a permanent substitute. Owned by `agents/security-architect/AGENT.md`'s compensating-control register. Distinct from simply accepting a risk with no mitigation at all — a compensating control is an active, if partial, mitigation.

## Forward-fix contingency

The required companion to any "No rollback available" classification in `templates/rollback-plan.md`: an explicit plan for what happens if a one-directional change fails validation, since there's no path back to the prior state. See `examples/vmware-esxi-upgrade-failure-rollback/WALKTHROUGH.md` for a fully worked example of a forward-fix contingency being defined in advance and then actually executed.

## Layer boundary

The explicit "in scope / out of scope, routes to X" division between two agents whose domains sit adjacent to or on top of each other — e.g. `agents/vmware-architect/AGENT.md` (hypervisor layer) vs. `agents/windows-infrastructure-engineer/AGENT.md` (guest-OS layer) vs. `agents/backup-dr-architect/AGENT.md` (backup-product layer), all of which can be involved in the same incident without any one of them owning the others' work. See `docs/architecture.md`'s agent roster table for the full set of layer boundaries currently defined.

## Recoverability (vs. backup success)

The distinction, owned by `agents/backup-dr-architect/AGENT.md`, between a backup job reporting a green/successful status and a backup actually being restorable. A green job status alone is never treated as evidence of recoverability in this platform — periodic restore/verification testing (e.g. SureBackup or equivalent) is required to make that claim.

## Risk classification (Low / Medium / High)

The `templates/change-request.md` field summarizing a change's overall risk, derived from blast radius, reversibility, and compliance scope — always accompanied by an explicit justification, never left as a bare label. See `templates/change-request.md`'s Risk Assessment section.

## Scope exclusion (documented)

A hardening or configuration control deliberately *not* applied by a given script/role because it belongs to another agent's domain — stated explicitly in the deliverable itself (e.g. a CIS hardening script's header noting "PAM/auth excluded — AD/LDAP-owned"), not left as a silent gap someone might mistake for an oversight. This is a specific application of the broader layer boundary concept, made visible at the artifact level rather than only in agent documentation. See `agents/linux-platform-engineer/AGENT.md` and `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` for the canonical example.

## Trigger condition

A specific, objective condition (not a vague "if something goes wrong") that determines when to invoke rollback rather than continue troubleshooting forward — required field in `templates/rollback-plan.md`, decided in advance of executing a change rather than improvised during an incident.

## MUST / SHOULD / MAY

The three-tier classification used throughout workflows and agent decision frameworks to distinguish mandatory requirements from recommendations from optional judgment calls, borrowed from RFC 2119-style requirement language. A workflow step or rule should use one of these terms explicitly wherever the level of obligation isn't already obvious from context — an unlabeled instruction defaults to being read as SHOULD, not MUST, so anything genuinely mandatory needs the word stated.

## Programme (vs. workflow, vs. change)

Three distinct scales of work this platform tracks with three distinct artifacts: a **change** (`templates/change-request.md`) is a single CAB-approved action; a **workflow** (`workflows/*/WORKFLOW.md`) is a reusable, repeatable procedure that a change might follow; a **programme** (`templates/programme-charter.md`) is a multi-phase initiative spanning many changes and potentially many different workflows, with its own governance and cross-workstream dependency tracking. See `agents/chief-infrastructure-engineer/AGENT.md`, which owns programme-level artifacts specifically.

## Maintenance note

Add a term here whenever a new file introduces platform-specific vocabulary intended to be reused elsewhere — the value of this glossary depends on it staying current, the same principle already stated for `knowledge/index.md`.
