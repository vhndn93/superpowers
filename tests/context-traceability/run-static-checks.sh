#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

require_file() {
  local path="$1"
  [ -f "$path" ] || fail "Missing required file: $path"
}

require_contains() {
  local path="$1"
  local pattern="$2"
  require_file "$path"
  grep -Fq "$pattern" "$path" || fail "Missing pattern in $path: $pattern"
}

support_skills=(
  skills/project-memory/SKILL.md
  skills/building-codebase-memory/SKILL.md
  skills/context-traceability/SKILL.md
  skills/traceability-review/SKILL.md
)

memory_files=(
  docs/project-memory/FEATURE_CONTEXT.md
  docs/project-memory/BUG_PATTERNS.md
  docs/project-memory/SPEC_INDEX.md
  docs/project-memory/ACTIVE_CONTEXT.md
)

commands=(
  context-start
  brainstorm-feature
  write-spec
  review-spec
  plan-spec
  review-plan
  implement-plan
  review-implementation
  debug-with-memory
  review-bug-fix
  update-spec
  record-learning
  review-memory
  review-traceability
  finish-traceable
)

for path in "${support_skills[@]}"; do
  require_file "$path"
  require_contains "$path" "description:"
done

for path in "${memory_files[@]}"; do
  require_file "$path"
done

for command in "${commands[@]}"; do
  path="commands/${command}.md"
  require_file "$path"
  require_contains "$path" "Fallback phrase:"
  require_contains "$path" "Required skill"
done

require_contains skills/using-superpowers/SKILL.md "context-traceability"
require_contains skills/using-superpowers/SKILL.md "project-memory"
require_contains skills/using-superpowers/SKILL.md "traceability-review"
require_contains skills/using-superpowers/SKILL.md "building-codebase-memory"
require_contains skills/project-memory/SKILL.md 'delegates to `building-codebase-memory`'
require_contains skills/project-memory/SKILL.md "Workflow Memory"
require_contains skills/project-memory/SKILL.md "Foundational Codebase Memory"
require_contains skills/project-memory/SKILL.md "Write directly only to workflow memory"
require_contains skills/project-memory/SKILL.md "Propose a foundational memory update"
require_contains skills/building-codebase-memory/SKILL.md "Trust-Level Handoff"
require_contains skills/building-codebase-memory/SKILL.md "directly requested"
require_contains skills/brainstorming/SKILL.md "building-codebase-memory"
require_contains skills/writing-plans/SKILL.md "building-codebase-memory"
require_contains commands/context-start.md "building-codebase-memory"
require_contains commands/record-learning.md "workflow memory files only"
require_file tests/skill-triggering/prompts/project-memory-record-learning-boundary.txt
require_file tests/skill-triggering/prompts/building-codebase-memory-refresh-foundational.txt
require_contains skills/brainstorming/SKILL.md "brainstorm-preflight"
require_contains skills/writing-plans/SKILL.md "planning-preflight"
require_contains skills/writing-plans/SKILL.md "Plan Pressure-Test"
require_contains skills/subagent-driven-development/SKILL.md "context packet"
require_contains skills/subagent-driven-development/implementer-prompt.md "Context Packet"
require_contains skills/executing-plans/SKILL.md "context packet"
require_contains skills/systematic-debugging/SKILL.md "BUG_PATTERNS.md"
require_contains skills/verification-before-completion/SKILL.md "traceability evidence"
require_contains skills/finishing-a-development-branch/SKILL.md "finish-traceable"

require_contains skills/traceability-review/SKILL.md "Blocking findings"
require_contains skills/traceability-review/SKILL.md "Non-blocking concerns"
require_contains skills/traceability-review/SKILL.md "Missing updates"
require_contains skills/traceability-review/SKILL.md "Recommended next command"
require_contains skills/brainstorming/SKILL.md "manual test artifact"
require_contains skills/writing-plans/SKILL.md "Manual test artifact"
require_contains skills/context-traceability/SKILL.md "manual test artifact"
require_contains skills/context-traceability/SKILL.md "manual QA status"
require_contains skills/traceability-review/SKILL.md "manual-test"
require_contains skills/subagent-driven-development/SKILL.md "manual test artifact"
require_contains skills/subagent-driven-development/implementer-prompt.md "manual test artifact"
require_contains skills/subagent-driven-development/spec-reviewer-prompt.md "manual test"
require_contains skills/executing-plans/SKILL.md "manual test artifact"
require_contains skills/systematic-debugging/SKILL.md "manual regression"
require_contains skills/verification-before-completion/SKILL.md "manual QA"
require_contains skills/finishing-a-development-branch/SKILL.md "manual QA"
require_contains skills/brainstorming/SKILL.md "Happy Path"
require_contains skills/brainstorming/SKILL.md "Affected Existing Features"
require_contains skills/writing-plans/SKILL.md "affected existing features"
require_contains skills/traceability-review/SKILL.md "manual test budget"
require_contains skills/traceability-review/SKILL.md "bug-fix-review"

require_contains commands/write-spec.md "manual test artifact"
require_contains commands/plan-spec.md "manual test artifact"
require_contains commands/implement-plan.md "manual test artifact"
require_contains commands/review-plan.md "manual test"
require_contains commands/review-implementation.md "manual test"
require_contains commands/review-bug-fix.md "manual regression"
require_contains commands/review-traceability.md "manual QA status"
require_contains commands/review-traceability.md "bug-fix-review"
require_contains commands/finish-traceable.md "manual QA"
require_contains commands/update-spec.md "manual test artifact"

require_file docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md
require_file tests/skill-triggering/prompts/traceability-review-manual-tests.txt
require_file tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt
require_contains tests/skill-triggering/run-all.sh "traceability-review-manual-tests.txt"
require_contains tests/explicit-skill-requests/run-all.sh "context-traceability-manual-tests.txt"

old_memory_skill="building-"project"-memory"
if grep -R "$old_memory_skill" skills commands tests docs/project-memory docs/superpowers/specs -n; then
  fail "Use building-codebase-memory instead of old project memory skill name"
fi

if grep -R "claude-mem" skills commands docs/project-memory tests/context-traceability -n | grep -v "optional" | grep -v "absent" | grep -v "optional adapter"; then
  fail "claude-mem must remain optional and absent-safe"
fi

echo "[PASS] Context traceability static checks passed"
