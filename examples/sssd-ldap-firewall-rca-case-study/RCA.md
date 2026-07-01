# Worked Example: SSSD/LDAP Authentication Failure — Diagnostic Case Study

Unlike the platform's other worked examples (AD DC swing migration, ESXi upgrade failure, 10G programme charter), which are clearly fictionalized illustrations, this one is based on a **real, well-documented failure pattern** seen across engagements involving AD/LDAP-integrated Linux hosts sitting behind a stateful firewall — reconstructed here as an anonymized composite case study rather than tied to any specific client, host, or change record. It's included because the underlying diagnostic pattern (a cross-layer failure that looks like an application problem but is actually a network-layer one) is genuinely valuable and worth walking through in full detail against `templates/rca.md`, without attaching it to any one organization's infrastructure.

**A note on this format:** this is written retroactively against `templates/rca.md`'s structure, which is a legitimate and common way real RCAs get produced (most incidents get written up after resolution, not live). The diagnostic sequence below reflects how this class of issue is actually typically found and resolved, not an idealized version invented to make the template look good.

---

## Incident Summary

| Field | Value |
|---|---|
| Incident/Problem Record ID | Illustrative — associated with a CIS Level 1 hardening change window |
| Date/time of incident | During a CIS Level 1 hardening rollout on two AD/LDAP-integrated Ubuntu 24.04 hosts |
| Date/time of detection | Authentication failures observed following hardening changes |
| Detection method | SSSD authentication failures observed post-hardening |
| Duration of impact | Authentication degraded until root cause identified and `ldap_connection_expire_timeout` fix applied |
| Severity | Medium — authentication-affecting on production hosts, but not a full outage of either host's core function |
| Affected system(s)/CI(s) | Two Ubuntu 24.04 hosts, both AD/LDAP-integrated via SSSD, both undergoing CIS Level 1 hardening in the same change window |
| Author | `agents/linux-platform-engineer/AGENT.md` |
| Date of RCA | Retroactively formatted for this platform |

## Impact

SSSD authentication began failing intermittently on both hosts following CIS Level 1 hardening changes. Because both hosts are AD/LDAP-integrated (SSSD-based, a common pattern for Linux hosts joined to an AD-based identity provider), this manifested as users/services unable to authenticate — a direct operational impact on anything depending on AD-integrated login for these two systems.

## Timeline

| Time (relative) | Event |
|---|---|
| T+0 | CIS Level 1 hardening applied to both hosts under a single change window — the hardening script explicitly excluded PAM/auth configuration (documented as AD/LDAP-owned) and host firewall (documented as network/hypervisor-layer owned), following the scope-exclusion discipline `docs/glossary.md` formalizes as a named platform term |
| T+shortly after | SSSD authentication failures observed on both hosts |
| Diagnostic step 1 | Initial hypothesis: the hardening script itself broke something in PAM/auth — ruled out, since the script's documented scope explicitly excluded PAM/auth configuration; re-confirmed the script hadn't touched it despite the temporal correlation with the hardening rollout |
| Diagnostic step 2 | A host firewall (UFW) was being configured on both hosts as part of the same broader change window (allow-list rules for AD DCs, monitoring, patch sources) — this became the next hypothesis given the temporal proximity, even though it was a separate, deliberately-scoped-differently piece of work from the PAM-excluded hardening script itself |
| Diagnostic step 3 | Investigation found the pattern was specifically **idle** LDAP connections failing, not all LDAP connections — active/fresh connections worked, connections that had been idle for a period started failing. This pattern (works at first, fails after idling) pointed at a *stateful* firewall behavior rather than a static rule blocking LDAP outright, which would have failed immediately and consistently rather than after a delay |
| Root cause identified | The stateful firewall was silently dropping idle LDAP TCP connections after its own connection-tracking timeout — SSSD's default LDAP connection handling didn't proactively refresh/close connections before that timeout, so a connection that had gone idle would be silently dropped by the firewall's connection table, and the next SSSD operation against that stale connection would fail |
| Fix applied | `ldap_connection_expire_timeout = 60` set in SSSD configuration, causing SSSD to proactively expire and re-establish LDAP connections before the firewall's own idle-connection timeout could drop them silently |
| Resolution confirmed | Authentication stabilized on both hosts following the SSSD configuration change |

## Root Cause

- **Symptom:** SSSD authentication failures on both hosts, specifically affecting connections that had been idle rather than all connections uniformly.
- **Root cause:** a stateful firewall silently dropping idle LDAP TCP connections after its own connection-tracking timeout expired, with SSSD's default configuration not proactively refreshing connections before that timeout — a **cross-layer** root cause (network/firewall layer causing a symptom that manifested at the authentication/application layer), which is exactly the kind of failure mode `docs/glossary.md`'s "layer boundary" entry describes agents needing to recognize rather than exhausting single-layer troubleshooting against.
- **Evidence supporting this as the actual root cause (not just a plausible story):** the specific pattern of *idle* connections failing while fresh connections succeeded is the diagnostic signature that distinguishes a stateful-firewall-timeout root cause from a simple blocking rule (which would fail all connections uniformly and immediately) — this pattern-matching is what moves an investigation from hypothesis to confirmed root cause.

## Contributing Factors

- The hardening script (PAM/auth-excluded) and the host firewall rollout (a separate, concurrently-scheduled piece of work) were close enough in timing that the first hypothesis incorrectly implicated the hardening script itself — a documented scope exclusion in the script's own header (the general practice this platform formalizes as "scope exclusion" in `docs/glossary.md`) is what allows that hypothesis to be ruled out quickly rather than spending more diagnostic time on the wrong layer.
- SSSD's default connection-handling behavior doesn't proactively manage idle connections against an arbitrary downstream firewall's connection-tracking timeout — this is a genuine interaction between two independently-reasonable defaults (SSSD's default connection reuse, the firewall's default idle-connection timeout) rather than a misconfiguration on either individual side.

## Resolution

```ini
# sssd.conf, [domain/<domain>] section
ldap_connection_expire_timeout = 60
```
Applied to both affected hosts, with SSSD restarted to pick up the configuration change.

## Validation

Authentication confirmed stable post-fix — the specific validation was continued authentication success across the idle-then-reconnect pattern that had previously triggered failures, not just an immediate post-change spot check (which would not have caught this specific failure mode, given it only manifested after a connection had been idle).

## Preventive Actions

| Action | Owner | Target Date | Status |
|---|---|---|---|
| Apply `ldap_connection_expire_timeout = 60` as a standard SSSD configuration setting on any AD/LDAP-integrated Linux host sitting behind a stateful firewall, rather than rediscovering this per-engagement | `agents/linux-platform-engineer/AGENT.md` | Ongoing — apply as new hosts are onboarded, across any client | Adopted as standard practice |
| Document this cross-layer failure pattern in the relevant workflow so future hardening/firewall rollouts check for it proactively rather than reactively | This platform | Done | `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md` references this fix by name in its firewall-interaction guidance |

## Detection Gap Analysis

Detection relied on authentication failures actually being observed/reported rather than a monitoring alert specifically watching for this failure signature (idle-connection-specific auth failures). A SIEM/monitoring rule watching for a pattern of "authentication succeeds initially in a session/window, then fails after a gap" would have caught this faster than relying on it being noticed operationally — worth raising with `agents/security-architect/AGENT.md` as a potential detection-coverage gap per that agent's SIEM strategy ownership, on any engagement running SSSD/LDAP-integrated hosts, since this is exactly the kind of subtle, delayed-onset failure pattern that's easy to miss without a specific rule for it.

## Lessons Learned / Workflow Feedback

This case study is the origin of the specific fix (`ldap_connection_expire_timeout = 60`) referenced by name in `agents/linux-platform-engineer/AGENT.md`'s Responsibilities section and `workflows/linux-cis-hardening-lifecycle/WORKFLOW.md`'s firewall-interaction guidance — this RCA is the detailed diagnostic backing for what's stated elsewhere as a known pattern, without the full narrative behind it. Any SSSD/LDAP troubleshooting on an AD-integrated Linux host behind a stateful firewall should check this specific failure signature (idle connections failing, fresh connections working) early, on any engagement, rather than rediscovering it from scratch each time.
