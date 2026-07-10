# Feature Workflow — Manual Tests

## Setup

- Superpowers installed as plugin on target harness (OpenCode recommended)
- Project with existing `docs/project-memory/` directory
- At least one existing command file in `commands/` for reference

## Test Cases

### Happy Path

#### MTC-01: Full flow — discovery to finish

Type: happy path
Priority: P0
Related acceptance criteria: AC-001 (single entry point orchestrates 5 phases), AC-002 (gate checks enforced), AC-004 (harness-agnostic), AC-006 (resume mid-flow)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 1-5 (skill), Task 6 (command), Task 7 (state tracking), Task 8 (spec index), Task 9 (manual test refinement), Task 10 (automated test)

Preconditions:
- Superpowers plugin installed on target harness
- Project has `docs/project-memory/` with at least `ACTIVE_CONTEXT.md`
- No active feature workflow in progress

Steps:
1. Trigger workflow: run `/start-feature` (or fallback phrase `Start feature workflow`)
2. Observe agent loads `feature-workflow` skill
3. Observe agent enters Discovery phase, reads project memory
4. Answer brainstorming questions until agent asks "Requirements captured? Confirm to proceed to Spec phase."
5. Confirm requirements captured
6. Observe agent transitions to Spec phase
7. Observe agent invokes `/write-spec` to create the spec document and manual test artifact
8. Observe agent updates `SPEC_INDEX.md` with the new spec entry
9. Observe agent runs `/review-spec` on the newly created spec
10. Observe review loop completes (no findings or `/update-spec` fixes applied)
11. Observe agent transitions to Plan phase, writes plan file
12. Observe agent runs `/review-plan`, review loop completes
13. Observe agent transitions to Implement phase
14. Observe agent executes plan tasks
15. Observe agent runs `/review-implementation`, review loop completes, automated tests pass
16. Observe agent transitions to Test phase, presents manual test artifact
17. Run manual tests for the implemented feature, report all pass
18. Observe agent runs `/finish-traceable` and completes workflow

Expected:
- All 5 phases execute in order
- Spec is written in Spec phase via `/write-spec`, NOT in Discovery
- Each gate blocks transition until review passes
- Workflow completes without manual intervention between phases (except gate confirmations and manual test results)
- `ACTIVE_CONTEXT.md` updated at each phase transition

Cleanup:
- Reset `ACTIVE_CONTEXT.md` to clean state for next test

Status:
- Not run

#### MTC-02: Spec write and review loop — findings require update

Type: happy path
Priority: P0
Related acceptance criteria: AC-002 (gate checks enforced), AC-003 (review loops iterate until clean)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 2 (skill — Phase 2 Spec write + review loop)

Preconditions:
- Discovery phase completed, requirements captured but spec NOT yet written

Steps:
1. Observe agent invokes `/write-spec` to create the spec document from the approved design
2. Observe spec file is created at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
3. Observe manual test artifact is created at `docs/superpowers/manual-tests/YYYY-MM-DD-<topic>-manual-tests.md`
4. Manually introduce an ambiguity into the spec (e.g., vague acceptance criterion)
5. Observe agent runs `/review-spec` on the spec
6. Observe `/review-spec` finds the ambiguity and reports it as a finding
7. Observe agent runs `/update-spec` to fix the ambiguity
8. Observe agent re-runs `/review-spec`
9. Repeat steps 6-8 until no open findings
10. Observe Gate 2 passes only after all findings resolved

Expected:
- `/write-spec` creates the spec from the approved design
- `/review-spec` detects the introduced ambiguity
- `/update-spec` resolves the finding
- Loop repeats until clean
- Gate does not pass while findings remain

Cleanup:
- Restore spec to clean state or proceed with fixed spec

Status:
- Not run

#### MTC-03: Plan review loop — findings require update

Type: happy path
Priority: P0
Related acceptance criteria: AC-002 (gate checks enforced), AC-003 (review loops iterate until clean)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 3 (skill — Phase 3 Plan review loop)

Preconditions:
- Discovery and Spec phases completed
- Plan file exists at `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`

Steps:
1. Manually remove a required task from the plan
2. Trigger Plan phase review: agent runs `/review-plan`
3. Observe `/review-plan` finds the missing task and reports it
4. Observe agent runs `/plan-spec` to add the missing task
5. Observe agent re-runs `/review-plan`
6. Repeat steps 3-5 until no open findings
7. Observe Gate 3 passes only after all findings resolved

Expected:
- `/review-plan` detects the missing task
- `/plan-spec` resolves the finding
- Loop repeats until clean
- Gate does not pass while findings remain

Cleanup:
- Restore plan to clean state or proceed with fixed plan

Status:
- Not run

#### MTC-04: Implementation review loop — findings require fix

Type: happy path
Priority: P0
Related acceptance criteria: AC-002 (gate checks enforced), AC-003 (review loops iterate until clean), AC-005 (automated verification required)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 3 (skill — Phase 4 Implement review loop)

Preconditions:
- Discovery, Spec, and Plan phases completed
- Implementation partially or fully executed

Steps:
1. Manually introduce a bug into the implemented code (e.g., wrong condition, missing null check)
2. Trigger implementation review: agent runs `/review-implementation`
3. Observe `/review-implementation` finds the bug and reports it
4. Observe agent fixes the bug
5. Observe agent re-runs automated tests and `/review-implementation`
6. Repeat steps 3-5 until no open findings AND all automated tests pass
7. Observe Gate 4 passes only after all findings resolved

Expected:
- `/review-implementation` detects the introduced bug
- Agent fixes the bug
- Automated tests pass after fix
- Loop repeats until clean
- Gate does not pass while findings remain or tests fail

Cleanup:
- Restore code to clean state or proceed with fixed implementation

Status:
- Not run

### Negative / Error Path

#### MTC-05: Session interruption and resume

Type: negative/error path
Priority: P1
Related acceptance criteria: AC-006 (resume mid-flow from `ACTIVE_CONTEXT.md`)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 1 (skill — Session Resume section)

Preconditions:
- Discovery phase completed, `ACTIVE_CONTEXT.md` contains phase tracking fields
- Session is ended

Steps:
1. Start a new session
2. Trigger `/context-start` or `/start-feature`
3. Observe agent reads `ACTIVE_CONTEXT.md`
4. Observe agent announces: "Resuming from [phase] phase. Spec at [path], Plan at [path]"
5. Observe agent continues from the recorded phase without redoing completed phases

Expected:
- Agent correctly identifies the last completed phase
- Agent resumes from the correct phase
- No duplicate work from completed phases
- Spec and plan paths are correctly resolved

Cleanup:
- None

Status:
- Not run

#### MTC-06: User attempts to skip gate

Type: negative/error path
Priority: P1
Related acceptance criteria: AC-002 (gate checks enforced)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 4 (skill — Gate Skip Policy section)

Preconditions:
- Discovery phase completed, Gate 1 pending

Steps:
1. Tell agent "skip spec, go straight to plan"
2. Observe agent warns about the risk of skipping the Spec phase
3. If user explicitly confirms the skip, observe agent allows the transition
4. Observe agent records the skip warning in `ACTIVE_CONTEXT.md`

Expected:
- Agent warns before allowing gate skip
- Agent does not silently skip the gate
- Warning is recorded in `ACTIVE_CONTEXT.md` if user confirms

Cleanup:
- Remove skip warning from `ACTIVE_CONTEXT.md` if testing in isolation

Status:
- Not run

#### MTC-07: No manual test applicable

Type: negative/error path
Priority: P1
Related acceptance criteria: AC-007 (graceful handling when no manual test needed)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 4 (skill — Phase 5 Test, Error Handling)

Preconditions:
- Feature is an internal refactor with no user-visible behavior

Steps:
1. Start feature workflow for the internal refactor
2. Complete Discovery phase
3. Observe spec includes `Manual test artifact: Not applicable` with a short reason
4. Observe Test phase skips manual test request and proceeds directly to `/finish-traceable`

Expected:
- Spec explicitly notes why manual test is not applicable
- Test phase does not request manual test execution
- Workflow proceeds to `/finish-traceable` without blocking

Cleanup:
- None

Status:
- Not run

### Edge Case / Risk

#### MTC-08: Subagents unavailable

Type: edge/risk
Priority: P2
Related acceptance criteria: AC-008 (fallback when subagents unavailable)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 3 (skill — Phase 4 Implement, Error Handling)

Preconditions:
- Harness does not support subagent dispatch (e.g., basic Claude CLI without subagent capability)

Steps:
1. Start feature workflow on the harness without subagent support
2. Complete Discovery, Spec, and Plan phases
3. Observe Implement phase falls back to `executing-plans` instead of `subagent-driven-development`
4. Observe workflow completes successfully

Expected:
- Implement phase uses `executing-plans` as fallback
- All plan tasks are still executed
- Workflow completes without errors

Cleanup:
- None

Status:
- Not run

#### MTC-09: Stale project memory at start

Type: edge/risk
Priority: P2
Related acceptance criteria: AC-009 (handles stale memory gracefully)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 2 (skill — Phase 1 Discovery, Error Handling)

Preconditions:
- `ACTIVE_CONTEXT.md` contains stale phase pointers (e.g., references deleted files or old branches)
- Foundational memory docs are outdated against current repo structure

Steps:
1. Start feature workflow
2. Observe agent detects stale memory during Discovery
3. Observe agent delegates to `building-codebase-memory` for refresh
4. Observe agent proceeds with refreshed memory

Expected:
- Agent detects staleness before proceeding
- `building-codebase-memory` is invoked for substantive refresh
- Workflow continues with updated memory

Cleanup:
- None

Status:
- Not run

#### MTC-10: Multiple specs match

Type: edge/risk
Priority: P2
Related acceptance criteria: AC-010 (asks user when ambiguous)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 4 (skill — Error Handling)

Preconditions:
- Project has multiple related specs that could match the current feature

Steps:
1. Start feature workflow
2. During Spec phase, observe agent detects multiple matching specs
3. Observe agent asks user to choose the correct spec
4. Observe agent uses the chosen spec for downstream phases

Expected:
- Agent does not guess when multiple specs match
- Agent explicitly asks user to choose
- Chosen spec is used consistently in Plan and Implement phases

Cleanup:
- None

Status:
- Not run

### Regression / Affected Existing Features

#### MTC-11: Existing commands remain independently usable

Type: regression/affected-feature
Priority: P0
Related acceptance criteria: AC-011 (existing commands unchanged and independently usable)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 6 (command — existing commands unchanged)

Preconditions:
- Superpowers plugin installed
- Existing command files present in `commands/`

Steps:
1. Run `/context-start` directly (not via `/start-feature`)
2. Verify it works independently and outputs project context
3. Run `/review-spec` directly with a spec path
4. Verify it works independently and outputs review findings
5. Run `/finish-traceable` directly
6. Verify it works independently and completes verification

Expected:
- All existing commands function without the `feature-workflow` skill
- No behavior changes to existing commands
- Commands produce the same output as before the feature workflow addition

Cleanup:
- None

Status:
- Not run

#### MTC-12: ACTIVE_CONTEXT.md new fields do not break existing readers

Type: regression/affected-feature
Priority: P0
Related acceptance criteria: AC-011 (existing commands unchanged and independently usable)
Related spec: `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
Related plan tasks: Task 7 (state tracking — backward-compatible fields)

Preconditions:
- `ACTIVE_CONTEXT.md` contains new phase tracking fields (`current_phase`, `gate_status`, `spec_path`, `plan_path`, `manual_test_artifact_path`)

Steps:
1. Start feature workflow, let it write phase tracking fields to `ACTIVE_CONTEXT.md`
2. Run `/context-start` in a separate session
3. Verify it reads the file without errors
4. Run `/review-memory`
5. Verify it reports the new fields correctly and does not flag them as stale or invalid

Expected:
- Existing commands read `ACTIVE_CONTEXT.md` without errors
- New fields are treated as additive, not breaking
- `/review-memory` recognizes new fields as valid

Cleanup:
- None

Status:
- Not run

## Affected Existing Features

| Feature | Touched Code Paths | Why Affected | Manual Case IDs |
|---------|-------------------|--------------|-----------------|
| Individual commands | None — referenced, not modified | New skill calls existing commands | MTC-11 |
| `ACTIVE_CONTEXT.md` | `docs/project-memory/ACTIVE_CONTEXT.md` | New fields: `current_phase`, `gate_status`, `spec_path`, `plan_path`, `manual_test_artifact_path` | MTC-05, MTC-12 |
| `SPEC_INDEX.md` | `docs/project-memory/SPEC_INDEX.md` | New entry for feature workflow spec | MTC-01 |
