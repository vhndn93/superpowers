#!/usr/bin/env bash
# Run all skill triggering tests
# Usage: ./run-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

CASES=(
    "systematic-debugging|systematic-debugging.txt"
    "test-driven-development|test-driven-development.txt"
    "writing-plans|writing-plans.txt"
    "dispatching-parallel-agents|dispatching-parallel-agents.txt"
    "executing-plans|executing-plans.txt"
    "requesting-code-review|requesting-code-review.txt"
    "traceability-review|traceability-review-manual-tests.txt"
)

echo "=== Running Skill Triggering Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=()

for test_case in "${CASES[@]}"; do
    skill="${test_case%%|*}"
    prompt_name="${test_case#*|}"
    prompt_file="$PROMPTS_DIR/$prompt_name"

    if [ ! -f "$prompt_file" ]; then
        echo "⚠️  SKIP: No prompt file for $skill"
        continue
    fi

    echo "Testing: $skill ($prompt_name)"

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" 3 2>&1 | tee /tmp/skill-test-$skill.log; then
        PASSED=$((PASSED + 1))
        RESULTS+=("✅ $skill")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("❌ $skill")
    fi

    echo ""
    echo "---"
    echo ""
done

echo ""
echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
    echo "  $result"
done
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
