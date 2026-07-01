# Standard: Git

Applies to all agents committing content to this repository, and to any Git-based version control this platform recommends for the estates it documents (e.g. Ansible role repositories, script repositories).

## Commit messages

- **Format:** short imperative summary line (≤ 72 characters), blank line, then body if needed explaining *why* the change was made, not just *what* changed (the diff already shows what).
- **No vague messages.** "Fix stuff," "updates," "wip" are not acceptable for anything landing on a shared branch. Every commit message should let someone six months from now understand the change's purpose without opening the diff.
- **Reference the change/incident record where applicable** (e.g. "Correct SSSD ldap_connection_expire_timeout per CR-2026-0342" or "RCA-2026-0091: document firewall root cause for LDAP drops").
- This platform's own milestone commits follow the pattern `Milestone N: <summary of what was added/changed>` — a reasonable convention to reuse for any similarly staged internal project.

## Branching

- **`main`** (or `master` on older repos) should always be in a deployable/usable state — for documentation-and-automation repositories like this one, that means "any file on `main` could be handed to an engineer or CAB right now without embarrassment."
- Feature/change work happens on a branch named descriptively (`feature/<short-description>`, `fix/<short-description>`), merged via pull/merge request rather than direct push, once collaborators are involved. For single-maintainer repositories (as this one currently is), direct commits to `main` are acceptable, but the same commit-message discipline still applies.
- Delete branches after merge to keep the branch list meaningful.

## What belongs in version control

- **Yes:** scripts, playbooks, documentation, templates, configuration-as-code (Ansible, Terraform), non-secret configuration files.
- **No, never:** credentials, API keys, private keys, connection strings with embedded passwords, `.env` files containing secrets, PII/sensitive data samples. Use `.gitignore` proactively for anything matching these patterns, and use a pre-commit hook or secret-scanning tool where the risk of accidental commit is non-trivial.
- If a secret is accidentally committed, treat it as compromised immediately (rotate it) — do not rely on simply removing it from a later commit, since it remains in history unless the history itself is rewritten and force-pushed, which has its own risks for a shared repository.

## `.gitignore` baseline for this platform

```gitignore
# OS/editor artifacts
.DS_Store
Thumbs.db
*.swp

# Secrets and local config
.env
*.pem
*.key
vault_pass.txt

# Ansible
*.retry

# Logs
*.log
```

## Tags and releases

For any deliverable expected to be referenced by version (e.g. a client's OpenStack backup role/automation), use annotated Git tags (`git tag -a v1.2.0 -m "..."`) rather than relying on commit messages or filenames alone to convey versioning.

## Repository hygiene

- Keep generated/binary artifacts (compiled output, exported reports) out of version control unless the artifact itself is the deliverable being tracked (e.g. a rendered PDF policy document that should be versioned alongside its source).
- Large binary files, if genuinely needed in-repo, should use Git LFS rather than being committed directly, to avoid repository bloat.

## What this standard does not cover

- CI/CD pipeline design — not yet in scope for this platform; if introduced, would warrant its own standard document.
