# Template: Emergency Change

> Use this only for changes that genuinely cannot wait for standard CAB timing — a live production-down or severe-impact situation, not routine urgency or external deadline pressure ("client demo in 20 minutes" is a business-priority problem, not automatically a technical emergency; judge the two separately). This template exists because `tests/agent-behavior/results-milestone-19.md` (Scenario 4) found that this platform had no defined emergency path, forcing every agent to improvise a fallback answer independently rather than following a documented process. This does not replace `templates/change-request.md` — it is a compressed, expedited variant of it, and **every emergency change must still be followed by a full standard change request within 24 hours**, filed retroactively with this document attached as justification for the expedited path.

## When this template applies

Use Emergency Change only when **all** of the following are true:
- There is active, material production impact right now (not anticipated, not "will be embarrassing," but actually happening) — outage, severe degradation, active security incident, or imminent data loss.
- Waiting for standard CAB timing would materially worsen that impact.
- The change is the most direct available remediation, not a workaround being reached for because it's faster to implement than the correct fix.

If these aren't all true, use `templates/change-request.md` through standard timing instead, even under time pressure — per every agent's shared Escalation Rules, "we're in a hurry" alone does not justify bypassing change control, and an agent asked to do so should say so explicitly rather than complying, per the precedent set in `tests/agent-behavior/results-milestone-19.md`.

## Emergency Change Record

| Field | Value |
|---|---|
| Change reference | (assign immediately, even before full CR exists) |
| Requested by | |
| Emergency approver | Named individual with emergency-change authority — **not** a role alone; see Approval Authority below |
| Date/time | |
| Systems affected | |

## Justification (why this can't wait for standard CAB)

State the active impact and why standard timing would materially worsen it. This is the field a post-hoc reviewer will scrutinize most — be specific and factual, not just "it was urgent."

## Change Description

What is being done — as specific as time allows, but this doesn't need the full detail of a standard CR's Implementation Plan. If a relevant workflow exists (`workflows/`), reference which scenario is being followed even under compressed timing, since the workflow's own risk/rollback guidance still applies — an emergency doesn't suspend the underlying technical risk, only the approval timeline.

## Risk Acknowledged

State the risk being accepted by proceeding without standard review. If the change touches AD, a core switching upgrade, a database engine, or anything else with domain-wide/estate-wide blast radius per that domain's own workflow, say so explicitly — expedited approval does not mean the blast radius is smaller, only that the approval process is faster.

## Rollback

Even under emergency timing, state the rollback plan before proceeding — per `templates/rollback-plan.md`'s classification (clean / partial / none available) and forward-fix contingency if "none." Skipping this because of time pressure is exactly the scenario `templates/rollback-plan.md` was built to prevent improvisation in.

## Approval Authority

Emergency changes require approval from a named individual with delegated emergency-change authority — **not** a verbal "go ahead" from whoever happens to be reachable. If the client has not yet designated who holds that authority, that's itself a gap to close (flag to `agents/chief-infrastructure-engineer/AGENT.md` / a human decision-maker) rather than proceeding without any real approval and calling it emergency change. Record the approver's name and the approval timestamp here, even if given verbally/via chat — capture it in writing immediately after, not reconstructed later from memory.

## Mandatory Follow-Up

- [ ] Full `templates/change-request.md` filed within 24 hours, referencing this emergency change record.
- [ ] Post-implementation validation completed and documented, matching the rigor `templates/change-request.md`'s own Post-Implementation Review would require.
- [ ] If the change revealed a gap in a workflow, template, or standard (e.g. "we didn't have an emergency path and had to improvise X"), file that as a platform finding — the same discipline this template's own origin followed, rather than letting the same gap get rediscovered under pressure again next time.
