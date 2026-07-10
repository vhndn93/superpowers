# Manual Test Artifact Workflow Manual Tests

Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan: `docs/superpowers/plans/2026-05-07-manual-test-artifact-workflow.md`
Feature size: Normal feature
Target case budget: 8-12 cases

## Affected Existing Features

- Feature: Spec authoring flow
  Code paths touched:
  - `skills/brainstorming/SKILL.md`
  - `commands/write-spec.md`
  Why affected:
  - The existing documentation phase gains manual test artifact creation and review responsibilities.
  Manual coverage:
  - TC-001
  - TC-008

- Feature: Plan authoring flow
  Code paths touched:
  - `skills/writing-plans/SKILL.md`
  - `commands/plan-spec.md`
  Why affected:
  - Plans must refine manual test artifacts and preserve traceability to affected code paths and existing features.
  Manual coverage:
  - TC-002
  - TC-009

- Feature: Traceability review and finish flow
  Code paths touched:
  - `skills/traceability-review/SKILL.md`
  - `skills/verification-before-completion/SKILL.md`
  - `skills/finishing-a-development-branch/SKILL.md`
  - `commands/review-traceability.md`
  - `commands/finish-traceable.md`
  Why affected:
  - Reviews and finish summaries must distinguish automated verification from human-run manual QA.
  Manual coverage:
  - TC-005
  - TC-006
  - TC-010

## Happy Path

### TC-001: Spec writing creates a sectioned manual test artifact

Type: happy path
Priority: P0
Related acceptance criteria: AC-001, AC-009
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 2

Preconditions:
- A feature has an approved design with user-visible or manually verifiable behavior.
- No manual test artifact exists yet for that feature.

Steps:
1. Ask the agent to write the approved spec.
2. Inspect the generated spec.
3. Inspect `docs/superpowers/manual-tests/`.

Expected:
- The spec links to `docs/superpowers/manual-tests/YYYY-MM-DD-<feature>-manual-tests.md`.
- The manual test artifact exists.
- The artifact uses Happy Path, Negative / Error Path, Edge Case / Risk, and Regression / Affected Existing Features sections.
- The total case count fits the feature-size budget.
- Each case starts with `Status: Not run`.

Cleanup:
- None.

Status:
- Not run

### TC-002: Plan writing refines the linked manual test artifact

Type: happy path
Priority: P0
Related acceptance criteria: AC-002, AC-010
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 2

Preconditions:
- A spec links to an existing manual test artifact.
- The implementation plan has not been written yet.

Steps:
1. Ask the agent to write a plan from the spec.
2. Inspect the plan header and implementation context packet.
3. Inspect the manual test artifact.

Expected:
- The plan links to the manual test artifact.
- The context packet includes the manual test artifact path.
- Manual cases include implementation setup or human-run prerequisites when relevant.
- The artifact maps cases to plan tasks after the plan exists.
- The artifact identifies affected existing features and touched code paths.

Cleanup:
- None.

Status:
- Not run

### TC-003: Implementation context includes manual test expectations

Type: happy path
Priority: P1
Related acceptance criteria: AC-003, AC-005
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 3, Task 4

Preconditions:
- A plan references a manual test artifact.
- The implementation flow uses subagents or inline execution.

Steps:
1. Ask the agent to implement the plan.
2. Inspect the implementation handoff or subagent prompt.

Expected:
- The handoff names the manual test artifact as required reading.
- The implementation context packet includes human-verifiable behavior and setup.
- The context packet includes affected existing features and touched code paths.
- The agent does not rely only on automated verification when manual behavior is relevant.

Cleanup:
- None.

Status:
- Not run

## Negative / Error Path

### TC-004: Feature with no manual-verifiable behavior records not applicable

Type: negative/error path
Priority: P1
Related acceptance criteria: AC-001, AC-009
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 2, Task 3

Preconditions:
- A spec describes an internal-only refactor with no meaningful manual-verifiable behavior.

Steps:
1. Ask the agent to write or review the spec.
2. Inspect the spec and plan metadata.

Expected:
- The spec says `Manual test artifact: Not applicable` with a short reason.
- The plan repeats the not-applicable reason.
- The agent does not create a low-value checklist just to satisfy the workflow.

Cleanup:
- None.

Status:
- Not run

### TC-005: Finish does not claim manual tests passed

Type: negative/error path
Priority: P0
Related acceptance criteria: AC-006
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 4, Task 5

Preconditions:
- Implementation is complete.
- Automated verification has run.
- Manual test cases still have `Status: Not run`.

Steps:
1. Ask the agent to finish traceable work.
2. Inspect the finish summary.

Expected:
- The summary reports automated verification separately.
- The summary links the manual test artifact.
- The summary says manual QA is ready for human execution.
- The agent does not mark manual cases passed, failed, or blocked without human-reported results.

Cleanup:
- None.

Status:
- Not run

## Edge Case / Risk

### TC-006: Review catches an undersized manual test artifact

Type: edge/risk
Priority: P1
Related acceptance criteria: AC-004, AC-009
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 3, Task 5

Preconditions:
- A normal feature has only two manual test cases.
- The feature has multiple user-visible flows.

Steps:
1. Ask the agent to review the spec or plan.
2. Inspect the review findings.

Expected:
- The review reports that the artifact is below the normal 8-12 case budget.
- The review identifies which sections are missing or too thin.
- The recommended action is to update the manual test artifact before implementation or finish.

Cleanup:
- None.

Status:
- Not run

### TC-007: Review catches an oversized low-value manual test artifact

Type: edge/risk
Priority: P2
Related acceptance criteria: AC-004, AC-009
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 3, Task 5

Preconditions:
- A small low-risk feature has more than 12 manual test cases.
- Several cases duplicate the same low-risk behavior.

Steps:
1. Ask the agent to review the plan or manual test artifact.
2. Inspect the review findings.

Expected:
- The review flags the artifact as over budget for a small change.
- The review recommends trimming duplicate or low-value cases.
- The review preserves coverage for happy path, one negative/error path, one edge/risk, and affected-feature regression when relevant.

Cleanup:
- None.

Status:
- Not run

## Regression / Affected Existing Features

### TC-008: Spec phase identifies likely affected existing features

Type: regression/affected-feature
Priority: P1
Related acceptance criteria: AC-001, AC-010
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 2

Preconditions:
- A new feature changes a shared user-facing flow or shared command behavior.

Steps:
1. Ask the agent to write the spec and manual test artifact.
2. Inspect the manual test artifact.

Expected:
- The artifact has an `Affected Existing Features` map.
- The map names likely affected existing features using related specs, feature context, and shared flows.
- Regression cases reference the affected features.

Cleanup:
- None.

Status:
- Not run

### TC-009: Plan phase refines affected code paths

Type: regression/affected-feature
Priority: P0
Related acceptance criteria: AC-002, AC-010
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 2, Task 3

Preconditions:
- A manual test artifact has an affected-feature map.
- Planning inspects relevant skill, command, and test files.

Steps:
1. Ask the agent to write or review the implementation plan.
2. Inspect the affected-feature map in the manual test artifact.

Expected:
- The map includes specific touched code paths.
- Each affected feature explains why it is affected.
- Each affected feature links to at least one manual regression case.

Cleanup:
- None.

Status:
- Not run

### TC-010: Bug-fix review requires manual regression coverage when human-verifiable

Type: regression/affected-feature
Priority: P1
Related acceptance criteria: AC-004, AC-006, AC-010
Related spec: `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
Related plan tasks: Task 4, Task 5

Preconditions:
- A bug fix changes behavior visible to a human tester.
- The feature has a linked manual test artifact.

Steps:
1. Ask the agent to review the bug fix.
2. Inspect the review report.

Expected:
- The report checks root-cause evidence.
- The report checks automated regression coverage when feasible.
- The report checks whether a manual regression case was added or updated.
- Missing manual regression coverage is reported as a finding.

Cleanup:
- None.

Status:
- Not run
