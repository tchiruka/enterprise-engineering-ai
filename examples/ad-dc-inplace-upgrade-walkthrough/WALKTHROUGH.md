# Worked Example: AD DC In-Place Upgrade (Scenario B)

This is a fictionalized but realistic worked example showing how an agent, a workflow, and the platform's templates compose into an actual deliverable — end to end, not just each artifact existing in isolation. It follows `agents/windows-infrastructure-engineer/AGENT.md` executing Scenario B ("In-Place OS Upgrade") of `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`.

**Scenario:** A domain controller, `PRD-DC03`, in a fictional domain `corp.example.com`, is being upgraded in place from Windows Server 2016 to Windows Server 2022, ahead of Windows Server 2016 Extended Support end-of-life.

---

## Step 1 — Agent identifies the correct workflow

`windows-infrastructure-engineer` receives the request "upgrade PRD-DC03 to Server 2022." Per its Decision Framework: this is AD DS-specific (not general Windows Server work), so the full AD DC Lifecycle workflow applies. The agent checks whether an in-place upgrade path from 2016 → 2022 is supported (it is not, directly — Microsoft's supported path requires either 2016 → 2019 → 2022 sequential upgrade, or a swing migration). This finding changes the plan: **Scenario C (Swing Migration) applies, not Scenario B**, because the direct in-place path isn't supported.

*This is itself the point of the worked example: the workflow's Decision Framework step ("confirm forest/domain functional level supports the target OS as a DC... do not assume all upgrade paths are supported in-place") caught a planning error before it became an implementation error.*

## Step 2 — Assessment (shared across all scenarios)

```powershell
dcdiag /v /c /d /e /s:PRD-DC03 > dcdiag_PRD-DC03_20260701.log
repadmin /replsummary
repadmin /showrepl * /csv > replsummary_20260701.csv
netdom query fsmo
```

**Result (fictional, for illustration):** `dcdiag` clean, zero replication failures, `PRD-DC03` holds no FSMO roles. Baseline is healthy — safe to proceed.

## Step 3 — Risk classification

Blast radius: single DC in a domain with two other healthy DCs — **Medium risk**, not High, since redundancy exists. If `PRD-DC03` were the last DC in the domain, this would escalate per the workflow's MUST rule.

## Step 4 — Change Request produced (using `templates/change-request.md`)

> Excerpt — abbreviated for this example; a real CR would complete every field.

| Field | Value |
|---|---|
| Title | DC Replacement (Swing Migration): PRD-DC03 (corp.example.com) Server 2016 → PRD-DC05 Server 2022 |
| Risk classification | Medium — single DC of three in domain, no FSMO roles held, replication healthy |
| Affected CI(s) | PRD-DC03, new build PRD-DC05 |

**Implementation Plan (referencing the workflow rather than duplicating it):** "Follow `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`, Scenario C (DC Replacement / Swing Migration): build PRD-DC05 on Server 2022 (Scenario A), confirm replication convergence, transfer no FSMO roles (none held by source), update DNS/DHCP scope options and any static references to PRD-DC03's IP, demote PRD-DC03 after a 14-day burn-in window."

**Validation Plan:** "`dcdiag /v` clean on PRD-DC05; `repadmin /showrepl` confirms replication with both remaining DCs within one cycle; no authentication or DNS query volume observed against PRD-DC03's IP during the 14-day burn-in window (monitored via Wazuh)."

## Step 5 — Rollback Plan produced (using `templates/rollback-plan.md`)

**Rollback Classification:** Clean rollback available. Justification: "PRD-DC03 is kept running, untouched, until burn-in completes — per the swing migration pattern, this is inherently lower-risk than in-place upgrade specifically because the old DC remains the rollback path."

**Rollback Procedure:** "Do not demote PRD-DC03. Redirect any client found still depending on it back to using it as primary, investigate the missed dependency, and extend the burn-in window before re-attempting demotion."

**Time Cost:** "Immediate — rollback is the absence of the final demotion step, not an active reversal."

## Step 6 — Execution produces evidence for Acceptance Criteria

After execution (fictional outcome for this example): PRD-DC05 built, replication converged within 40 minutes, no FSMO transfer needed, DNS/DHCP updated, 14-day burn-in showed zero unexpected traffic to PRD-DC03, demotion completed cleanly.

## Step 7 — If something had gone wrong: RCA produced (using `templates/rca.md`)

Not needed in this fictional successful outcome — but if, say, an application server had been found during burn-in still statically pointing at PRD-DC03's IP for LDAP binds, that would trigger: (a) rollback is not even needed since PRD-DC03 is still running, (b) an RCA documenting the missed dependency, its root cause (static IP configuration undocumented in CMDB), and a preventive action to audit static LDAP references before future DC retirements — fed back into the workflow's Lessons Learned section per the standard pattern.

---

## What this example demonstrates

1. The workflow's Decision Framework caught a planning error (assumed in-place path that doesn't exist) before implementation — this is the actual value of having decision frameworks encoded rather than jumping straight to execution.
2. The change request didn't duplicate the workflow's procedural detail — it referenced the workflow and scenario, keeping the authoritative how-to in one place.
3. The rollback plan's classification ("clean rollback available") was a direct consequence of choosing the swing migration scenario over in-place upgrade — a decision made in Step 1 that shaped every downstream artifact.
4. Acceptance criteria and RCA hooks tie back to the same workflow document, so lessons from a real execution have an obvious home to be recorded in.

This is the composition the platform is designed to produce: agent judgment → correct workflow selection → standardized artifacts that reference rather than duplicate each other → a documented outcome that feeds back into the system.
