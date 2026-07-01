# Standard: Bash

Applies to all Bash scripts produced by any agent in this platform, for use in production Linux environments (primarily `agents/linux-platform-engineer/AGENT.md`, but any agent producing Linux-side automation).

## Mandatory requirements

1. **Strict mode at the top of every script:**
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   IFS=$'\n\t'
   ```
   `-e` exits on any unhandled error, `-u` treats unset variables as errors, `-o pipefail` ensures a failure anywhere in a pipeline fails the whole pipeline (without this, `false | true` exits 0, silently hiding the failure). This is non-negotiable for any script touching production state — the default Bash behavior of continuing past errors is the single most common source of scripts that "worked" but silently skipped a critical step.

2. **Idempotency for any script that changes state.** Running the script twice should not cause errors or duplicate effects — check current state before acting (e.g. check if a file/user/service already exists in the desired state before creating/modifying it), matching the pattern already established in this estate's CIS hardening scripts.

3. **Dry-run support for state-changing scripts.** Provide a `--dry-run` or `-n` flag that prints what would be done without doing it, mirroring the intent of PowerShell's `-WhatIf` (see `standards/powershell.md`) for the same reason: a state-changing script must be safely previewable before committing to run it against production.
   ```bash
   DRY_RUN=false
   while getopts "n" opt; do
       case $opt in
           n) DRY_RUN=true ;;
       esac
   done

   run() {
       if [ "$DRY_RUN" = true ]; then
           echo "[DRY RUN] Would run: $*"
       else
           "$@"
       fi
   }
   ```

4. **Explicit error handling around operations that can fail non-fatally under `set -e`.** Some commands (e.g. `grep` returning non-zero when no match is found, used deliberately for a conditional) need explicit handling so they don't trigger an unwanted exit:
   ```bash
   if grep -q "pattern" file.conf; then
       echo "found"
   fi
   ```

5. **No hardcoded credentials or secrets.** Reference environment variables sourced from a secrets store, or prompt interactively — never embed a password, API key, or connection string as a literal in the script.

6. **Quote all variable expansions** (`"$var"`, not `$var`) to prevent word-splitting and globbing bugs — a frequent, hard-to-diagnose source of scripts that break on inputs containing spaces or special characters.

7. **`shellcheck`-clean.** Every script intended as a platform deliverable should pass `shellcheck` with no unaddressed warnings (or an explicit, commented justification for any suppressed warning).

## Structure for scripts intended as platform deliverables

```bash
#!/usr/bin/env bash
#
# Script: harden-ssh-transport.sh
# Purpose: Applies CIS-aligned SSH transport hardening. Idempotent — safe to re-run.
# Scope exclusions: does not touch PAM/auth configuration (AD/LDAP-owned, see
#   agents/windows-infrastructure-engineer/AGENT.md) or host firewall rules
#   (see this script's companion, configure-host-firewall.sh).
# Usage: ./harden-ssh-transport.sh [-n for dry-run]
#
set -euo pipefail
IFS=$'\n\t'

DRY_RUN=false
while getopts "n" opt; do
    case $opt in
        n) DRY_RUN=true ;;
        *) echo "Usage: $0 [-n]" >&2; exit 1 ;;
    esac
done

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run() {
    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would run: $*"
    else
        "$@"
    fi
}

main() {
    log "Starting SSH transport hardening"
    # idempotent state-checking logic here before any state-changing 'run' call
    log "Complete"
}

main "$@"
```

## Naming conventions

- Script files: `verb-noun.sh` (e.g. `harden-ssh-transport.sh`, `check-replication-health.sh`), lowercase with hyphens.
- Functions: `snake_case`.
- Variables: `UPPER_CASE` for constants/environment-sourced values, `lower_case` for local script variables.

## Logging for state-changing scripts

At minimum, log what action was taken, against what target, and when, to a location that survives script execution — matching the requirement in `standards/powershell.md`. Prefer writing to a dedicated log file under a predictable path (e.g. `/var/log/platform-automation/<script-name>.log`) over relying solely on console output, which is lost once the terminal session ends.

## What this standard does not cover

- Ansible-based automation — see `standards/ansible.md`, which is the preferred approach for anything beyond a single-host, one-off script; Bash scripts in this platform are primarily for host-local operations (hardening, diagnostics) rather than fleet-wide orchestration.
