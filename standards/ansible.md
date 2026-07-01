# Standard: Ansible

Applies to all Ansible playbooks/roles produced by any agent in this platform, for fleet-wide orchestration across Windows, Linux, VMware, and OpenStack targets.

## Mandatory requirements

1. **Idempotency is the default expectation, not an aspiration.** Ansible modules are generally idempotent by design — use modules (`ansible.builtin.*`, platform-specific collections) rather than raw `shell`/`command` tasks wherever a proper module exists. Where `shell`/`command` is genuinely necessary, add `changed_when` and, ideally, a `creates`/`removes` guard so the task correctly reports "no change" on a re-run rather than always reporting changed.

2. **`--check` mode (dry-run) must work correctly.** Tasks using `shell`/`command` don't support check mode by default — explicitly set `check_mode: false` only where the command is genuinely safe to always-run even in check mode (rare), or better, avoid the need entirely by using proper modules. A playbook that can't be meaningfully dry-run before production execution is not acceptable as a platform deliverable, mirroring the `-WhatIf`/dry-run requirement in `standards/powershell.md` and `standards/bash.md`.

3. **No hardcoded credentials or secrets.** Use Ansible Vault for any secret material committed alongside a playbook, or reference an external secrets manager. Never commit an unencrypted credential, even for a "test" playbook — test playbooks get copied and reused.

4. **Role-based structure for anything beyond a trivial single-play task.** Follow standard Ansible role directory layout (`tasks/`, `handlers/`, `defaults/`, `vars/`, `templates/`, `meta/`) rather than one large flat playbook, once a task grows beyond a handful of steps or is intended for reuse across inventories.

5. **`defaults/main.yml` for anything the caller might reasonably want to override; `vars/main.yml` only for values that should not be overridden.** This distinction matters for anyone consuming the role later without reading its full source.

6. **Tag every task or task block meaningfully** (e.g. `tags: [hardening, ssh]`) so a role can be selectively run against a subset of its full scope — useful for targeted re-runs after a partial failure.

7. **Explicit `become`/privilege escalation scoping.** Apply `become: true` at the task level where privilege is actually needed, not blanket at the play level, so it's clear from reading the role exactly which operations require elevation.

8. **Inventory and group_vars should reflect the platform's actual host role taxonomy** (e.g. group hosts by function — domain controllers, ESXi hosts, OpenStack compute nodes — rather than by ad hoc naming) so role targeting stays legible as the estate grows.

## Structure for a platform-deliverable role

```text
roles/
  harden-linux-cis/
    defaults/main.yml       # overridable defaults (e.g. cis_level: 1)
    vars/main.yml           # non-overridable internal vars
    tasks/main.yml          # entry point, includes sub-task files by concern
    tasks/aide.yml
    tasks/sysctl.yml
    tasks/ssh_transport.yml
    handlers/main.yml       # e.g. restart sshd, only fires on actual change
    templates/              # Jinja2 templates for config files
    meta/main.yml           # role metadata, dependencies
    README.md               # scope, exclusions, usage — mirrors the header
                             # comment convention in standards/bash.md
```

## Example task demonstrating idempotency and check-mode compatibility

```yaml
- name: Ensure SSH root login is disabled
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin no'
    validate: '/usr/sbin/sshd -t -f %s'
  notify: restart sshd
  tags: [hardening, ssh]
```
This is idempotent (repeated runs report no change once applied), supports `--check` natively (it's a proper module, not `shell`), and validates config syntax before allowing the change to apply.

## Patch automation specifics

For Windows patch automation (via `win_updates`-family modules) and Linux patch automation (`apt`/`dnf`/`yum` modules), always:
- Separate the "check for available updates" step from the "apply updates" step, so a dry-run or reporting-only invocation is possible without committing to installing anything.
- Respect maintenance windows via scheduling at the inventory/playbook-invocation level (cron/AWX/Ansible Tower schedule, or explicit `when` conditions against a maintenance-window variable) rather than hardcoding "always patch now" into the role.
- Log patch actions per-host in a way that feeds into the platform's broader patch compliance reporting, not just Ansible's own run output.

## What this standard does not cover

- Single-host, one-off diagnostic scripts — see `standards/bash.md` for those; Ansible is the right tool for fleet-wide, repeatable orchestration, not for a quick one-time diagnostic on a single host.
- PowerShell-based automation on Windows targets invoked via Ansible's `win_shell`/`win_command` — the PowerShell content itself should still follow `standards/powershell.md` even when orchestrated by Ansible.
