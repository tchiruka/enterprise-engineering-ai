#!/usr/bin/env bash
#
# Script: validate-repo.sh
# Purpose: Structural validation test suite for this platform's own artifacts —
#   formalizes what docs/cross-reference-audit-milestone-13.md has been doing
#   manually milestone-over-milestone into a repeatable, scriptable test suite.
#   This is the "Testing framework" deliverable named in the original project
#   brief that had no concrete implementation until this milestone.
#
# What it checks:
#   1. Every agents/*/AGENT.md (excluding _TEMPLATE.md) has all 9 required
#      sections per agents/_TEMPLATE.md.
#   2. Every workflows/*/WORKFLOW.md (excluding _TEMPLATE.md) has all 10
#      required sections per workflows/_TEMPLATE.md.
#   3. No placeholder text (TODO, [insert ...], lorem ipsum) outside files that
#      are themselves templates (where placeholder syntax is expected/correct).
#   4. Cross-reference consistency: every backtick-quoted repository path
#      resolves to a real file, except a maintained allow-list of deliberately
#      deferred/historical references.
#
# What it does NOT check (out of scope for this script, by design):
#   - Semantic/technical correctness of any procedure described in a workflow
#     (e.g. whether a PowerShell command is actually correct) — this is a
#     structural linter, not a technical reviewer. A human or a
#     platform-specific agent still owns technical accuracy.
#   - Whether an agent's Scope boundaries are logically consistent with
#     another agent's — that's a judgment call for `chief-infrastructure-engineer`
#     or a human maintainer, not something a script can verify.
#
# Usage: ./validate-repo.sh
# Exit code: 0 if all checks pass, 1 if any genuine failure is found.
#
set -euo pipefail
IFS=$'\n\t'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL_COUNT=0
PASS_COUNT=0

log_pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "  PASS: $*"
}

log_fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "  FAIL: $*" >&2
}

# ---------------------------------------------------------------------------
# Check 1: Agent structure
# ---------------------------------------------------------------------------
echo "== Checking agent structure =="
REQUIRED_AGENT_SECTIONS=(
    "## Mission" "## Scope" "## Responsibilities" "## Decision Framework"
    "## Vendor Guidance" "## Escalation Rules" "## Deliverables"
    "## Output Format" "## Quality Checklist"
)
for agent_file in agents/*/AGENT.md; do
    [ -f "$agent_file" ] || continue
    missing=""
    for section in "${REQUIRED_AGENT_SECTIONS[@]}"; do
        if ! grep -qF "$section" "$agent_file"; then
            missing="$missing [$section]"
        fi
    done
    if [ -z "$missing" ]; then
        log_pass "$agent_file has all required sections"
    else
        log_fail "$agent_file missing:$missing"
    fi
done

# ---------------------------------------------------------------------------
# Check 2: Workflow structure
# ---------------------------------------------------------------------------
echo "== Checking workflow structure =="
REQUIRED_WORKFLOW_SECTIONS=(
    "## Executive Summary" "## Prerequisites" "## Assessment" "## Risk Analysis"
    "## Dependencies" "## Implementation" "## Validation" "## Rollback"
    "## Acceptance Criteria" "## Lessons Learned"
)
for workflow_file in workflows/*/WORKFLOW.md; do
    [ -f "$workflow_file" ] || continue
    missing=""
    for section in "${REQUIRED_WORKFLOW_SECTIONS[@]}"; do
        # Workflows nest scenarios, so "## Implementation" etc. may appear as
        # "### Implementation" inside a scenario, or as a shared top-level
        # "## Assessment" — accept either level for sections that are
        # legitimately scenario-scoped rather than requiring an exact "##" match.
        if ! grep -qE "^#{2,3} ${section#\#\# }" "$workflow_file"; then
            missing="$missing [$section]"
        fi
    done
    if [ -z "$missing" ]; then
        log_pass "$workflow_file has all required sections"
    else
        log_fail "$workflow_file missing:$missing"
    fi
done

# ---------------------------------------------------------------------------
# Check 3: No stray placeholder text outside template files
# ---------------------------------------------------------------------------
echo "== Checking for placeholder text outside template files =="
# Template files (where bracket-style placeholders are correct, not a defect):
#   agents/_TEMPLATE.md, workflows/_TEMPLATE.md, and everything under templates/
PLACEHOLDER_HITS=$(grep -rln "TODO\|lorem ipsum\|\[insert" --include="*.md" \
    agents workflows standards playbooks examples docs knowledge 2>/dev/null \
    | grep -v "_TEMPLATE.md" || true)
if [ -z "$PLACEHOLDER_HITS" ]; then
    log_pass "no stray placeholder text found outside template files"
else
    while IFS= read -r hit; do
        log_fail "placeholder text found in $hit"
    done <<< "$PLACEHOLDER_HITS"
fi

# ---------------------------------------------------------------------------
# Check 4: Cross-reference consistency
# ---------------------------------------------------------------------------
echo "== Checking cross-reference consistency =="
# Maintained allow-list of deliberately deferred/historical references — keep
# this in sync with docs/cross-reference-audit-milestone-13.md's own table.
DEFERRED_REFS=(
    "docs/roadmap.md"
    "standards/terraform.md"
    "docs/incident-response-playbook.md"
    "playbooks/_TEMPLATE.md"
    "agents/X/AGENT.md"
    "workflows/Y/WORKFLOW.md"
)
is_deferred() {
    local ref="$1"
    for d in "${DEFERRED_REFS[@]}"; do
        [ "$ref" = "$d" ] && return 0
    done
    return 1
}

REFS=$(grep -rEo '`(agents|workflows|templates|standards|knowledge|examples|docs|playbooks|checklists|policies|scripts|automation|tests|tools|training|diagrams)/[a-zA-Z0-9_./-]+`' \
    --include="*.md" . | sed 's/^[^:]*://' | tr -d '`' | sort -u)

while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    case "$ref" in
        *"..."*) continue ;;   # generic ellipsis-truncated category references, not real paths
        */) continue ;;        # bare directory references (e.g. `tests/agent-behavior/`) used
                                # generically in prose, not a specific file — same classification
                                # bug Milestone 13 fixed for `agents/` vs. `agents/X/AGENT.md`;
                                # applies here to any directory-level reference ending in "/"
    esac
    if [ -f "$ref" ]; then
        continue  # resolves cleanly, no need to log every single one individually
    elif is_deferred "$ref"; then
        continue  # known, documented, correctly deferred
    else
        log_fail "cross-reference does not resolve and is not in the deferred allow-list: $ref"
    fi
done <<< "$REFS"
log_pass "cross-reference check complete (see any FAILs above for genuine gaps)"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "== Summary =="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
