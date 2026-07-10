# Reference: Framework Alignment Guide

> Not a fillable document template like the other files in this directory — this is the reference `agents/documentation-standards-architect/AGENT.md` reads every time it needs to populate a Standards Alignment section in `templates/sop.md`, `templates/build-document.md`, `templates/runbook.md`, or `templates/work-instruction.md`. It gives the *shape* of each framework and which document types it applies to. It does not replace verifying the exact current name/number/version of a specific citation via search before it goes into a client-facing or audit-facing document — these frameworks revise periodically, and a stale citation is worse than none.

## ITIL v4

Use for: SOPs, Runbooks, and the process-flow parts of Build Documents.

ITIL v4 is organized around **Practices** (not the older v3 "processes"), grouped into General Management, Service Management, and Technical Management practices. The ones that come up most for infrastructure SOPs/Runbooks:

- Incident Management
- Problem Management
- Change Enablement
- Service Configuration Management
- Release Management
- Deployment Management
- Monitoring and Event Management
- Service Continuity Management

**Before citing:** confirm the practice name and current guiding-principle language via search — ITIL 4 practice names and the seven Guiding Principles are stable but easy to misquote from memory. Cite the practice name only, not a specific certification syllabus module number.

## NIST

Use for: Build Documents, hardening/security Work Instructions, anything with a technical control basis.

Relevant NIST publications:
- **SP 800-53** (Security and Privacy Controls) — control families (AC, AU, CM, IA, SC, SI, etc.) and specific control IDs (e.g. CM-6 Configuration Settings, AC-2 Account Management).
- **SP 800-40** — patch and vulnerability management guidance.
- **CSF 2.0** (Cybersecurity Framework) — functions: Govern, Identify, Protect, Detect, Respond, Recover (CSF 2.0 added "Govern" to the original five).
- **SP 800-123** — server security guide, useful for build-hardening documents.

**Before citing:** confirm the exact control ID and current revision (e.g. "SP 800-53 Rev. 5") via search — control numbering has changed across revisions, and citing a withdrawn or renumbered control undermines the document. Never state a control ID from memory alone when the document will be used externally or for an audit.

## COBIT 2019

Use for: the governance framing line in a document's front matter or Standards Alignment section — rarely the bulk of the document.

COBIT 2019 is organized into governance/management objectives across domains:
- EDM (Evaluate, Direct, Monitor) — governance
- APO (Align, Plan, Organize)
- BAI (Build, Acquire, Implement) — e.g. BAI06 Managed IT Changes, BAI10 Managed Configuration
- DSS (Deliver, Service, Support) — e.g. DSS01 Managed Operations, DSS02 Managed Service Requests and Incidents
- MEA (Monitor, Evaluate, Assess)

**Before citing:** confirm the objective code and current title via search. One line, such as "Supports COBIT 2019 DSS01 (Managed Operations)," is normally sufficient — don't pad this into a governance essay.

## CISA / CISM / CISSP

These are **certifications with bodies of knowledge**, not numbered-control standards like NIST/COBIT. Use them only for terminology and structural framing, never as a citable control:

- **CISSP** (ISC2) — 8 domains (Security and Risk Management, Asset Security, Security Architecture and Engineering, Communication and Network Security, Identity and Access Management, Security Assessment and Testing, Security Operations, Software Development Security). Useful for making sure risk/access-control language in a document is professionally framed.
- **CISM** (ISACA) — 4 domains centred on information security governance, risk management, program development/management, and incident management. Useful for governance/risk framing in SOPs.
- **CISA** (ISACA) — domains centred on the IS audit process, governance, systems acquisition/development, operations/resilience, and asset protection. Useful for making sure a document would satisfy an IS auditor's expectations (evidence trail, control-testing language).

**Do not** write "per CISSP control X.X" or invent a numbered clause — these bodies of knowledge don't have citable control IDs. If this level of framing is wanted, phrase it as "structured to reflect CISSP Security Operations domain practices," not a fabricated citation.

## Which frameworks to include, per document type

| Document type | Primary | Secondary | Usually omit |
|---|---|---|---|
| SOP (`templates/sop.md`) | ITIL v4 | COBIT 2019 (1 line) | NIST control IDs, unless the SOP is security-specific (e.g. a patch management SOP) |
| Build Document (`templates/build-document.md`) | NIST (SP 800-53 / 800-123) | COBIT 2019 BAI | ITIL v4, unless deployment-practice framing adds value |
| Runbook (`templates/runbook.md`) | ITIL v4 (Incident Management) | — | COBIT 2019, NIST — unless the incident is security-specific |
| Work Instruction (`templates/work-instruction.md`) | — | — | Usually no framework citation needed; it's too granular. Add only if it's a security-control step. |

Never force all four frameworks onto one document. A short, correctly cited alignment beats a padded one — see `agents/documentation-standards-architect/AGENT.md` Decision Framework and Quality Checklist, which enforce the same 2-5 line discipline this table implies.
