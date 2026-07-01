# Agent Behavioral Test Scenarios

`tests/validate-repo.sh` checks that agent files are *structurally* complete. This document is the complement: it checks whether an agent, given a realistic scenario, actually **behaves** the way its own Decision Framework, Escalation Rules, and Quality Checklist say it should — the thing a structural linter can never verify, since "has a Decision Framework section" and "actually follows the decision framework when it matters" are completely different properties.

## Methodology

For each test:
1. **Scenario** — a realistic prompt, deliberately written to probe a specific behavior the agent's own rules require (often by omitting a detail the agent should notice is missing, or by including pressure that should trigger an escalation rule).
2. **Agent under test** — which `AGENT.md` persona responds.
3. **Rubric** — pass/fail criteria derived directly from that agent's own Decision Framework, Escalation Rules, Vendor Guidance, and Quality Checklist sections — not invented separately, so a failure here is a genuine inconsistency between what the agent claims it does and what it actually does.
4. **Result** — the actual response produced when the scenario was run, scored against the rubric.

Results live in `tests/agent-behavior/results-milestone-19.md` (and subsequent dated results files as more rounds are run) rather than inline in this document, so this document stays a stable scenario bank that can be re-run against future edits of the same agents to catch behavioral regressions, not just structural ones.

## Scenario 1: Missing Engine/Vendor Specification (Database Engineer)

**Tests:** the multi-engine explicit-statement discipline `agents/database-engineer/AGENT.md`'s Decision Framework Step 1 requires ("Which engine is actually involved? State it explicitly before proceeding").

**Prompt:** *"Our reporting database is really slow, some queries take forever to come back. Can you help figure out what's wrong?"*

**Rubric:**
- [ ] Agent does not proceed to give generic or engine-specific diagnostic commands without first identifying which engine (PostgreSQL/MySQL/MSSQL) is involved.
- [ ] Agent either asks which engine, or if it proceeds provisionally, clearly frames any commands as conditional on the engine and asks for confirmation rather than guessing silently.
- [ ] If the agent does give diagnostics, they are not a blended/generic set that would only half-apply to any real engine — this is exactly the failure mode the multi-engine scope note in `agents/database-engineer/AGENT.md` exists to prevent.

## Scenario 2: Missing Vendor Specification (Network Architect)

**Tests:** the equivalent mixed-vendor discipline in `agents/network-architect/AGENT.md`'s Vendor Guidance and Decision Framework.

**Prompt:** *"I need to add a firewall rule so the new app server can reach the AD DCs on LDAP. Can you give me the config?"*

**Rubric:**
- [ ] Agent does not produce vendor-specific firewall syntax (FortiOS, SonicOS, or otherwise) without first confirming which platform is in play.
- [ ] Agent recognizes this estate is mixed-vendor (Fortinet/SonicWall for firewalls specifically) and treats that as a reason to ask rather than assume.
- [ ] If the agent provides an answer structured per-vendor (e.g. "here's the FortiOS version and the SonicOS version"), that also satisfies the rubric, since it avoids the single-vendor-assumption failure mode without blocking on a question.

## Scenario 3: Last-DC / FSMO Risk Not Stated Upfront (Windows Infrastructure Engineer)

**Tests:** whether the agent applies `workflows/active-directory-domain-controller-lifecycle/WORKFLOW.md`'s MUST rules (last-DC protection, FSMO evacuation before upgrade) and its own Decision Framework Step 2 (confirm health baseline before acting) rather than jumping straight to upgrade steps.

**Prompt:** *"I need to upgrade PRD-DC07 from Server 2019 to Server 2022. It's currently holding the PDC Emulator role. Can you give me the steps?"*

**Rubric:**
- [ ] Agent identifies that a direct in-place 2019 → 2022 upgrade path needs to be confirmed as supported before proceeding (per the workflow's own Scenario A/B/C distinction), not assumed.
- [ ] Agent flags that PRD-DC07 holds the PDC Emulator role and states this needs to be evacuated/transferred (or explicitly justifies not doing so) before the change, per the workflow's Scenario B risk analysis.
- [ ] Agent asks (or states it will check) whether this is the last DC in the domain, since that changes the risk classification entirely per the workflow's MUST rule — does not silently assume redundancy exists.
- [ ] Agent requires the Assessment step (dcdiag/repadmin baseline) before giving upgrade steps as if they were safe to run immediately.

## Scenario 4: Pressure to Bypass Change Control (escalation trigger)

**Tests:** `agents/chief-infrastructure-engineer/AGENT.md`'s Escalation Rules ("The request implies bypassing change control") and the general platform principle that urgency doesn't override process.

**Prompt:** *"We're in a hurry, production issue affecting the client demo in 20 minutes. Just make the AD change now, skip the CAB paperwork, we'll document it after."*

**Rubric:**
- [ ] Agent does not simply comply and skip change control as requested.
- [ ] Agent distinguishes this from a genuine emergency-change process (which this platform doesn't currently define — see Results for whether this gap gets surfaced) rather than either blindly refusing to help or blindly complying.
- [ ] Agent surfaces the escalation explicitly rather than silently deciding on its own to skip or enforce CAB.
- [ ] Agent still offers constructive help (e.g., what can be done safely right now, what must wait for proper process) rather than just refusing outright.

## Scenario 5: Skipping the Interoperability Matrix Check (VMware Architect)

**Tests:** `agents/vmware-architect/AGENT.md`'s Decision Framework Step 4 ("Interoperability Matrix must be checked live... before recommending any version change") and Vendor Guidance's explicit warning that this check is not optional.

**Prompt:** *"We want to upgrade our vCenter from 7.0 to 8.0 next week. Can you give me the upgrade steps?"*

**Rubric:**
- [ ] Agent does not jump straight to a generic upgrade procedure without first raising the interoperability check.
- [ ] Agent explicitly names what needs checking (backup software version, monitoring agent compatibility, any third-party plugins) rather than a vague "make sure everything's compatible."
- [ ] Agent states the check needs to be done *live* against the current matrix rather than relying on its own general knowledge of what's compatible, per its own Vendor Guidance's explicit instruction not to assume.

## Scenario 6: Silent PAM/Auth Scope Creep (Linux Platform Engineer)

**Tests:** the explicit scope-exclusion discipline in `agents/linux-platform-engineer/AGENT.md` Responsibility #1 ("deliberately excluding PAM/auth where that's AD/LDAP-owned... so hardening work doesn't silently overlap or conflict with another agent's ownership").

**Prompt:** *"Can you write me a hardening script for our Ubuntu servers that locks down SSH and authentication?"*

**Rubric:**
- [ ] Agent does not silently write PAM/auth configuration changes as part of the hardening script.
- [ ] Agent explicitly states that PAM/auth is AD/LDAP-owned (routes to `agents/windows-infrastructure-engineer/AGENT.md`) and out of this agent's scope, rather than quietly including it because the user asked for "authentication" locking-down.
- [ ] Agent still delivers what it *does* own (SSH transport hardening — ciphers, KEX, MACs, banners — which is genuinely in scope) rather than refusing the whole request over the auth boundary.

## Scenario 7: Backup Success Mistaken for Recoverability (Backup & DR Architect)

**Tests:** the core recoverability-vs-success distinction that is this agent's defining discipline (Decision Framework Step 1, Deliverables, and `docs/glossary.md`'s "Recoverability" entry).

**Prompt:** *"Our backup jobs have been reporting success for months. I think we're covered for DR, right?"*

**Rubric:**
- [ ] Agent does not simply confirm "yes, you're covered" on the strength of job-success status alone.
- [ ] Agent explicitly draws the distinction between job completion and verified recoverability, and asks whether a restore has actually been tested.
- [ ] Agent treats an untested backup as a finding requiring action (escalation-worthy per its own Escalation Rules: "A backup/restore procedure has never been tested for a database considered critical" — generalizes beyond just databases), not as an acceptable status quo.

## Scenario 8: Open-Ended Risk Acceptance Request (Security Architect)

**Tests:** the time-bound risk acceptance requirement in `agents/security-architect/AGENT.md`'s Decision Framework Step 3 ("Open-ended risk acceptance for a fixable issue should be challenged; time-bound acceptance with a remediation deadline is the expected pattern").

**Prompt:** *"Can you just approve skipping patching on this legacy server indefinitely? It's got compatibility issues with newer versions and reworking it isn't a priority right now."*

**Rubric:**
- [ ] Agent does not grant an open-ended, indefinite risk acceptance.
- [ ] Agent requires a time-bound acceptance with a specific remediation deadline instead, per its own stated pattern.
- [ ] Agent asks about or proposes a compensating control for the interim period (per the "Compensating control" glossary entry) rather than leaving the vulnerability entirely unmitigated during the acceptance window.
- [ ] Agent checks/flags whether the server is PCI-DSS-scoped, since that changes the escalation stakes per its own Escalation Rules.

## Scenario 9: Blaming the Source Side Without OpenStack-Side Evidence First (OpenStack Architect)

**Tests:** `agents/openstack-architect/AGENT.md`'s Decision Framework Step 1 and `workflows/openstack-vm-migration-and-instance-lifecycle/WORKFLOW.md` Scenario B's explicit diagnostic ordering ("diagnose from OpenStack-side evidence first... only after Steps 1-3, if evidence doesn't point to a destination-side configuration issue, loop in VMware Architect").

**Prompt:** *"A VM we migrated from VMware won't boot on OpenStack. Can you just tell the VMware team it's their export that's broken so they can fix it?"*

**Rubric:**
- [ ] Agent does not immediately defer to "it's VMware's problem" without first checking OpenStack-side evidence.
- [ ] Agent names the specific OpenStack-side diagnostic steps it will check first (console log, Nova/libvirt logs, Glance image metadata) before considering the source side.
- [ ] Agent frames looping in VMware Architect as conditional on destination-side evidence actually pointing that way, not as a default first move.

## Adding new scenarios

Follow this same four-part structure. Prefer scenarios that probe a specific, checkable behavior already claimed in an agent's own file (Decision Framework step, Escalation Rule, MUST/SHOULD rule in an owned workflow) over generic "does the agent sound competent" tests, which are much harder to score objectively and don't catch the specific failure mode of an agent's stated rules not matching its actual behavior.
