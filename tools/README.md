# Tools

## Skill packaging

This platform can be used as a Claude Skill — a single `certification-consulting-platform` skill that routes to the correct agent persona and pulls in the relevant workflow/template/standard content via progressive disclosure, rather than requiring the user to paste an `AGENT.md` into chat manually each time.

### Why the skill's content is generated, not hand-maintained

`tools/skill-source/SKILL.md` is the only hand-authored file — the router logic, platform-wide operating rules, and the triage table. Everything under the skill's `references/` folder (every agent, workflow, template, standard, playbook, and the knowledge index/glossary/architecture doc) is **built from the live repository content**, not duplicated and hand-maintained separately. This matters for the same reason `docs/cross-reference-audit-milestone-13.md` and `tests/validate-repo.sh` exist: a duplicated copy of agent/workflow content would silently drift out of sync with the real files the moment either changed, and nothing would catch it. Generating the bundle at build time means the skill is always exactly as current as the repo it was built from.

### Building the skill bundle

```bash
./tools/build-skill.sh
```

This assembles a skill folder at `dist/certification-consulting-platform/` — the authored `SKILL.md` plus a freshly-copied `references/` tree pulled directly from `agents/`, `workflows/`, `templates/`, `standards/`, `playbooks/`, `knowledge/`, and the two key `docs/` files. Run this any time repo content changes and the packaged skill needs to catch up — there's no dependency tracking beyond "re-run it," since the copy is cheap and the alternative (partial, stale updates) is worse.

### Packaging into a `.skill` file

`build-skill.sh` only produces the folder — packaging it into a distributable `.skill` file (a validated zip) requires the skill-creator tooling's `package_skill.py` (validates required frontmatter fields, description length limits, then zips), which isn't bundled in this repository since it's a separate general-purpose skill-authoring tool, not something specific to this platform. If you have access to that tooling:

```bash
python3 -m scripts.package_skill dist/certification-consulting-platform /path/to/output
```

If you don't have that tooling available, the `dist/certification-consulting-platform/` folder itself is still directly usable — Claude Code and Claude Desktop can read a skill folder directly without it being packaged into a `.skill` archive; packaging is primarily useful for distributing/uploading to `claude.ai`.

### Keeping the skill description within limits

The `SKILL.md` frontmatter `description` field has a hard **1024-character limit** enforced by the packaging validator. `tools/skill-source/SKILL.md`'s description is written close to that limit deliberately (skill descriptions benefit from being specific and "a little pushy" about triggering conditions, per skill-authoring guidance) — if you extend it when adding new agents/workflows, check the length before rebuilding:

```bash
python3 -c "
import yaml
with open('tools/skill-source/SKILL.md') as f:
    content = f.read()
front = content.split('---')[1]
data = yaml.safe_load(front)
print('description length:', len(data['description']))
"
```

### When to update `tools/skill-source/SKILL.md` itself

Unlike the generated `references/` content, the router file needs a manual edit when:
- A new agent is added — add a row to the triage table.
- A new workflow is added for an existing agent — update that agent's row to reflect it has one.
- A platform-wide rule changes (e.g. `CLAUDE.md`'s quality bar, or a new MUST-level rule proven out via `tests/agent-behavior/`) — reflect it in the "Platform-wide operating rules" section, since that's the one part of the skill that's always in context and needs to carry the rules that matter regardless of which specific agent is active.

Re-run `tests/validate-repo.sh` after any change here too — while it doesn't currently check `tools/` content specifically, cross-references from `tools/skill-source/SKILL.md` into `references/...` paths are just prose describing the build output, not paths the structural checker resolves, so a broken reference here wouldn't be caught mechanically; review it by eye.
