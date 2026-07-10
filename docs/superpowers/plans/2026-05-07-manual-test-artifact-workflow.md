# Manual Test Artifact Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the manual test artifact workflow described in the context traceability spec so specs, plans, implementation, review, debugging, and finishing keep human-run QA cases traceable.

**Architecture:** Keep slash commands thin and put reusable behavior in existing skills. Add one lightweight manual test template under `docs/superpowers/manual-tests/`, then update existing workflow skills, subagent prompts, command files, and static/eval surfaces to carry that artifact through the lifecycle.

**Tech Stack:** Markdown skills and commands, Bash static checks, existing Claude-based skill eval harness.

**Project Memory:** `docs/project-memory/ARCHITECTURE.md`, `docs/project-memory/CONVENTIONS.md`, `docs/project-memory/TESTING.md`, `docs/project-memory/FEATURE_CONTEXT.md`, `docs/project-memory/SPEC_INDEX.md`, `docs/project-memory/CONCERNS.md`

---

## Implementation Context Packet

**Active spec:** `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`

**Manual test artifact:** `docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md`

**Related artifacts:**
- `docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`
- `docs/superpowers/plans/2026-05-04-codebase-memory-delegation.md`
- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`
- `skills/context-traceability/SKILL.md`
- `skills/traceability-review/SKILL.md`
- `skills/subagent-driven-development/SKILL.md`
- `skills/subagent-driven-development/implementer-prompt.md`
- `skills/subagent-driven-development/spec-reviewer-prompt.md`
- `skills/executing-plans/SKILL.md`
- `skills/systematic-debugging/SKILL.md`
- `skills/verification-before-completion/SKILL.md`
- `skills/finishing-a-development-branch/SKILL.md`
- `commands/write-spec.md`
- `commands/plan-spec.md`
- `commands/implement-plan.md`
- `commands/review-plan.md`
- `commands/review-implementation.md`
- `commands/review-bug-fix.md`
- `commands/review-traceability.md`
- `commands/finish-traceable.md`
- `commands/update-spec.md`
- `tests/context-traceability/run-static-checks.sh`

**Feature context:** Slash commands remain thin entrypoints. Existing skills own workflow behavior. File-backed project memory is authoritative. Skill text is behavior-shaping content and needs eval/static evidence.

**Acceptance criteria:**
- AC-001: `brainstorming` creates and links a manual test artifact during spec writing when the feature has user-visible or manually verifiable behavior.
- AC-002: `writing-plans` reads and refines the linked manual test artifact, includes it in the plan header/context packet, and pressure-tests manual coverage.
- AC-003: `context-traceability` includes manual test artifact path, manual QA status, and human-run prerequisites in command state/context packets/subagent injection.
- AC-004: `traceability-review` checks manual test artifact coverage in spec, plan, implementation, bug-fix, and full review modes.
- AC-005: implementation execution paths read the manual test artifact and verify behavior against manual test expectations.
- AC-006: `verification-before-completion` and `finishing-a-development-branch` report manual QA separately from automated verification and do not mark manual tests passed without human evidence.
- AC-007: command files mention manual test artifact responsibilities where users enter the workflow.
- AC-008: static checks and eval prompts cover manual test artifact creation, refinement, review, bug-fix regression, and finish behavior.
- AC-009: manual test artifacts use a size/risk budget and required sections: Happy Path, Negative / Error Path, Edge Case / Risk, and Regression / Affected Existing Features.
- AC-010: manual test artifacts identify affected existing features, touched code paths, why they are affected, and which manual cases cover them.

**Edge cases and negative cases:**
- A spec has no human-verifiable behavior: spec and plan say `Manual test artifact: Not applicable` with a short reason.
- A manual test artifact is missing when a plan or implementation expects one: review reports a blocking or missing-update finding instead of silently continuing.
- A bug is human-verifiable but not automated-testable: bug-fix review requires a manual regression case and explains why automated coverage is not feasible.
- The human has not run manual tests: finish reports `Ready for human manual QA`, never `Passed`.
- The human reports a failed manual case: agent may record `Failed by human` with observed behavior and recommend `/debug-with-memory` or `/update-spec`.
- A feature is small and low risk: generate 4-6 focused cases rather than the default 8-12.
- A feature touches shared components, state, APIs, config, permissions, or existing workflows: include affected-feature regression cases even when the new feature's own happy path is simple.
- A generated artifact exceeds the recommended budget: trim duplicate or low-risk cases before asking the human partner to run it.

**Relevant code paths:**
- Skill workflows: `skills/brainstorming/SKILL.md`, `skills/writing-plans/SKILL.md`, `skills/context-traceability/SKILL.md`, `skills/traceability-review/SKILL.md`
- Execution handoff: `skills/subagent-driven-development/SKILL.md`, `skills/subagent-driven-development/implementer-prompt.md`, `skills/subagent-driven-development/spec-reviewer-prompt.md`, `skills/executing-plans/SKILL.md`
- Debug/finish: `skills/systematic-debugging/SKILL.md`, `skills/verification-before-completion/SKILL.md`, `skills/finishing-a-development-branch/SKILL.md`
- Commands: `commands/*.md` listed above
- Verification: `tests/context-traceability/run-static-checks.sh`, `tests/skill-triggering/prompts/`, `tests/explicit-skill-requests/prompts/`

**Verification commands:**
- `bash tests/context-traceability/run-static-checks.sh`
- `bash tests/skill-triggering/run-test.sh traceability-review tests/skill-triggering/prompts/traceability-review-manual-tests.txt 3`
- `bash tests/explicit-skill-requests/run-test.sh context-traceability tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt 3`
- If Claude/eval CLI is unavailable locally, record that limitation and rely on the static check plus prompt file coverage.

**Known risks and open questions:** Skill edits can change agent behavior in unintended ways. Keep wording concise and structural. Do not add dependencies. Do not change unrelated legacy workflow language. The existing `AGENTS.md` typechange is unrelated and must not be reverted.

## File Structure

- Create: `docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md`
  - Human-run QA checklist for this feature.
- Modify: `skills/brainstorming/SKILL.md`
  - Add manual test artifact creation/linking to spec-writing checklist and documentation phase.
- Modify: `skills/writing-plans/SKILL.md`
  - Add manual test artifact refinement to plan preflight, header, pressure-test, and self-review.
- Modify: `skills/context-traceability/SKILL.md`
  - Carry manual test artifact through command state, context packet, implementation context, debug preflight, and subagent injection.
- Modify: `skills/traceability-review/SKILL.md`
  - Add manual test artifact checks to report contract and review modes.
- Modify: `skills/subagent-driven-development/SKILL.md`
  - Require manual test artifact in traceability requirement.
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
  - Include manual test path/expectations in implementer context and self-review.
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md`
  - Include manual test expectations in spec compliance review.
- Modify: `skills/executing-plans/SKILL.md`
  - Require reading manual test artifact before inline execution.
- Modify: `skills/systematic-debugging/SKILL.md`
  - Add manual regression case update when bug is human-verifiable.
- Modify: `skills/verification-before-completion/SKILL.md`
  - Separate automated verification evidence from human-run manual QA status.
- Modify: `skills/finishing-a-development-branch/SKILL.md`
  - Include manual QA status in traceable finish hygiene.
- Modify: `commands/write-spec.md`, `commands/plan-spec.md`, `commands/implement-plan.md`, `commands/review-plan.md`, `commands/review-implementation.md`, `commands/review-bug-fix.md`, `commands/review-traceability.md`, `commands/finish-traceable.md`, `commands/update-spec.md`
  - Keep command prose thin while naming manual test artifact responsibilities.
- Modify: `tests/context-traceability/run-static-checks.sh`
  - Add objective checks for manual test artifact support.
- Create: `tests/skill-triggering/prompts/traceability-review-manual-tests.txt`
  - Pressure prompt for traceability review manual QA coverage.
- Create: `tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt`
  - Explicit prompt for manual-test-aware implementation context.

## Tasks

### Task 1: Add Static Checks And Eval Prompts For Manual Test Artifact Behavior

**Files:**
- Modify: `tests/context-traceability/run-static-checks.sh`
- Create: `tests/skill-triggering/prompts/traceability-review-manual-tests.txt`
- Create: `tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt`

- [ ] **Step 1: Add failing static check assertions**

In `tests/context-traceability/run-static-checks.sh`, after:

```bash
require_contains skills/traceability-review/SKILL.md "Recommended next command"
```

add:

```bash
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
```

- [ ] **Step 2: Run static checks and verify they fail**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with a message naming the first missing manual test artifact pattern, such as:

```text
[FAIL] Missing pattern in skills/brainstorming/SKILL.md: manual test artifact
```

- [ ] **Step 3: Create skill-triggering pressure prompt**

Create `tests/skill-triggering/prompts/traceability-review-manual-tests.txt` with:

```text
Review this finished implementation against its spec and plan. The spec links to docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md, but the implementation summary only mentions automated tests. Check whether the manual test artifact is still current, whether the case count fits the feature-size budget, whether Happy Path / Negative or Error Path / Edge Case or Risk / Regression or Affected Existing Features sections exist, whether affected existing features and touched shared code paths have manual coverage, whether manual QA status is honest, and whether missing manual regression cases should block finishing.
```

- [ ] **Step 4: Create explicit context-traceability prompt**

Create `tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt` with:

```text
Please use context-traceability to prepare an implementation context packet for an approved plan. Include the active spec path, plan path, project memory, acceptance criteria, verification commands, affected existing features, touched code paths, and the linked manual test artifact with any human-run setup requirements.
```

- [ ] **Step 5: Commit test scaffolding**

Run:

```bash
git add tests/context-traceability/run-static-checks.sh tests/skill-triggering/prompts/traceability-review-manual-tests.txt tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md
git commit -m "test: add manual test artifact workflow coverage"
```

### Task 2: Update Spec And Plan Authoring Skills

**Files:**
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Update brainstorming checklist**

In `skills/brainstorming/SKILL.md`, replace checklist item 8:

```markdown
8. **Write design doc** — save to a date-stamped design file under `docs/superpowers/specs/` and commit
```

with:

```markdown
8. **Write design doc and manual test artifact** — save the spec under `docs/superpowers/specs/`; when behavior is user-visible or manually verifiable, create and link a manual test artifact under `docs/superpowers/manual-tests/`
```

- [ ] **Step 2: Update brainstorming Documentation section**

In `skills/brainstorming/SKILL.md`, after:

```markdown
- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
  - (User preferences for spec location override this default)
```

add:

```markdown
- If the feature has user-visible or manually verifiable behavior, create `docs/superpowers/manual-tests/YYYY-MM-DD-<topic>-manual-tests.md` and link it from the spec.
- Manual test cases are for human QA after implementation. They do not replace automated tests or verification commands.
- Use these sections: `Happy Path`, `Negative / Error Path`, `Edge Case / Risk`, and `Regression / Affected Existing Features`.
- Default to 8-12 cases for a normal feature. Use 4-6 for small low-risk changes, 12-18 for large/high-risk changes, 3-6 for bug fixes, and 0-3 for internal refactors with limited manual-verifiable behavior.
- Include an `Affected Existing Features` map with feature name, touched code paths, why the feature is affected, and manual coverage case IDs.
- Start each manual case with `Status: Not run`; do not mark cases passed, failed, or blocked unless the human partner reports results.
- If manual testing is not applicable, include `Manual test artifact: Not applicable` in the spec with a short reason.
```

- [ ] **Step 3: Update brainstorming spec self-review**

In `skills/brainstorming/SKILL.md`, after:

```markdown
4. **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.
```

add:

```markdown
5. **Manual QA check:** If the feature is user-visible or manually verifiable, does the spec link to a manual test artifact with the right case budget, required sections, affected existing features, touched code paths, and cases mapped to acceptance criteria?
```

- [ ] **Step 4: Update writing-plans traceability preflight**

In `skills/writing-plans/SKILL.md`, replace the `## Traceability Preflight` numbered list:

```markdown
1. Invoke `context-traceability` in `planning-preflight` mode.
2. Read the approved spec and related specs/plans.
3. Inspect relevant code paths named by the spec, memory, or preflight.
4. Build a context packet in the plan.
5. Invoke `traceability-review` in `plan-review` mode after writing the plan.
```

with:

```markdown
1. Invoke `context-traceability` in `planning-preflight` mode.
2. Read the approved spec, related specs/plans, and linked manual test artifact when present.
3. Inspect relevant code paths named by the spec, memory, manual test artifact, or preflight.
4. Refine the manual test artifact with setup, data/account/device prerequisites, plan task mappings, affected existing features, touched code paths, and newly discovered edge or regression cases.
5. Build a context packet in the plan.
6. Invoke `traceability-review` in `plan-review` mode after writing the plan.
```

- [ ] **Step 5: Update writing-plans pressure-test**

In `skills/writing-plans/SKILL.md`, after:

```markdown
5. Are likely edge cases covered by tasks or tests?
```

add:

```markdown
6. Does human-verifiable behavior have manual test coverage, the right case budget, required sections, affected-existing-feature regression coverage, and setup clear enough for the human partner?
```

- [ ] **Step 6: Update writing-plans header template**

In `skills/writing-plans/SKILL.md`, inside the plan header template after:

```markdown
**Project Memory:** [Relevant docs/project-memory/*.md files used for this plan, or "None - greenfield"]
```

add:

```markdown
**Manual Test Artifact:** [path to docs/superpowers/manual-tests/... or "Not applicable - <reason>"]
```

Inside the `## Implementation Context Packet` template after:

```markdown
**Verification commands:** [commands]
```

add:

```markdown
**Manual test artifact:** [path plus cases that require human/device/account/data verification]
```

- [ ] **Step 7: Update writing-plans self-review**

In `skills/writing-plans/SKILL.md`, after:

```markdown
**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.
```

add:

```markdown
**4. Manual QA traceability:** If the spec links to a manual test artifact, does the plan link it, refine setup/prerequisites, map cases to plan tasks, identify affected existing features and touched code paths, keep the case count within the right budget, and avoid claiming human-run status?
```

- [ ] **Step 8: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: still FAIL until the later skills and commands are updated. The first failure should move past `skills/brainstorming/SKILL.md` and `skills/writing-plans/SKILL.md`.

- [ ] **Step 9: Commit authoring skill updates**

Run:

```bash
git add skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md
git commit -m "feat: add manual test artifacts to spec and plan authoring"
```

### Task 3: Update Context And Review Skills

**Files:**
- Modify: `skills/context-traceability/SKILL.md`
- Modify: `skills/traceability-review/SKILL.md`

- [ ] **Step 1: Update context-traceability overview**

In `skills/context-traceability/SKILL.md`, replace:

```markdown
Discover related context and keep each workflow phase traceable from discussion to memory, spec, plan, code, tests, and bug learnings.
```

with:

```markdown
Discover related context and keep each workflow phase traceable from discussion to memory, spec, plan, manual test artifact, code, tests, and bug learnings.
```

- [ ] **Step 2: Update implementation-context mode**

In `skills/context-traceability/SKILL.md`, replace the `implementation-context` numbered list with:

```markdown
1. Read the plan, referenced spec, context packet, and linked manual test artifact when present.
2. Verify the plan names related specs, memory files, likely code paths, affected existing features, edge cases, manual test artifact path, and verification commands.
3. Prepare a subagent-ready context packet that includes manual test expectations, affected existing features, touched code paths, and human-run setup requirements.
4. If context is partial, say which artifacts are missing before dispatch.
```

- [ ] **Step 3: Update debug-preflight and spec-update**

In `skills/context-traceability/SKILL.md`, replace the `debug-preflight` list with:

```markdown
1. Read `BUG_PATTERNS.md`, `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, relevant specs/plans, and the linked manual test artifact when present.
2. Establish expected behavior before root-cause investigation.
3. Prepare an evidence trail with observations, hypotheses, experiments, root cause, fix, automated verification, manual regression impact, and memory/spec/manual-test updates.
```

Replace the `spec-update` list with:

```markdown
1. Resolve the most relevant spec through `SPEC_INDEX.md`, filenames, and content search.
2. Ask the human partner to choose when multiple specs match.
3. Update behavior through the spec before implementation.
4. Update the linked manual test artifact when human-verifiable behavior, setup, expected results, negative cases, or regression cases change.
5. Trigger spec review after the update.
```

- [ ] **Step 4: Update command state and context packet**

In `skills/context-traceability/SKILL.md`, after:

```markdown
- Spec metadata: status, related specs, related plans, owning command, last review date.
- Plan metadata: referenced spec, status, context packet, related specs, verification commands.
```

replace those two lines with:

```markdown
- Spec metadata: status, related specs, related plans, owning command, last review date, manual test artifact path or not-applicable reason.
- Plan metadata: referenced spec, status, context packet, related specs, verification commands, manual test artifact path.
```

In the context packet template, after:

```text
Test obligations and verification commands:
```

add:

```text
Manual test artifact, case budget, affected existing features, touched code paths, and manual QA status:
```

- [ ] **Step 5: Update subagent injection**

In `skills/context-traceability/SKILL.md`, replace:

```markdown
2. Name the spec, plan, memory files, and code paths the subagent must read.
```

with:

```markdown
2. Name the spec, plan, manual test artifact when present, memory files, and code paths the subagent must read.
```

- [ ] **Step 6: Update traceability-review report contract**

In `skills/traceability-review/SKILL.md`, replace:

```markdown
Missing updates
- Spec/plan/memory/test update needed, with target file.
```

with:

```markdown
Missing updates
- Spec/plan/memory/test/manual-test update needed, with target file.
```

- [ ] **Step 7: Update traceability-review modes**

In `skills/traceability-review/SKILL.md`, replace the mode descriptions with these exact versions:

```markdown
### `spec-review`

Review a spec for mismatch with current discussion when available, approved design, related specs, project memory, feature context, assumptions, unknowns, edge cases, user-facing surface, acceptance criteria, manual test artifact link or not-applicable reason, manual test budget, required manual test sections, affected-existing-feature coverage, and testability.

### `plan-review`

Review a plan for spec coverage, missing code areas, missing tests, missing manual test coverage for human-verifiable behavior, missing affected-existing-feature coverage, task size, ordering problems, unclear acceptance criteria, missing docs/config/migrations, missing context packet inputs, and risk of behavior outside the spec.

Then pressure-test the plan:

1. Can each task be completed from the given context?
2. Are task dependencies ordered correctly?
3. Does any task write before required discovery?
4. Does every acceptance criterion have automated verification or manual test coverage?
5. Do likely edge cases appear in tasks, tests, or manual test cases?
6. Do affected existing features and touched shared code paths have regression coverage?
7. Is the manual test case count within the right budget?
8. Is manual setup clear enough for the human partner?

### `implementation-review`

Review the current diff against the active plan and spec. Check that every plan task is complete, every acceptance criterion is satisfied, feature-context invariants still hold, tests cover edge cases, manual test expectations still match implemented user-facing behavior, behavior has not drifted beyond the spec, unrelated changes are absent, and docs/spec/memory/manual-test updates are identified.

### `bug-fix-review`

Review whether root-cause evidence exists, the fix addresses root cause, an automated regression test exists when feasible, a manual regression case was added or updated when the bug is human-verifiable, no new edge case was introduced, the spec was updated if behavior changed, and `BUG_PATTERNS.md` was updated when the pattern is reusable.

### `memory-review`

Review `docs/project-memory/*.md` for stale facts, missing files, missing feature context, missing bug patterns, duplicate information, and stale `SPEC_INDEX.md` entries.

### `full`

Review the whole chain: discussion or available context, project memory, feature context, related specs, plan, manual test artifact and manual QA status, code, automated tests, bug patterns, and finishing hygiene. Include `bug-fix-review` when the target is a bug fix or when the active diff is bug-fix work.
```

- [ ] **Step 8: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: still FAIL until execution skills and commands are updated. The first failure should move past `skills/context-traceability/SKILL.md` and `skills/traceability-review/SKILL.md`.

- [ ] **Step 9: Commit context and review skill updates**

Run:

```bash
git add skills/context-traceability/SKILL.md skills/traceability-review/SKILL.md
git commit -m "feat: trace manual test artifacts through context review"
```

### Task 4: Update Execution, Debugging, And Finishing Skills

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md`
- Modify: `skills/executing-plans/SKILL.md`
- Modify: `skills/systematic-debugging/SKILL.md`
- Modify: `skills/verification-before-completion/SKILL.md`
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Update subagent-driven-development traceability requirement**

In `skills/subagent-driven-development/SKILL.md`, replace the traceability requirement paragraph:

```markdown
**Traceability requirement:** Before dispatching any implementer, spec reviewer, code quality reviewer, debugger, or explorer subagent, build or read the plan's context packet. Include that packet in the subagent prompt with the active spec path, plan path, related memory files, feature context, acceptance criteria, edge cases, relevant code paths, verification commands, and missing or untrusted context.
```

with:

```markdown
**Traceability requirement:** Before dispatching any implementer, spec reviewer, code quality reviewer, debugger, or explorer subagent, build or read the plan's context packet. Include that packet in the subagent prompt with the active spec path, plan path, linked manual test artifact when present, related memory files, feature context, acceptance criteria, edge cases, relevant code paths, verification commands, human-run setup requirements, and missing or untrusted context.
```

- [ ] **Step 2: Update implementer prompt context**

In `skills/subagent-driven-development/implementer-prompt.md`, replace:

```markdown
[Paste the active context packet here. Include spec path, plan path, project-memory files, feature context, acceptance criteria, edge cases, relevant code paths, verification commands, known risks, and untrusted context.]
```

with:

```markdown
[Paste the active context packet here. Include spec path, plan path, linked manual test artifact when present, project-memory files, feature context, acceptance criteria, edge cases, manual test expectations, relevant code paths, verification commands, human-run setup requirements, known risks, and untrusted context.]
```

Then replace:

```markdown
Before editing, read the named spec, plan, and memory files. If any required artifact is missing or contradictory, report NEEDS_CONTEXT instead of guessing.
```

with:

```markdown
Before editing, read the named spec, plan, manual test artifact when present, and memory files. If any required artifact is missing or contradictory, report NEEDS_CONTEXT instead of guessing.
```

- [ ] **Step 3: Update implementer self-review**

In `skills/subagent-driven-development/implementer-prompt.md`, under `**Completeness:**`, after:

```markdown
- Are there edge cases I didn't handle?
```

add:

```markdown
- Does the implementation still match manual test expectations for human-verifiable behavior?
```

Under `**Testing:**`, after:

```markdown
- Are tests comprehensive?
```

add:

```markdown
- Did I leave manual QA status untouched unless the human partner reported results?
```

- [ ] **Step 4: Update spec reviewer prompt**

In `skills/subagent-driven-development/spec-reviewer-prompt.md`, replace:

```markdown
[Paste active spec path, plan path, context packet, related specs, project-memory files, feature context, acceptance criteria, and edge cases.]
```

with:

```markdown
[Paste active spec path, plan path, context packet, linked manual test artifact when present, related specs, project-memory files, feature context, acceptance criteria, edge cases, and manual test expectations.]
```

Replace:

```markdown
Verify the implementation against the requested task, active spec, feature context, and related artifacts. If the task conflicts with the spec or feature context, report the conflict instead of choosing silently.
```

with:

```markdown
Verify the implementation against the requested task, active spec, feature context, manual test expectations, and related artifacts. If the task conflicts with the spec, feature context, or manual test artifact, report the conflict instead of choosing silently.
```

- [ ] **Step 5: Update executing-plans load step**

In `skills/executing-plans/SKILL.md`, replace:

```markdown
2. Read the referenced spec, related specs, project memory, and the plan's context packet.
```

with:

```markdown
2. Read the referenced spec, linked manual test artifact when present, related specs, project memory, and the plan's context packet.
```

- [ ] **Step 6: Update systematic-debugging traceability intro**

In `skills/systematic-debugging/SKILL.md`, replace:

```markdown
After the fix, update the relevant spec if behavior changed. If the root cause is reusable, record it in `BUG_PATTERNS.md`.
```

with:

```markdown
After the fix, update the relevant spec if behavior changed. If the bug is human-verifiable, add or update a manual regression case in the linked manual test artifact. If the root cause is reusable, record it in `BUG_PATTERNS.md`.
```

- [ ] **Step 7: Update verification-before-completion traceability evidence**

In `skills/verification-before-completion/SKILL.md`, after:

```markdown
3. Check whether feature context, project memory, `SPEC_INDEX.md`, or `BUG_PATTERNS.md` need updates.
```

add:

```markdown
4. If a manual test artifact is linked, report its path and manual QA status separately from automated verification. Do not mark manual cases passed, failed, or blocked without human-reported evidence.
```

Then renumber the existing steps 4 and 5 to 5 and 6.

- [ ] **Step 8: Update finishing-a-development-branch traceable hygiene**

In `skills/finishing-a-development-branch/SKILL.md`, in Step 1.5 after:

```markdown
1. Run `traceability-review` in `full` mode.
```

add:

```markdown
2. Report the linked manual test artifact path and manual QA status when present. Do not claim manual tests passed unless the human partner reported results.
```

Then renumber the existing steps 2-5 to 3-6 and update the final summary line to include `manual tests changed` and `manual tests requiring human execution`.

- [ ] **Step 9: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: still FAIL until command files are updated. The first failure should move past execution, debugging, and finishing skills.

- [ ] **Step 10: Commit execution and finish skill updates**

Run:

```bash
git add skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/spec-reviewer-prompt.md skills/executing-plans/SKILL.md skills/systematic-debugging/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: include manual test artifacts in execution context"
```

### Task 5: Update Slash Command Prose

**Files:**
- Modify: `commands/write-spec.md`
- Modify: `commands/plan-spec.md`
- Modify: `commands/implement-plan.md`
- Modify: `commands/review-plan.md`
- Modify: `commands/review-implementation.md`
- Modify: `commands/review-bug-fix.md`
- Modify: `commands/review-traceability.md`
- Modify: `commands/finish-traceable.md`
- Modify: `commands/update-spec.md`

- [ ] **Step 1: Update write-spec command**

Replace the final paragraph of `commands/write-spec.md` with:

```markdown
Finalize only an approved design that is pending spec writing. Use `traceability-review` in `spec-review` mode before presenting the spec path. When behavior is user-visible or manually verifiable, create and link a manual test artifact under `docs/superpowers/manual-tests/` with the right case budget, required sections, and affected existing features. Do not write an implementation plan.
```

- [ ] **Step 2: Update plan-spec command**

Replace the final paragraph of `commands/plan-spec.md` with:

```markdown
Use `writing-plans`. Before writing tasks, use `context-traceability` in `planning-preflight` mode and include a context packet in the plan. Read and refine the linked manual test artifact when present, including setup, human-run prerequisites, affected existing features, touched code paths, and plan task mappings. Run `traceability-review` in `plan-review` mode and pressure-test the plan before asking for approval.
```

- [ ] **Step 3: Update implement-plan command**

Replace the final paragraph of `commands/implement-plan.md` with:

```markdown
Use `subagent-driven-development` when subagents are available; otherwise use `executing-plans`. Read the plan, referenced spec, context packet, linked manual test artifact when present, feature context, related specs, and relevant code before executing.
```

- [ ] **Step 4: Update review-plan command**

Replace the final paragraph of `commands/review-plan.md` with:

```markdown
Use `traceability-review` in `plan-review` mode. Resolve the referenced spec, read project memory, related specs, and linked manual test artifact when present, inspect named code paths, and pressure-test task ordering, automated verification coverage, manual test budget, required sections, affected-existing-feature coverage, and manual test coverage.
```

- [ ] **Step 5: Update review-implementation command**

Replace the final paragraph of `commands/review-implementation.md` with:

```markdown
Use `traceability-review` in `implementation-review` mode. Inspect the current diff and verify plan completion, spec acceptance criteria, feature-context invariants, automated tests, manual test expectations, affected existing feature coverage, docs, and memory updates.
```

- [ ] **Step 6: Update review-bug-fix command**

Replace the final paragraph of `commands/review-bug-fix.md` with:

```markdown
Use `traceability-review` in `bug-fix-review` mode. Check root-cause evidence, automated regression test coverage when feasible, manual regression coverage when the bug is human-verifiable, spec updates for behavior changes, and reusable bug-pattern recording.
```

- [ ] **Step 7: Update review-traceability command**

Replace the final paragraph of `commands/review-traceability.md` with:

```markdown
Use `traceability-review` in `full` mode unless the target clearly maps to a narrower review mode. Check discussion or available context, project memory, feature context, related specs, plan, manual test artifact and manual QA status, code, automated tests, and bug patterns. Include `bug-fix-review` when the target is a bug fix or when the active diff is bug-fix work.
```

- [ ] **Step 8: Update finish-traceable command**

Replace the final paragraph of `commands/finish-traceable.md` with:

```markdown
Use `verification-before-completion`, then run `traceability-review` in `full` mode. Update `SPEC_INDEX.md`, project memory, and `BUG_PATTERNS.md` when required before invoking `finishing-a-development-branch`. Report the linked manual test artifact and manual QA status separately from automated verification; do not claim manual tests passed without human-reported results.
```

- [ ] **Step 9: Update update-spec command**

Replace the final paragraph of `commands/update-spec.md` with:

```markdown
Use `context-traceability` in `spec-update` mode. Resolve the target spec through `SPEC_INDEX.md`, filenames, and content search. Ask when multiple specs match. Update the linked manual test artifact when the change affects human-verifiable behavior, setup, expected results, negative cases, or regression cases. Run `traceability-review` in `spec-review` mode after the update.
```

- [ ] **Step 10: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with:

```text
[PASS] Context traceability static checks passed
```

- [ ] **Step 11: Commit command updates**

Run:

```bash
git add commands/write-spec.md commands/plan-spec.md commands/implement-plan.md commands/review-plan.md commands/review-implementation.md commands/review-bug-fix.md commands/review-traceability.md commands/finish-traceable.md commands/update-spec.md
git commit -m "feat: expose manual test artifacts in workflow commands"
```

### Task 6: Run Review, Pressure-Test, And Final Verification

**Files:**
- Review: all files changed by Tasks 1-5
- Modify if needed: any file with review findings

- [ ] **Step 1: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected:

```text
[PASS] Context traceability static checks passed
```

- [ ] **Step 2: Run manual-test-aware skill trigger eval if available**

Run:

```bash
bash tests/skill-triggering/run-test.sh traceability-review tests/skill-triggering/prompts/traceability-review-manual-tests.txt 3
```

Expected if the Claude/eval CLI is available: PASS. The result should show `traceability-review` was loaded.

If the command fails because the local environment lacks the required external CLI, record the exact failure in the final verification notes and do not claim eval pass.

- [ ] **Step 3: Run explicit context-traceability eval if available**

Run:

```bash
bash tests/explicit-skill-requests/run-test.sh context-traceability tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt 3
```

Expected if the Claude/eval CLI is available: PASS. The result should show `context-traceability` was loaded.

If the command fails because the local environment lacks the required external CLI, record the exact failure in the final verification notes and do not claim eval pass.

- [ ] **Step 4: Pressure-test the plan against the spec**

Read `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md` and this plan. Confirm:

```text
AC-001 covered by Task 2.
AC-002 covered by Task 2.
AC-003 covered by Task 3 and Task 4.
AC-004 covered by Task 3 and Task 5.
AC-005 covered by Task 4 and Task 5.
AC-006 covered by Task 4 and Task 5.
AC-007 covered by Task 5.
AC-008 covered by Task 1 and Task 6.
AC-009 covered by Task 1, Task 2, Task 3, and Task 5.
AC-010 covered by Task 1, Task 2, Task 3, and Task 5.
```

Expected: every acceptance criterion maps to at least one task and at least one verification step.

- [ ] **Step 5: Review final diff**

Run:

```bash
git diff -- skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/context-traceability/SKILL.md skills/traceability-review/SKILL.md skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/spec-reviewer-prompt.md skills/executing-plans/SKILL.md skills/systematic-debugging/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md commands/write-spec.md commands/plan-spec.md commands/implement-plan.md commands/review-plan.md commands/review-implementation.md commands/review-bug-fix.md commands/review-traceability.md commands/finish-traceable.md commands/update-spec.md tests/context-traceability/run-static-checks.sh tests/skill-triggering/prompts/traceability-review-manual-tests.txt tests/explicit-skill-requests/prompts/context-traceability-manual-tests.txt docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md
```

Expected: diff is limited to manual test artifact workflow changes and does not touch unrelated files such as `AGENTS.md`.

- [ ] **Step 6: Commit final fixes if needed**

If Steps 1-5 required fixes, commit them:

```bash
git add <fixed files>
git commit -m "fix: tighten manual test artifact workflow"
```

## Self-Review

**Spec coverage:** All manual test artifact requirements from the updated spec are mapped to concrete skill, command, prompt, and static-check changes, including case budgets and affected-existing-feature coverage.

**Placeholder scan:** No task uses placeholder language or generic test instructions. Each file change names exact target files and text to insert or replace.

**Type consistency:** The plan uses one term consistently: `manual test artifact`. Human-run status uses `manual QA status`. Static checks match these exact phrases.

**Manual QA traceability:** This plan links to `docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md`, maps that artifact to plan tasks, uses required manual test sections, includes affected existing features, and keeps all manual cases at `Status: Not run`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-07-manual-test-artifact-workflow.md`. Two execution options:

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
