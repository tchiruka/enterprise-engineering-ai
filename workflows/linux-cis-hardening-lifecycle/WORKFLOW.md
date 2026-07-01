# Workflow: Linux CIS Hardening Lifecycle

**Owning agent(s):** Linux Platform Engineer (primary); Security Architect (baseline strategy, risk-acceptance arbitration); Windows Infrastructure Engineer (consulted for AD/LDAP-boundary items); Network Architect (consulted for host firewall-to-network-ACL boundary items)
**Applies to:** Ubuntu 20.04/22.04/24.04 and Red Hat-family (RHEL/CentOS-successor) servers
**Compliance frameworks referenced:** PCI-DSS v4.0 (Req. 2 — secure configuration; Req. 6.3 — vulnerability management), ISO/IEC 27001:2022 (A.8.9 configuration management, A.8.8 management of technical vulnerabilities), CIS Benchmarks (Ubuntu/RHEL, Level 1/Level 2)

## Executive Summary

CIS Benchmark hardening reduces attack surface on Linux hosts by disabling unnecessary services, enforcing secure kernel/filesystem/SSH parameters, and enabling integrity monitoring — but hardening applied carelessly can break legitimate application dependencies or authentication paths. This workflow covers the full lifecycle: baseline hardening on a new/existing host, handling documented exceptions where a control conflicts with an operational dependency, periodic re-audit to catch configuration drift, and a specific boundary discipline this platform recommends across engagements — deliberately excluding PAM/auth (AD/LDAP-owned) and host firewall design intent (network-layer-owned) from the hardening script itself, even though the script may configure the mechanism.

## Prerequisites (all scenarios)

- Root or sudo access to the target host(s), and Ansible control node access if applying via the `standards/ansible.md`-compliant hardening role rather than a standalone `standards/bash.md` script.
- Confirmed OS/distribution version and whether it's within vendor support (an EOL distribution changes the risk calculus — flag per `agents/linux-platform-engineer/AGENT.md`'s escalation rules rather than proceeding as routine).
- Target CIS Benchmark level identified (Level 1 or Level 2) and confirmed against Security Architect's baseline strategy for this host's classification (e.g. PCI-scoped hosts may warrant Level 2 where general-purpose hosts use Level 1).
- Documented exceptions register checked for this host/role — any known operational dependency that conflicts with a standard control should already be recorded, not rediscovered mid-implementation.
- Change record raised in the client's ITSM/CMDB platform (e.g. iTop, ServiceNow, or equivalent) for anything beyond a documented, pre-approved standard baseline application; validated against the client's own change-control validation criteria before CAB submission where required.
- Current backup/snapshot of the host confirmed, particularly for hardening applied to an already-in-service host rather than a fresh build.

## Assessment (all scenarios)

```bash
# OS and version
lsb_release -a 2>/dev/null || cat /etc/os-release

# Current AppArmor/SELinux status
aa-status 2>/dev/null || sestatus 2>/dev/null

# Current SSH configuration relevant to hardening targets
sshd -T | grep -iE 'permitrootlogin|passwordauthentication|protocol|ciphers'

# Kernel module and sysctl baseline (compare against target hardening script's expected state)
sysctl -a 2>/dev/null | grep -E 'net.ipv4.conf|net.ipv4.tcp_syncookies|kernel.randomize_va_space'

# Existing host firewall state (informational only — this workflow does not own firewall
# design intent, see Scope note below; confirming current state avoids the hardening script
# conflicting with rules the Network Architect / existing config already established)
ufw status verbose 2>/dev/null || firewall-cmd --list-all 2>/dev/null

# AIDE / integrity monitoring presence
which aide 2>/dev/null && aide --version 2>/dev/null

# Chrony/NTP sync status
chronyc tracking 2>/dev/null || timedatectl 2>/dev/null
```

Baseline established = current state recorded before any change, so the post-hardening diff is meaningful and any unexpected side effect can be traced to a specific control rather than "something changed."

## Risk Analysis (all scenarios)

- **Blast radius:** typically single-host, but a hardening control applied via a fleet-wide Ansible role run without adequate testing can affect many hosts simultaneously if a bad control ships broadly — this is why the Implementation section below mandates a canary/pilot-host approach before fleet-wide rollout.
- **Failure modes:** SSH lockout (if transport hardening is misapplied without an active session held open as a safety net), broken application dependency (a blacklisted kernel module or disabled service that a legitimate application actually needs), broken authentication (if a control inadvertently touches PAM/auth configuration — explicitly out of scope for this workflow's hardening script, but a real risk if scope discipline isn't maintained), broken monitoring (NRPE/Wazuh agent health affected by AppArmor/SELinux enforcement of a profile that wasn't tuned for the monitoring agent).
- **MUST:** keep an active, separate SSH/console session open and unaffected by the change until SSH hardening is validated — never apply SSH transport hardening in a way that could lock out the only active session. Never let the hardening script touch PAM/auth configuration (AD/LDAP-owned) or firewall design intent (network-layer-owned) — this is a deliberate, documented scope boundary this platform recommends across engagements, not an oversight to "fix" by expanding the script's scope.
- **SHOULD:** apply to one canary host per role/OS-version combination before fleet-wide rollout; re-run the hardening script (idempotently) on a schedule to catch configuration drift rather than treating hardening as a one-time event.

## Dependencies

- Security Architect: baseline level (1 vs. 2) selection per host classification, and arbitration for any control that conflicts with a documented operational dependency.
- Windows Infrastructure Engineer: for the SSSD/LDAP boundary — this workflow's hardening script does not touch PAM/auth, but validating that authentication still works post-hardening requires confirming the AD-side configuration is unaffected, which may need cross-agent confirmation if anything looks off.
- Network Architect: for the host firewall boundary — this workflow configures the mechanism (UFW/firewalld rule syntax) but the *design intent* (which ports/sources should be allowed) should trace back to Network Architect's documented allow-list pattern, not be invented ad hoc during hardening.
- Backup & DR Architect: confirm backup agent compatibility with AppArmor/SELinux enforcement before enabling enforcing mode broadly — monitoring agents (e.g. NRPE-based) are a known category of software that can show elevated memory consumption under resource pressure, worth checking for regardless of which specific monitoring stack the client runs.

---

## Scenario A: Baseline Hardening (New Build or First Application to Existing Host)

### Implementation
1. Confirm target CIS level and OS version against the documented baseline strategy.
2. Apply the idempotent hardening script/role covering: AIDE, AppArmor/SELinux, sysctl hardening, SSH transport hardening, chrony/NTP, kernel module blacklisting.
3. **Explicitly exclude from the script's scope:** PAM/auth configuration (routes to `agents/windows-infrastructure-engineer/AGENT.md` for the AD/LDAP side, `agents/linux-platform-engineer/AGENT.md`'s own SSSD client-side responsibility for the Linux side — but not this hardening script) and host firewall rule *design* (the script may apply UFW/firewalld syntax, but the allow-list content should trace to Network Architect's documented design, not be invented here).
4. Apply first to a canary host matching the role/OS-version combination; do not proceed to fleet-wide rollout until the canary is validated (see below).
5. Roll out fleet-wide via Ansible (per `standards/ansible.md`) once canary validation passes, respecting maintenance windows and applying in batches rather than all hosts simultaneously.

### Validation
- SSH access confirmed functional from a fresh session (not just the session held open during the change) before closing out the change.
- Application/service functionality spot-checked on the canary host — nothing legitimate broken by kernel module blacklisting or AppArmor/SELinux enforcement.
- NRPE/Wazuh monitoring agent confirmed still reporting correctly post-hardening.
- `aa-status`/`sestatus`, `sysctl` values, and SSH config confirmed matching the target hardening script's expected state.
- Re-running the hardening script produces no further changes (idempotency confirmed).

### Rollback
- Because the hardening script is idempotent, "rollback" for most individual controls is re-applying the pre-hardening configuration value, which should be recorded during Assessment specifically to make this possible. For a canary host failing validation broadly, restoring from the pre-change backup/snapshot is the clean rollback path — this is why the canary-first approach exists, to contain the blast radius of anything requiring a full restore.

---

## Scenario B: Handling a Control Conflict / Documented Exception

Used when a specific CIS control conflicts with a genuine operational dependency (e.g. a legacy application requiring a kernel module the benchmark would otherwise blacklist).

### Implementation
1. Do not silently skip the control in the script and move on — document the conflict explicitly.
2. Route to Security Architect for risk-acceptance per `agents/security-architect/AGENT.md`'s decision framework: is there a lower-cost mitigation than outright exception (a scoped exception, a compensating control, monitoring in lieu of full remediation)?
3. Record the approved exception in a compensating-control register entry (owned by Security Architect) with a remediation deadline if the underlying dependency is expected to be resolved eventually (e.g. legacy application replacement already planned).
4. Update the hardening script/role to explicitly skip only that specific control for the specific host/role it applies to — via a documented, named exception flag, not a broad scope reduction that could silently also skip the control on hosts where it isn't actually needed.

### Validation
- The exception is documented in the compensating-control register, not just as a code comment.
- The hardening script's exception handling is scoped precisely to the affected host/role — confirm by checking that other hosts of the same role without the dependency still receive the full control.

### Rollback
- Reverting an exception (i.e. re-enabling the control) once its underlying dependency is resolved follows the same path as Scenario A implementation for that specific control, applied to the specific host(s) that had the exception.

---

## Scenario C: Periodic Re-Audit (Configuration Drift Detection)

### Implementation
1. Re-run the idempotent hardening script/role in check/dry-run mode (per `standards/ansible.md`'s check-mode requirement, or `standards/bash.md`'s `--dry-run` flag) on a scheduled cadence (recommend quarterly, or aligned with the broader vulnerability management SLA cadence Security Architect defines).
2. Any reported "would change" output indicates drift — a control that was applied but has since been reverted (manually, by a package update, or by an unrelated change).
3. Investigate the drift's cause before simply re-applying — silent drift on a security control can itself be a finding worth an RCA if the cause is concerning (e.g. an undocumented manual change bypassing change control).

### Validation
- Re-audit report shows the expected zero-drift state after remediation, or documents the specific drift found and its resolution.

### Rollback
- Not applicable — this scenario is itself a detection/remediation activity, not a state-changing one until drift is found and corrected (at which point Scenario A's validation/rollback pattern applies to the specific correction made).

---

## Acceptance Criteria (all scenarios)

- [ ] SSH access confirmed functional from a fresh session post-hardening.
- [ ] Hardening script re-run confirms idempotency (no further changes on a second run).
- [ ] No PAM/auth or firewall design-intent changes made by the hardening script itself — scope boundary respected.
- [ ] Any control conflict documented as an explicit, scoped exception in the compensating-control register, not silently skipped.
- [ ] NRPE/Wazuh monitoring agent confirmed functional post-hardening.
- [ ] Change record closed in the client's ITSM/CMDB platform with before/after evidence (Assessment output vs. post-hardening state).

## Lessons Learned

To be populated after first production execution of each scenario (Baseline / Exception Handling / Periodic Re-Audit) — track separately, since their failure patterns differ.
