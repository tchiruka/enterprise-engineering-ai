# Workflow: Database Engine Lifecycle Management

**Owning agent(s):** Database Engineer (primary); Chief Infrastructure Engineer (multi-instance programme sequencing); Security Architect (PCI-DSS scope, auth findings); Backup & DR Architect (recoverability assurance for database-native backups); Windows Infrastructure Engineer (AD/LDAP server-side auth, and Windows Server OS underneath any MSSQL instance)
**Applies to:** PostgreSQL, MySQL (and MySQL-compatible engines, e.g. MariaDB), and Microsoft SQL Server (MSSQL) — this workflow covers all three engines commonly encountered across engagements, with engine-specific implementation detail nested inside each scenario rather than duplicated across three separate workflow documents
**Compliance frameworks referenced:** PCI-DSS v4.0 (Req. 3 — protection of stored data; Req. 8 — authentication), ISO/IEC 27001:2022 (A.8.24 use of cryptography, A.8.2 privileged access), ITIL v4 (change enablement)

## Executive Summary

Databases hold the estate's most sensitive and hardest-to-regenerate data, and the wrong DB engine's own multi-engine estate means guidance and diagnostic commands don't transfer between them — a PostgreSQL runbook followed against a SQL Server instance is a guaranteed mistake. This workflow covers the full engine lifecycle across all three engines: baseline health/recoverability assessment (shared across engines), version upgrade (engine-specific implementation, shared risk framework), authentication integration (engine-specific mechanism, shared unique-service-account-per-server policy), and backup/recoverability verification (engine-specific commands, shared recoverability-vs-success discipline owned by `agents/backup-dr-architect/AGENT.md`).

## Prerequisites (all scenarios, all engines)

- Administrative access appropriate to the specific engine (PostgreSQL superuser/role with `CREATEDB`/replication privileges as needed; MySQL account with appropriate `GRANT`s; MSSQL `sysadmin` or scoped equivalent).
- **State the engine explicitly before starting** — this workflow's Implementation steps are nested by engine specifically so this can't be skipped by accident.
- Current, verified backup using the engine's native mechanism (see Scenario C), confirmed restorable — not just "job completed."
- Change record raised in the client's ITSM/CMDB platform (e.g. iTop, ServiceNow, or equivalent), validated against the client's own change-control validation criteria before CAB submission.
- For any auth-related change: confirmation with `agents/windows-infrastructure-engineer/AGENT.md` that the AD/LDAP server side is healthy and ready, since a database-side auth change against an unhealthy AD/LDAP backend will fail in ways that look database-side at first.

## Assessment (all scenarios, all engines — run before selecting a scenario)

Identify the engine, then run the matching baseline health check:

**PostgreSQL:**
```sql
SELECT version();
SELECT * FROM pg_stat_activity WHERE state != 'idle';
SELECT * FROM pg_replication_slots;
SHOW data_checksums;
```

**MySQL:**
```sql
SELECT VERSION();
SHOW ENGINE INNODB STATUS\G
SHOW SLAVE STATUS\G  -- or SHOW REPLICA STATUS on newer versions
SHOW VARIABLES LIKE 'have_ssl';
```

**MSSQL:**
```sql
SELECT @@VERSION;
SELECT * FROM sys.dm_exec_requests WHERE session_id > 50;
SELECT * FROM sys.dm_os_wait_stats ORDER BY wait_time_ms DESC;
SELECT * FROM sys.availability_groups; -- if Always On is in use
```

Baseline "healthy" = engine responsive with no long-blocking sessions, replication/AG status current with no unexpected lag, no unexpected error log entries in the period preceding this assessment. Resolve any of these before proceeding with a version upgrade or major configuration change — layering a risky change on an already-unhealthy instance compounds risk unnecessarily.

## Risk Analysis (all scenarios, all engines)

- **Blast radius:** single-instance vs. replicated/clustered (PostgreSQL streaming replication, MySQL Group Replication, MSSQL Always On Availability Groups) vs. an instance serving multiple dependent applications. State explicitly which applies.
- **Failure modes common across engines:** authentication breakage post-change (most common and most avoidable — verify auth continues working immediately after any engine upgrade or auth reconfiguration, don't assume it silently carries over), replication/AG desync, unexpected application incompatibility with a new engine version's behavior changes (not just breaking API changes — subtle query planner or default-behavior changes are a frequent source of "upgrade succeeded, application now behaves differently" incidents).
- **MUST:** never perform a major-version upgrade without a verified, tested-restorable backup immediately beforehand, regardless of engine. Never assume auth configuration migrates cleanly across a major version upgrade — verify explicitly post-upgrade for all three engines.
- **SHOULD:** test major-version upgrades in a non-production environment first wherever one exists; where it doesn't (a real constraint, especially for MSSQL given licensing costs of standing up parallel instances — see `agents/database-engineer/AGENT.md` escalation rules), apply extra weight to the pre-change backup/rollback rigor to compensate.

## Dependencies

- `agents/backup-dr-architect/AGENT.md`: confirm backup schedules and broader recoverability policy are accounted for around any maintenance window.
- `agents/windows-infrastructure-engineer/AGENT.md`: AD/LDAP health (all engines' LDAP/Windows Auth integration depends on it) and, for MSSQL specifically, the underlying Windows Server OS.
- `agents/security-architect/AGENT.md`: PCI-DSS Req. 3/8 scope confirmation for any database processing cardholder-adjacent data.

---

## Scenario A: Version Upgrade

### Implementation — PostgreSQL
```bash
# Confirm target version compatibility with any extensions in use first
pg_dumpall > pre_upgrade_backup_$(date +%F).sql   # logical backup as a supplementary safety net
# Use pg_upgrade for in-place major version upgrade, or a dump/restore for a clean cutover
pg_upgrade --old-datadir=/path/to/old --new-datadir=/path/to/new --old-bindir=... --new-bindir=...
```
Verify extensions used by dependent applications are available and compatible for the target version before starting — an unsupported extension is a common blocker discovered too late otherwise.

### Implementation — MySQL
```bash
mysqldump --all-databases --routines --triggers --events > pre_upgrade_backup_$(date +%F).sql
# In-place upgrade via package manager (apt/dnf) is standard for minor versions;
# major version upgrades should follow the specific documented upgrade path for the version pair —
# do not assume all major version jumps support direct in-place upgrade.
```
Run `mysql_upgrade` (or the equivalent post-upgrade check for the target version, since this step has been folded into server startup in some newer versions — confirm current behavior for the specific version) after the binary upgrade to reconcile system tables.

### Implementation — MSSQL
```sql
-- Native full backup immediately before, in addition to any VM-level snapshot
BACKUP DATABASE [DatabaseName] TO DISK = 'path\to\backup.bak' WITH CHECKSUM, COMPRESSION;
```
Run SQL Server Setup for the target version's in-place upgrade, or stand up a new instance and migrate via backup/restore or detach/attach for a clean-cutover approach (preferred where licensing allows, mirroring the swing-migration preference used elsewhere in this platform for its lower-risk rollback profile).

### Validation (all engines)
- Engine reports expected target version.
- Application connectivity and a representative query/transaction succeed post-upgrade.
- Auth (LDAP/Windows Auth) confirmed working, not assumed.
- Replication/AG status (if applicable) confirmed healthy post-upgrade.

### Rollback
- **PostgreSQL/MySQL (in-place upgrade path):** generally not cleanly reversible in place — the pre-upgrade backup is the rollback mechanism (restore to a fresh instance at the prior version).
- **MSSQL / any engine using a clean-cutover (new instance) approach:** rollback is simply not cutting over — keep the prior instance running until the new one is validated, mirroring the swing-migration pattern's inherent lower risk.

---

## Scenario B: Authentication Integration (LDAP/AD)

### Implementation — PostgreSQL
```conf
# pg_hba.conf — unique service account per server, not shared
host    all    all    <subnet>    ldap ldapserver=<dc-fqdn> ldapbasedn="..." ldapbinddn="svc-pgsql-<hostname>" ldapbindpasswd="..."
```

### Implementation — MySQL
Configure the appropriate authentication plugin (PAM-based LDAP integration, or a native LDAP plugin depending on edition/version in use) with a unique per-server bind account, following the same naming convention pattern (`svc-mysql-<hostname>`) as the estate's established convention.

### Implementation — MSSQL
Windows Authentication mode (or Mixed Mode with Windows Auth as the primary path) mapped to AD security groups rather than individual accounts where feasible, with the SQL Server service account itself following the unique-service-account-per-server pattern — coordinate directly with `agents/windows-infrastructure-engineer/AGENT.md` for the AD-side account/group creation.

### Validation (all engines)
- A test connection using the configured auth mechanism succeeds.
- Confirm the service/bind account is unique to this server (not shared across instances) — this is a security finding if found to be shared, per `agents/database-engineer/AGENT.md`'s escalation rules.

### Rollback
- Revert the configuration file/setting change and restart the engine's auth-related service. Low risk, quick rollback across all three engines, since this scenario doesn't touch data.

---

## Scenario C: Backup & Recoverability Verification

### Implementation — PostgreSQL
```bash
pg_basebackup -D /path/to/backup -Fp -Xs -P
# WAL archiving for PITR should already be configured continuously, not just at backup time
```

### Implementation — MySQL
```bash
mysqldump --single-transaction --routines --triggers --events --all-databases > backup_$(date +%F).sql
# Or, for larger estates: Percona XtraBackup for physical, near-zero-downtime backup
```

### Implementation — MSSQL
```sql
BACKUP DATABASE [DatabaseName] TO DISK = 'path\to\full.bak' WITH CHECKSUM, COMPRESSION;
BACKUP LOG [DatabaseName] TO DISK = 'path\to\log.trn' WITH CHECKSUM;
```

### Validation (all engines — this is the step that actually matters)
**Restore the backup to a separate, isolated instance and confirm the database is usable** — query a representative table, confirm row counts are sane, confirm the application (or a stand-in test) can connect and function. A backup job reporting success is not evidence of recoverability, per the distinction owned by `agents/backup-dr-architect/AGENT.md` and defined in `docs/glossary.md` — this validation step is what actually closes that gap rather than just asserting it's closed.

### Rollback
- Not applicable — this scenario is itself a verification exercise, not a production change. If the restore test fails, that's the finding: escalate per `agents/database-engineer/AGENT.md`'s escalation rules ("A backup/restore procedure has never been tested for a database considered critical") rather than treating a failed test as something to quietly retry until it passes.

---

## Acceptance Criteria (all scenarios, all engines)

- [ ] Engine identified explicitly throughout the change record — no ambiguity about which of the three engines was involved.
- [ ] Baseline health confirmed before the change (per the Assessment section).
- [ ] Auth confirmed working post-change via an actual test connection, not assumed.
- [ ] For upgrades: target version confirmed via engine query, not just installer/package output.
- [ ] For backup verification: restore actually performed and validated against a separate instance, not just backup-job-success relied upon.
- [ ] Change record closed in the client's ITSM/CMDB platform with before/after evidence attached.

## Lessons Learned

To be populated after first production execution of each scenario, tracked separately per engine where the failure pattern is genuinely engine-specific (e.g. a PostgreSQL extension incompatibility vs. an MSSQL licensing constraint) rather than merged into one undifferentiated notes section.
