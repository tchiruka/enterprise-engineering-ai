# Workflow: [Workflow Name]

> Template — copy this file to `workflows/<workflow-slug>/WORKFLOW.md` and complete every section. Remove this notice once done. No section may be left as a placeholder in a "finished" workflow.

**Owning agent(s):** [which specialist agent(s) execute this]
**Applies to:** [platforms/versions this workflow covers]
**Compliance frameworks referenced:** [PCI-DSS / ISO 27001 / COBIT / ITIL v4 / NIST — name specific clauses where known]

## Executive Summary

2-4 sentences: what this workflow does, why it exists, and the business/operational risk it manages. Written for a non-technical stakeholder or CAB reviewer.

## Prerequisites

Everything that must be true, available, or confirmed before this workflow can start:
- Access/permissions required
- Tools/software required
- Documentation/approvals required
- Environmental preconditions (e.g. backup completed and verified, maintenance window approved)

## Assessment

How to establish current state before acting. What to check, what commands/tools to run, what "healthy baseline" looks like. This is the diagnostic step that determines whether it's safe to proceed and informs the risk analysis below.

## Risk Analysis

- **Blast radius:** what is affected if this goes wrong (single host / cluster / domain / site).
- **Failure modes:** the specific ways this can fail, ranked by likelihood or severity.
- **Mitigations:** what reduces each risk.
- **MUST / SHOULD / MAY:** classify key decisions using these terms so mandatory steps are unambiguous.

## Dependencies

Other systems, teams, schedules, or workflows this depends on or affects (e.g. "must not run during month-end batch processing window", "depends on backup workflow completing successfully first").

## Implementation

The actual step-by-step procedure. Numbered, unambiguous, with exact commands/scripts where applicable in fenced code blocks with language hints. Each step that changes state should note what "success" looks like before moving to the next step.

## Validation

How to confirm the change worked and the environment is healthy afterward. Specific checks, expected output, thresholds.

## Rollback

The explicit procedure to revert if validation fails or an issue is discovered. If rollback is not possible or not applicable, state that explicitly and explain why, plus what the forward-fix path is instead.

## Acceptance Criteria

The checklist that must be true for this workflow to be considered successfully complete — this is what a CAB reviewer or the engineer's lead would check off.

## Lessons Learned

Leave this section present but empty in the initial version — it exists to be filled in after real executions of this workflow, capturing what went differently than planned. Note here: "To be populated after first production execution."
