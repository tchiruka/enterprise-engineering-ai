# Template: Work Instruction

> Use for a single, narrow, highly prescriptive task — one operator, one task, no decision points. Produced by `agents/documentation-standards-architect/AGENT.md`. If a draft keeps adding branches or naming more than one role, it is not actually a Work Instruction — reclassify as an SOP (`templates/sop.md`) or Runbook (`templates/runbook.md`). Per `templates/framework-alignment-guide.md`, most Work Instructions need no standards citation at all — it's too granular; add one only if the single step is itself a security control.

## Document Control

| Field | Value |
|---|---|
| Document ID | WI-[System]-[NNN] |
| Version | |
| Parent SOP/Build Document | Reference the broader document this WI supports, if any |
| Owner | |

## Task

One sentence — exactly what this instruction accomplishes.

## Tools/Access Required

- [...]

## Steps

```text
1. [Exact action]
2. [Exact action]
3. [Exact action]
```

No branches, no "if/then." If a decision point is genuinely needed, this should be an SOP procedure instead.

## Expected Result

What the operator should see when the task is done correctly.

## If This Doesn't Work

Point to the parent SOP's Exception Handling section or a Runbook — don't duplicate troubleshooting logic here.
