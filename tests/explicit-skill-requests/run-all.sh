#!/usr/bin/env bash
# Run all explicit skill request tests
# Usage: ./run-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

echo "=== Running All Explicit Skill Request Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=""

run_case() {
    local skill="$1"
    local prompt_name="$2"
    local label="$3"

    echo ">>> Test $((PASSED + FAILED + 1)): $label"
    if "$SCRIPT_DIR/run-test.sh" "$skill" "$PROMPTS_DIR/$prompt_name"; then
        PASSED=$((PASSED + 1))
        RESULTS="$RESULTS\nPASS: $label"
    else
        FAILED=$((FAILED + 1))
        RESULTS="$RESULTS\nFAIL: $label"
    fi
    echo ""
}

# Test: subagent-driven-development, please
run_case "subagent-driven-development" "subagent-driven-development-please.txt" "subagent-driven-development-please"

# Test: use systematic-debugging
run_case "systematic-debugging" "use-systematic-debugging.txt" "use-systematic-debugging"

# Test: please use brainstorming
run_case "brainstorming" "please-use-brainstorming.txt" "please-use-brainstorming"

# Test: mid-conversation execute plan
run_case "subagent-driven-development" "mid-conversation-execute-plan.txt" "mid-conversation-execute-plan"

# Test: context-traceability manual test context packet
run_case "context-traceability" "context-traceability-manual-tests.txt" "context-traceability-manual-tests"

echo "=== Summary ==="
echo -e "$RESULTS"
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
