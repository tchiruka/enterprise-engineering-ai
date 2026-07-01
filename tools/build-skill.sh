#!/usr/bin/env bash
#
# Script: build-skill.sh
# Purpose: Regenerate the enterprise-engineering-platform Claude Skill bundle
#   from the repository's live source files (agents/, workflows/, templates/,
#   standards/, playbooks/, knowledge/, docs/) rather than maintaining a
#   duplicated, driftable copy. The authored router (SKILL.md, the triage
#   table and platform-wide rules) lives in tools/skill-source/SKILL.md and
#   is versioned in this repo; the reference/ content underneath it is always
#   freshly assembled from the current state of the repo at build time.
#
# Usage: ./tools/build-skill.sh [output-dir]
#   output-dir defaults to ./dist relative to the repo root.
#
# This produces a skill FOLDER (dist/enterprise-engineering-platform/), not a
# packaged .skill file — packaging requires the skill-creator tooling
# (validation + zip), which isn't part of this repo. See tools/README.md for
# the packaging step.
#
set -euo pipefail
IFS=$'\n\t'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUTPUT_DIR="${1:-$REPO_ROOT/dist}"
SKILL_DIR="$OUTPUT_DIR/enterprise-engineering-platform"

echo "Building skill bundle at: $SKILL_DIR"
rm -rf "$SKILL_DIR"
mkdir -p "$SKILL_DIR/references"/{agents,workflows,templates,standards,playbooks,knowledge,docs}

# --- SKILL.md (authored, versioned separately from repo content) ---
cp tools/skill-source/SKILL.md "$SKILL_DIR/SKILL.md"

# --- Agents (skip _TEMPLATE.md — authoring template, not runtime content) ---
for d in agents/*/; do
    name="$(basename "$d")"
    [ "$name" = "_TEMPLATE.md" ] && continue
    if [ -f "${d}AGENT.md" ]; then
        mkdir -p "$SKILL_DIR/references/agents/$name"
        cp "${d}AGENT.md" "$SKILL_DIR/references/agents/$name/"
    fi
done

# --- Workflows (skip _TEMPLATE.md) ---
for d in workflows/*/; do
    name="$(basename "$d")"
    [ "$name" = "_TEMPLATE.md" ] && continue
    if [ -f "${d}WORKFLOW.md" ]; then
        mkdir -p "$SKILL_DIR/references/workflows/$name"
        cp "${d}WORKFLOW.md" "$SKILL_DIR/references/workflows/$name/"
    fi
done

# --- Templates, standards (flat directories, copy everything) ---
cp templates/*.md "$SKILL_DIR/references/templates/"
cp standards/*.md "$SKILL_DIR/references/standards/"

# --- Playbooks ---
for d in playbooks/*/; do
    name="$(basename "$d")"
    if [ -f "${d}PLAYBOOK.md" ]; then
        mkdir -p "$SKILL_DIR/references/playbooks/$name"
        cp "${d}PLAYBOOK.md" "$SKILL_DIR/references/playbooks/$name/"
    fi
done

# --- Knowledge index and key orientation docs ---
cp knowledge/index.md "$SKILL_DIR/references/knowledge/"
cp docs/glossary.md docs/architecture.md "$SKILL_DIR/references/docs/"

echo ""
echo "Skill bundle built. Contents:"
find "$SKILL_DIR" -type f | sort

echo ""
echo "Next step (packaging into a .skill file) requires the skill-creator tooling's"
echo "validate/zip script (not bundled in this repo) — see tools/README.md."
