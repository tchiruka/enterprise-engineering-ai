# Standard: PowerShell

Applies to all PowerShell scripts produced by any agent in this platform, for use in production Windows/AD/VMware (PowerCLI) environments.

## Mandatory requirements

1. **`[CmdletBinding()]` on every script/function** intended for interactive or reusable use. This enables common parameters (`-Verbose`, `-Debug`, `-ErrorAction`) consistently.
2. **`-WhatIf` and `-Confirm` support on every state-changing script.** Any script that creates, modifies, or deletes a resource must implement `SupportsShouldProcess` and honor `-WhatIf`. This is non-negotiable for anything touching production AD, VMware, or file-system state — it is the difference between a script that can be safely dry-run before execution and one that can't.
   ```powershell
   [CmdletBinding(SupportsShouldProcess = $true)]
   param(...)
   ...
   if ($PSCmdlet.ShouldProcess($target, "Description of the action")) {
       # state-changing code here
   }
   ```
3. **Explicit error handling.** Use `try/catch` around operations that can fail (network calls, AD cmdlets, file I/O), and set `-ErrorAction Stop` on cmdlets inside a `try` block so errors are actually caught rather than silently continuing. Never use empty `catch {}` blocks — at minimum log what was caught.
4. **No hardcoded credentials, connection strings, or secrets.** Use `Get-Credential`, a credential manager, or a secrets store reference. This applies even to scripts intended for one-time use — one-time scripts get reused.
5. **Parameter validation.** Use `[ValidateSet()]`, `[ValidateNotNullOrEmpty()]`, `[ValidateScript()]` etc. rather than validating manually inside the function body where avoidable — it fails fast and documents constraints in the signature itself.
6. **Comment-based help** (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) on every script/function intended for reuse by someone other than the original author.
7. **Logging for state-changing scripts.** At minimum, log what action was taken, against what target, by whom, and when, to a location that survives the script's own execution (transcript, log file, or structured log — not just console output).

## Naming conventions

- Verb-Noun format matching approved PowerShell verbs (`Get-`, `Set-`, `New-`, `Remove-`, `Test-`, etc. — check `Get-Verb` rather than inventing non-standard verbs).
- Variables: `$PascalCase` for script-scope/parameters, `$camelCase` acceptable for local loop variables.
- Script files: `Verb-Noun.ps1` matching the primary function, or a descriptive name for orchestration scripts (`Invoke-ADHealthCheck.ps1`).

## Structure for scripts intended as platform deliverables

```powershell
<#
.SYNOPSIS
Short description.

.DESCRIPTION
Full description including what it does NOT do, and any prerequisites.

.PARAMETER <Name>
Description of each parameter.

.EXAMPLE
Realistic usage example, including -WhatIf usage if state-changing.

.NOTES
Author, date, related workflow/agent document.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetSystem
)

begin {
    # setup, logging init, connection establishment
}

process {
    try {
        if ($PSCmdlet.ShouldProcess($TargetSystem, "Description of action")) {
            # main logic
        }
    }
    catch {
        Write-Error "Failed to <action> against $TargetSystem`: $_"
        throw
    }
}

end {
    # cleanup, summary output
}
```

## PowerCLI-specific additions (VMware Architect agent scripts)

- Always `Connect-VIServer` explicitly with error handling around connection failure — do not assume an existing session.
- Always `Disconnect-VIServer -Confirm:$false` in a `finally` block to avoid orphaned sessions.
- Use `-ErrorAction Stop` on VMware cmdlets inside `try` blocks for the same reason as standard PowerShell — VMware cmdlets frequently continue silently on error by default.

## What this standard does not cover

- AD-specific cmdlet usage patterns (ActiveDirectory module) beyond the general PowerShell rules above — those live in the relevant workflow documents where the specific operation is described.
- Ansible-based automation — see `standards/ansible.md` (to be created) for the growing Ansible automation estate.
