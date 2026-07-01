# Standard: Logging

Applies to all scripts, automation, and services this platform's agents design or configure, across PowerShell, Bash, and Ansible-driven changes — the cross-cutting complement to the language-specific logging requirements already stated in `standards/powershell.md` and `standards/bash.md`.

## Why this exists as its own standard

Individual language standards each say "log state-changing actions" but don't define a consistent *shape* for that logging. Without a shared format, log output from a PowerShell AD script, a Bash hardening script, and an Ansible playbook run all look different, which makes correlation during an incident (e.g. tracing a change across Windows and Linux hosts during the same maintenance window) needlessly hard. This standard defines the shared shape; language standards define the mechanics of writing it.

## Minimum required fields for any state-changing action log entry

Every log entry recording a state-changing action (not routine informational output) should include:

- **Timestamp** — ISO 8601 format (`2026-07-01T14:32:07Z`), UTC preferred to avoid timezone ambiguity across a multi-site estate.
- **Actor** — who/what initiated the action (username, service account, or script/automation identity).
- **Target** — the specific system/object acted upon (hostname, AD object DN, VM name, etc.) — not a vague category.
- **Action** — what was done, in plain language, specific enough to be meaningful without needing to open the script that generated it.
- **Outcome** — success, failure, or partial, with enough detail to distinguish "succeeded" from "reported success but didn't actually verify."
- **Related change/incident reference** where applicable (CR number, RCA ID) — ties the log entry back to the governance record that authorized or explains it.

## Example (language-agnostic shape)

```json
{
  "timestamp": "2026-07-01T14:32:07Z",
  "actor": "svc-ad-automation",
  "target": "PRD-DC05.corp.example.com",
  "action": "AD DC promotion (Install-ADDSDomainController)",
  "outcome": "success",
  "change_reference": "CR-2026-0417"
}
```
Plain-text log formats are acceptable where structured logging infrastructure isn't in place, but should still include all the fields above in a consistent, parseable order — e.g. `[2026-07-01T14:32:07Z] actor=svc-ad-automation target=PRD-DC05.corp.example.com action="AD DC promotion" outcome=success change_ref=CR-2026-0417`.

## Log retention and location

- **Location:** state-changing action logs should be written somewhere that survives the originating script/session — a dedicated log directory (e.g. `/var/log/platform-automation/` on Linux, a defined path under `C:\ProgramData\PlatformAutomation\Logs\` on Windows), not solely console/transcript output that disappears when the terminal closes.
- **Retention:** align with the applicable compliance requirement — PCI-DSS v4.0 Req. 10.5.1 specifies a minimum 12 months retention with at least the most recent 3 months immediately available for analysis; treat this as the floor for any log that could plausibly be relevant to a PCI-scoped system, and confirm the actual requirement with `agents/security-architect/AGENT.md` for systems where scope is ambiguous.
- **Protection:** logs recording privileged actions should not be writable/deletable by the same account that performed the logged action, where feasible — otherwise the log's evidentiary value in an incident is undermined.

## What counts as "state-changing" for this standard's purposes

If in doubt, log it. Concretely, always log:
- Any create/modify/delete operation against AD, VMware, OpenStack, or file-system state.
- Any privilege escalation or credential use in automation.
- Any configuration change to a security control (firewall rule, hardening setting).
- Any patch/update application.

Do **not** need this level of structured logging for purely read-only diagnostic queries (e.g. a `dcdiag` health check run for assessment purposes) — informational output is fine as plain console/log output without the full field set above, though it's still good practice to timestamp it.

## Relationship to SIEM/monitoring

This standard defines what a script or automation *writes*; it does not itself define SIEM ingestion, alerting rules, or detection coverage — that's `agents/security-architect/AGENT.md`'s domain (SIEM strategy) and the relevant platform agent's domain (agent-level log shipping configuration, e.g. Wazuh agent enrollment). Logs written per this standard should be structured consistently enough that ingestion into the SIEM doesn't require bespoke per-script parsing logic.

## What this standard does not cover

- Application-level logging for custom software (as distinct from infrastructure automation) — not yet in scope for this platform.
- SIEM rule/decoder authoring itself — see `agents/security-architect/AGENT.md` and the Wazuh documentation reference in `knowledge/index.md`.
