# Template: Standard Operating Procedure (SOP)

> Use for a repeatable, steady-state operational process — "how we do X," not a specific build or an incident response. Produced by `agents/documentation-standards-architect/AGENT.md`; the underlying technical steps should already be validated by the relevant domain specialist agent before this document is drafted. Consult `templates/framework-alignment-guide.md` before completing the Standards Alignment section — this template is designed to satisfy ITIL v4 Service Configuration Management / Change Enablement practice framing, with a light COBIT 2019 governance line where relevant.

## Document Control

| Field | Value |
|---|---|
| Document ID | SOP-[System/Area]-[NNN] |
| Version | |
| Status | Draft / Approved |
| Author | |
| Owner | The role responsible for keeping this current, not a named individual |
| Date created | |
| Last reviewed | |
| Next review due | Set a cadence — e.g. annual, or on next material system change |
| Classification | Per the client's information classification policy |

## 1. Purpose

1-3 sentences: what this SOP achieves and why it exists. What risk or inconsistency does it prevent?

## 2. Scope

**In scope:** systems, environments, and situations this SOP covers.

**Out of scope:** explicitly state what it does *not* cover, to prevent misapplication.

## 3. Roles and Responsibilities

| Role | Responsibility |
|---|---|
| | |

Name roles, not individuals — e.g. "the on-call engineer," not "someone."

## 4. Preconditions

- Access/permissions required.
- Tools/systems that must be available.
- Approvals needed before starting, if any.

## 5. Procedure

Numbered, atomic steps — one action per step. A step reading "configure X and verify Y" should be split into two steps. Each step states how success is confirmed at that point (command output, screenshot reference, log entry) — this is what makes the document audit-usable rather than merely descriptive.

```text
5.1 [Sub-process name, if the SOP has phases]
1. [Action]
   Verification: [how confirmed]
2. [Next action]
   Verification: [how confirmed]
```

## 6. Exception Handling

What to do if a step fails or an unexpected condition is hit. Point to the escalation path, or to a Runbook (`templates/runbook.md`) if the exception is itself complex enough to warrant one.

## 7. Rollback / Reversal

How to undo the procedure's effects, if applicable. If the process is genuinely non-destructive, state that explicitly rather than leaving the section blank.

## 8. Related Documents

Linked Build Documents, Runbooks, change control procedure, or policies.

## 9. Standards Alignment

2-5 lines, only the frameworks that genuinely apply — see `templates/framework-alignment-guide.md`. Example: "Aligned to ITIL v4 Service Configuration Management practice. Supports COBIT 2019 DSS01 (Managed Operations)." Verify any specific practice name or objective code via search before finalizing.

## 10. Revision History

| Version | Date | Author | Change summary |
|---|---|---|---|
| | | | Initial version |
