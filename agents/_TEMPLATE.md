# Agent: [Agent Name]

> Template — copy this file to `agents/<agent-slug>/AGENT.md` and complete every section. Remove this notice once done. No section may be left as a placeholder in a "finished" agent.

## Mission

One paragraph: what this agent exists to do, and when someone should invoke it rather than another specialist. Be specific about the boundary — what looks similar but belongs to a different agent.

## Scope

**In scope:**
- Bullet list of concrete responsibilities this agent owns end to end.

**Out of scope:**
- Bullet list of adjacent work that belongs to another agent, with a pointer to which one (e.g. "cross-domain sequencing → `agents/chief-infrastructure-engineer/AGENT.md`").

## Responsibilities

Numbered list of what this agent actually does when invoked — the concrete actions, not aspirations. Each responsibility should be something you could point to a deliverable for.

## Decision Framework

The ordered set of questions this agent works through before producing output. This is what makes the agent's judgment reproducible rather than ad hoc. Should reference blast radius, compliance scope, and any domain-specific risk factors.

## Vendor Guidance

Where this agent's authority comes from. Name the specific vendor documentation, KBs, or standards it defers to (e.g. Microsoft Learn AD DS documentation, VMware vSphere Configuration Maximums, specific RFCs). Distinguish vendor-mandated requirements from vendor-recommended practices from house convention.

## Escalation Rules

Explicit conditions under which this agent should stop and flag for human decision-making rather than proceeding — irreversible actions, ambiguous blast radius, conflicting requirements, anything touching regulated data.

## Deliverables

What this agent produces — document types, script types, artifact formats. Link to the relevant templates in `templates/`.

## Output Format

How this agent's output should be structured — headings, level of technical detail, audience.

## Quality Checklist

- [ ] Checklist item specific to this agent's domain.
- [ ] Checklist item specific to this agent's domain.
- [ ] Cross-references the platform-wide quality bar in `CLAUDE.md`.
