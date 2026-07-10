#!/usr/bin/env bash
# Structural verification for the feature-workflow skill
# Usage: ./feature-workflow-structural.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/../../skills/feature-workflow/SKILL.md"
PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"
    if [ "$result" = "true" ]; then
        echo "✅ PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "❌ FAIL: $description"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Feature Workflow Structural Tests ==="
echo ""

# Test 1: Skill file exists
if [ -f "$SKILL_FILE" ]; then
    check "Skill file exists" "true"
else
    check "Skill file exists" "false"
    echo "Cannot continue without skill file"
    exit 1
fi

# Test 2: Has YAML frontmatter
if head -5 "$SKILL_FILE" | grep -q "^---"; then
    check "Has YAML frontmatter" "true"
else
    check "Has YAML frontmatter" "false"
fi

# Test 3: Has name in frontmatter
if grep -q "^name: feature-workflow" "$SKILL_FILE"; then
    check "Has name: feature-workflow" "true"
else
    check "Has name: feature-workflow" "false"
fi

# Test 4: Has all 5 phase sections
PHASES_OK=true
for phase in "Phase 1: Discovery" "Phase 2: Spec" "Phase 3: Plan" "Phase 4: Implement" "Phase 5: Test"; do
    if ! grep -q "$phase" "$SKILL_FILE"; then
        PHASES_OK=false
    fi
done
check "All 5 phase sections present" "$PHASES_OK"

# Test 5: Has delegation rules
if grep -q "Delegation Rules" "$SKILL_FILE"; then
    check "Has delegation rules section" "true"
else
    check "Has delegation rules section" "false"
fi

# Test 6: Has gate enforcement
if grep -q "Gate" "$SKILL_FILE"; then
    check "Has gate enforcement" "true"
else
    check "Has gate enforcement" "false"
fi

# Test 7: Has error handling
if grep -q "Error Handling" "$SKILL_FILE"; then
    check "Has error handling section" "true"
else
    check "Has error handling section" "false"
fi

# Test 8: Has harness trigger mapping
if grep -q "Harness Trigger Mapping" "$SKILL_FILE"; then
    check "Has harness trigger mapping" "true"
else
    check "Has harness trigger mapping" "false"
fi

# Test 9: Uses "human partner" terminology
if grep -q "human partner" "$SKILL_FILE"; then
    check "Uses 'human partner' terminology" "true"
else
    check "Uses 'human partner' terminology" "false"
fi

# Test 10: Command file exists
if [ -f "$SCRIPT_DIR/../../commands/start-feature.md" ]; then
    check "Command file exists" "true"
else
    check "Command file exists" "false"
fi

# Test 11: No third-party dependencies referenced
if grep -qi "pip install\|npm install\|cargo add\|dependency:" "$SKILL_FILE"; then
    check "No third-party dependencies" "false"
else
    check "No third-party dependencies" "true"
fi

# Test 12: References existing skills (not duplicating behavior)
DELEGATED_SKILLS=true
for skill in "brainstorming" "writing-plans" "traceability-review" "subagent-driven-development" "verification-before-completion"; do
    if ! grep -q "$skill" "$SKILL_FILE"; then
        DELEGATED_SKILLS=false
    fi
done
check "References existing skills for delegation" "$DELEGATED_SKILLS"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
    exit 1
fi
