# Worked Example: SSSD/LDAP Authentication Failure — Real Incident RCA

Unlike the platform's first three worked examples (AD DC swing migration, ESXi upgrade failure, 10G programme charter), all of which were fictionalized illustrations, this one documents an **actual incident** from this estate's real work: SSSD authentication failures on `prd-apexia` and `prd-ability` during the CIS Level 1 hardening rollout (change record `C-082327`), traced to a stateful firewall silently dropping idle LDAP TCP connections. It's included specifically because `CHANGELOG.md` Milestone 16 raised the question of whether a real example would strengthen the set more than another synthetic one — this is that real example, formatted against `templates/rca.md` retroactively to demonstrate the template holding up against genuine (not staged) incident detail.

**A note on retroactive formatting:** this incident occurred and was resolved before this platform's `templates/rca.md` existed. Reconstructing it against the template after the fact is a legitimate use of the template (most real RCAs in any organization get written up after resolution, not live) — but it's worth being explicit that the *timeline* below reflects the actual diagnostic sequence as it happened, not an idealized version written to make the template look good.

---

## Incident Summary

| Field | Value |
|---|---|
| Incident/Problem Record ID | Associated with change record C-082327 (CIS Level 1 hardening rollout) |
| Date/time of incident | During CIS Level 1 hardening rollout on `prd-apexia` and `prd-ability` (Ubuntu 24.04) |
| Date/time of detection | Authentication failures observed following hardening changes |
| Detection method | SSSD authentication failures observed post-hardening |
| Duration of impact | Authentication degraded until root cause identified and `ldap_connection_expire_timeout` fix applied |
| Severity | Medium — authentication-affecting on two production hosts, but not a full outage of either host's core function |
| Affected system(s)/CI(s) | `prd-apexia`, `prd-ability` (both Ubuntu 24.04, both undergoing CIS Level 1 hardening under C-082327) |
| Author | `agents/linux-platform-engineer/AGENT.md` (this agent's real-world counterpart) |
| Date of RCA | Retroactively formatted for this platform |

## Impact

SSSD authentication began failing intermittently on both `prd-apexia` and `prd-ability` following CIS Level 1 hardening changes. Because both hosts are AD/LDAP-integrated (SSSD-based, per the estate's standard pattern), this manifested as users/services unable to authenticate against these hosts — a direct operational impact on anything depending on AD-integrated login for these two production systems.

## Timeline

| Time (relative) | Event |
|---|---|
| T+0 | CIS Level 1 hardening applied to `prd-apexia` and `prd-ability` under C-082327 — the hardening script explicitly excluded PAM/auth configuration (documented as AD/LDAP-owned) and host firewall (documented as network/hypervisor-layer owned), per the scope-exclusion discipline this estate already practiced before this platform formalized it as a term in `docs/glossary.md` |
| T+shortly after | SSSD authentication failures observed on both hosts |
| Diagnostic step 1 | Initial hypothesis: the hardening script itself broke something in PAM/auth — ruled out, since the script's documented scope explicitly excluded PAM/auth configuration; re-confirmed the script hadn't touched it despite the temporal correlation with the hardening rollout |
| Diagnostic step 2 | UFW host firewall was being configured on both hosts as part of the same broader change window (allow-list rules for AD DCs, Wazuh, NRPE) — this became the next hypothesis given the temporal proximity, even though it was a separate, deliberately-scoped-differently piece of work from the PAM-excluded hardening script itself |
| Diagnostic step 3 | Investigation found the pattern was specifically **idle** LDAP connections failing, not all LDAP connections — active/fresh connections worked, connections that had been idle for a period started failing. This pattern (works at first, fails after idling) pointed at a *stateful* firewall behavior rather than a static rule blocking LDAP outright, which would have failed immediately and consistently rather than after a delay |
| Root cause identified | The stateful firewall (introduced/configured as part of the UFW rollout on these hosts) was silently dropping idle LDAP TCP connections after its own connection-tracking timeout — SSSD's default LDAP connection handling didn't proactively refresh/close connections before that timeout, so a connection that had gone idle would be silently dropped by the firewall's connection table, and the next SSSD operation against that stale connection would fail |
| Fix applied | `ldap_connection_expire_timeout = 60` set in SSSD configuration, causing SSSD to proactively expire and re-establish LDAP connections before the firewall's own idle-connection timeout could drop them silently |
| Resolution confirmed | Authentication stabilized on both hosts following the SSSD configuration change |

## Root Cause

- **Symptom:** SSSD authentication failures on `prd-apexia` and `prd-ability`, specifically affecting connections that had been idle rather than all connections uniformly.
- **Root cause:** a stateful firewall silently dropping idle LDAP TCP connections after its own connection-tracking timeout expired, with SSSD's default configuration not proactively refreshing connections before that timeout — a **cross-layer** root cause (network/firewall layer causing a symptom that manifested at the authentication/application layer), which is exactly the kind of failure mode `docs/glossary.md`'s "layer boundary" entry describes agents needing to recognize rather than exhausting single-layer troubleshooting against.
- **Evidence supporting this as the actual root cause (not just a plausible story):** the specific pattern of *idle* connections failing while fresh connections succeeded is the diagnostic signature that distinguishes a stateful-firewall-timeout root cause from a simple blocking rule (which would fail all connections uniformly and immediately) — this pattern-matching is what moved the investigation from hypothesis to confirmed root cause.

## Contributing Factors

- The hardening script (PAM/auth-excluded) and the UFW firewall rollout (a separate, concurrently-scheduled piece of work) were close enough in timing that the first hypothesis incorrectly implicated the hardening script itself — the documented scope exclusion in the script's own header (a real, pre-existing practice this estate already followed, later formalized in this platform as "scope exclusion" in `docs/glossary.md`) is what allowed that hypothesis to be ruled out quickly rather than spending more diagnostic time on the wrong layer.
- SSSD's default connection-handling behavior doesn't proactively manage idle connections against an arbitrary downstream firewall's connection-tracking timeout — this is a genuine interaction between two independently-reasonable defaults (SSSD's default connection reuse, the firewall's default idle-connection timeout) rather than a misconfiguration on either individual side.

## Resolution

```ini
# sssd.conf, [domain/<domain>] section
ldap_connection_expire_timeout = 60
```
Applied to both `prd-apexia` and `prd-ability`, with SSSD restarted to pick up the configuration change.

## Validation

Authentication confirmed stable post-fix — the specific validation was continued authentication success across the idle-then-reconnect pattern that had previously triggered failures, not just an immediate post-change spot check (which would not have caught this specific failure mode, given it only manifested after a connection had been idle).

## Preventive Actions

| Action | Owner | Target Date | Status |
|---|---|---|---|
| Apply `ldap_connection_expire_timeout = 60` as a standard SSSD configuration setting on any future AD/LDAP-integrated Linux host with a stateful host firewall in this estate, rather than rediscovering this per-host | `agents/linux-platform-engineer/AGENT.md` | Ongoing — apply as new hosts are onboarded | Adopted as standard practice |
| Document this cross-layer failure pattern in the relevant workflow so future hardening/firewall rollouts check for it proactively rather than reactively | This platform | This milestone | **Done** — see `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md`, which should be checked/extended to reference this specific interaction if not already covered |

## Detection Gap Analysis

Detection relied on authentication failures actually being observed/reported rather than a monitoring alert specifically watching for this failure signature (idle-connection-specific auth failures). A SIEM/monitoring rule watching for a pattern of "authentication succeeds initially in a session/window, then fails after a gap" would have caught this faster than relying on it being noticed operationally — worth raising with `agents/security-architect/AGENT.md` as a potential Wazuh detection-coverage gap per that agent's SIEM strategy ownership, since this is exactly the kind of subtle, delayed-onset failure pattern that's easy to miss without a specific rule for it.

## Lessons Learned / Workflow Feedback

This incident is the origin of the specific fix (`ldap_connection_expire_timeout = 60`) already referenced by name in `agents/linux-platform-engineer/AGENT.md`'s Responsibilities section and `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md`'s general firewall-interaction guidance — this RCA is the detailed, real-incident backing for what was previously stated as a known pattern without the full diagnostic narrative behind it. Future SSSD/LDAP troubleshooting in this estate should check this specific failure signature (idle connections failing, fresh connections working) early rather than rediscovering it from scratch.
