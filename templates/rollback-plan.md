# Template: Rollback Plan

> Every workflow's Rollback section and every change request's Rollback Plan field should be able to point to a completed version of this template for any change of Medium risk or above. For Low-risk, easily reversible changes, an inline summary in the change request may suffice — use judgment, but default to using this template explicitly rather than skipping it, since "we'll figure out rollback if needed" is exactly the failure mode this exists to prevent.

## Change Reference

| Field | Value |
|---|---|
| Related CR number | |
| Related workflow / scenario | e.g. `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`, Scenario B |
| Prepared by | |
| Date | |

## Rollback Classification

Choose the category that applies — this determines the shape of the rest of the document:

- [ ] **Clean rollback available** — the change can be fully reversed to the prior state.
- [ ] **Partial rollback available** — some aspects can be reversed, others cannot (specify which).
- [ ] **No rollback available** — the change is one-directional once committed (e.g. certain in-place OS upgrades). A forward-fix contingency is mandatory in this case.

State explicitly *why* this classification applies — don't just tick a box. E.g. "In-place ESXi host upgrades do not support downgrade; classified as No rollback available. Forward-fix contingency: reinstall from prior-version ISO if the upgraded host fails validation."

## Trigger Conditions

The specific, objective conditions under which rollback should be executed rather than continuing to troubleshoot forward. Vague criteria ("if something goes wrong") lead to indecision during an actual incident — be specific: "If `repadmin /replsummary` still shows failures 30 minutes after the change, or if any downstream authentication-dependent system reports outage, initiate rollback."

## Rollback Procedure

Numbered, step-by-step, exact commands where applicable — written with the same rigor as the original Implementation steps, because rollback is executed under time pressure and cannot afford ambiguity.

```text
1. ...
2. ...
```

## Time Cost

Estimated time to execute the rollback procedure fully, and confirmation this fits within the approved maintenance window alongside the forward implementation time. If it doesn't fit, the maintenance window is under-scoped — fix that before proceeding with the change, not after.

## Data Loss / State Loss Implications

Does rollback lose any state created or changed since the original change began (e.g. transactions processed, objects created, configuration drift)? State this explicitly — "none" is a valid answer but must be stated, not assumed.

## Validation After Rollback

How to confirm the rollback itself succeeded and the environment is back to a known-good state — not just "the change was reverted" but specific checks with expected output, matching the rigor of the original Validation section.

## Forward-Fix Contingency (mandatory if "No rollback available" is selected above)

If rollback isn't possible, what's the plan if the change fails validation? This might be "restore from the pre-change backup" (which is itself a form of rollback via a different mechanism — state which) or "proceed with troubleshooting in the new state since there's no path back." Be explicit about which it is; do not leave this implicit.

## Decision Authority

Who has authority to invoke rollback during the change window, and do they need to consult anyone before doing so, or can they act unilaterally within pre-agreed trigger conditions? For high-risk changes, name the person, not just the role.
