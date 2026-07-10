# Feature Workflow — 5-Phase Orchestrated Development Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new `feature-workflow` skill and `/start-feature` command that orchestrates 5 phases (Discovery → Spec → Plan → Implement → Test) with gate checks, reusing existing Superpowers skills.

**Architecture:** A single orchestrator skill (`skills/feature-workflow/SKILL.md`) defines a state machine with 5 phases. A thin command (`commands/start-feature.md`) triggers it. State is tracked via `ACTIVE_CONTEXT.md`. The skill delegates to existing skills — it does not duplicate behavior.

**Tech Stack:** Markdown (skill files), YAML frontmatter, shell (no runtime dependencies).

**Project Memory:** `docs/project-memory/ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`, `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, `ACTIVE_CONTEXT.md`

**Manual Test Artifact:** `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md`

---

## Implementation Context Packet

**Active spec:** `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`

**Related artifacts:**
- `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md`
- `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
- `skills/brainstorming/SKILL.md` (pattern reference)
- `skills/project-memory/SKILL.md` (pattern reference)
- `commands/context-start.md` (command pattern reference)

**Feature context:**
- Superpowers is a zero-dependency Markdown skill library
- Skills are behavior-shaping code, not prose
- Slash commands are thin entry points, not competing workflows
- File-based project memory is authoritative
- `ACTIVE_CONTEXT.md` stores phase tracking state
- Orchestrator skill delegates to existing skills, does not duplicate behavior

**Acceptance criteria:**
- AC-001: Single entry point orchestrates all 5 phases
- AC-002: Gate checks enforced at each boundary
- AC-003: Review loops iterate until clean
- AC-004: Harness-agnostic via trigger/fallback mapping
- AC-005: Automated verification required before Gate 4
- AC-006: Session interruption recovery from `ACTIVE_CONTEXT.md`
- AC-007: Graceful handling when no manual test applicable
- AC-008: Fallback to `executing-plans` when subagents unavailable
- AC-009: Stale memory detection triggers refresh
- AC-010: Asks user when multiple specs match
- AC-011: Existing commands remain independently usable

**Edge cases and negative cases:**
- Session interruption mid-flow
- User attempts to skip gate
- No manual test applicable (internal refactor)
- Subagents unavailable
- Stale project memory at start
- Multiple specs match
- Existing commands must work independently

**Relevant code paths:**
- `skills/feature-workflow/SKILL.md` (new)
- `commands/start-feature.md` (new)
- `docs/project-memory/ACTIVE_CONTEXT.md` (modify — add phase tracking fields)

**Verification commands:**
- `ls skills/feature-workflow/SKILL.md` — file exists
- `ls commands/start-feature.md` — file exists
- Skill trigger test: prompt "start feature workflow" → verify skill loads
- Existing command independence: run `/context-start`, `/review-spec`, `/finish-traceable` independently

**Manual test artifact:** 12 cases (MTC-01 through MTC-12) covering happy path, error path, edge cases, and regression. Cases require human/device/account verification for MTC-01 (full flow), MTC-05 (resume), MTC-08 (subagent fallback), MTC-09 (stale memory), MTC-11 (command independence), MTC-12 (backward compatibility).

**Known risks and open questions:**
- Skill behavior changes require eval evidence — this is a new skill, so evals must be run before upstream PR
- `using-superpowers` skill may need updating to list `feature-workflow` as an available skill (deferred to future)
- Open upstream memory PRs (#880, #1129, #1113, #935) — this is fork-only until eval evidence exists

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `skills/feature-workflow/SKILL.md` | Create | Orchestrator skill — 5-phase state machine, gate enforcement, delegation rules (Tasks 1-5) |
| `commands/start-feature.md` | Create | Thin command trigger with fallback phrase (Task 6) |
| `tests/skill-triggering/prompts/feature-workflow.txt` | Create | Prompt-based skill trigger test (Task 10) |
| `tests/skill-triggering/feature-workflow-structural.sh` | Create | Structural verification script (Task 10) |
| `docs/project-memory/ACTIVE_CONTEXT.md` | Modify | Add phase tracking fields (Task 7) |
| `docs/project-memory/SPEC_INDEX.md` | Modify | Add feature workflow entry (Task 8) |
| `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md` | Modify | Refine with plan task mappings (Task 9) |
| `docs/superpowers/plans/2026-05-18-feature-workflow.md` | Create | This plan file |

---

## Task 1: Create skill frontmatter, core principle, state machine, and state tracking

**Files:**
- Create: `skills/feature-workflow/SKILL.md`

- [ ] **Step 1: Create the skill file with frontmatter and opening sections**

```markdown
---
name: feature-workflow
description: "Orchestrates a 5-phase feature development flow (Discovery → Spec → Plan → Implement → Test) with gate checks. Use when starting end-to-end feature work from idea to manual test."
---

# Feature Workflow

Orchestrate feature development through 5 phases with explicit gate checks. Load this skill via `/start-feature` or when the user says "start feature workflow".

## Core Principle

This skill is an orchestrator. It delegates to existing Superpowers skills for each phase. It does not duplicate behavior — it defines when and how to invoke other skills, enforces gate checks, and tracks phase state.

## Phase State Machine

```
discovery → spec → plan → implement → test
              ↑        ↑        ↑
           [gate]   [gate]   [gate]
```

Each gate blocks transition until the corresponding `traceability-review` passes with no open findings (except Gate 1 which is user confirmation).

## State Tracking

Read `docs/project-memory/ACTIVE_CONTEXT.md` at start. Track:
- `current_phase`: one of `discovery`, `spec`, `plan`, `implement`, `test`
- `gate_status`: `pending`, `passed`, `failed`
- `spec_path`: path to the written spec
- `plan_path`: path to the written plan
- `manual_test_artifact_path`: path to manual test cases

Update this file at each phase transition.

## Session Resume

At skill load, check `ACTIVE_CONTEXT.md`:
- If `current_phase` is set and `gate_status` is `passed`, announce: "Resuming from [phase] phase. Spec at [path], Plan at [path]."
- Resume from the next phase after the last passed gate.
- If `gate_status` is `pending`, resume from the current phase.
- If `ACTIVE_CONTEXT.md` is missing or has no phase data, start from Discovery.
```

- [ ] **Step 2: Verify frontmatter follows conventions**

Check:
- `description` describes triggering conditions, not workflow steps
- `name` matches directory name (`feature-workflow`)

- [ ] **Step 3: Commit**

```bash
git add skills/feature-workflow/SKILL.md
git commit -m "feat: add feature-workflow skill — frontmatter, core principle, state machine, state tracking"
```

---

## Task 2: Add Phase 1 (Discovery) and Phase 2 (Spec) definitions

**Files:**
- Modify: `skills/feature-workflow/SKILL.md`

- [ ] **Step 1: Append Phase 1 and Phase 2 to the skill file**

Append after the Session Resume section:

```markdown

## Phase 1: Discovery

**Trigger:** Skill load with no active phase, or user says "start feature workflow"

**Actions:**
1. Invoke `project-memory` in start mode — read memory, check freshness
2. If foundational memory is missing/stale, delegate to `building-codebase-memory`
3. Invoke `context-traceability` in `brainstorm-preflight` mode — discover related specs, plans, code paths
4. Invoke `brainstorming` — follow its full workflow: ask clarifying questions, propose approaches, present design, get approval
5. Capture all requirements and design decisions (do NOT write the spec yet)
6. Ask user: "Requirements captured? Confirm to proceed to Spec phase."

**Gate 1:** User confirms requirements are captured. Update `ACTIVE_CONTEXT.md`: `current_phase: spec`, `gate_status: passed`. Transition to Phase 2. The spec does NOT exist yet — Phase 2 begins with `/write-spec`.

## Phase 2: Spec

**Trigger:** Gate 1 passed

**Actions:**
1. Invoke `/write-spec` — finalize the approved design from Discovery into a spec document at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
2. `/write-spec` creates the manual test artifact when behavior is user-visible or manually verifiable
3. Update `SPEC_INDEX.md` with the new spec entry
4. Loop:
   - Run `/review-spec` — `traceability-review` in `spec-review` mode
   - If findings exist → run `/update-spec` — fix findings → repeat
   - If no open findings → Gate 2 passed

**Gate 2:** `traceability-review` spec-review passes with no open findings. Update `ACTIVE_CONTEXT.md`: `current_phase: plan`, `gate_status: passed`, `spec_path: <path>`, `manual_test_artifact_path: <path>`. Transition to Phase 3.
```

- [ ] **Step 2: Commit**

```bash
git add skills/feature-workflow/SKILL.md
git commit -m "feat: add feature-workflow skill — Phase 1 Discovery and Phase 2 Spec"
```

---

## Task 3: Add Phase 3 (Plan) and Phase 4 (Implement) definitions

**Files:**
- Modify: `skills/feature-workflow/SKILL.md`

- [ ] **Step 1: Append Phase 3 and Phase 4 to the skill file**

Append after Phase 2:

```markdown

## Phase 3: Plan

**Trigger:** Gate 2 passed

**Actions:**
1. Invoke `writing-plans` — follow its full workflow: planning preflight, context packet, write plan, pressure-test
2. Plan is written to `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`
3. Refine linked manual test artifact with test setup, prerequisites, task mappings
4. Loop:
   - Run `traceability-review` in `plan-review` mode
   - If findings exist → update the plan to fix findings → repeat
   - If no open findings → Gate 3 passed

**Gate 3:** `traceability-review` plan-review passes with no open findings. Update `ACTIVE_CONTEXT.md`: `current_phase: implement`, `gate_status: passed`, `plan_path: <path>`. Transition to Phase 4.

## Phase 4: Implement

**Trigger:** Gate 3 passed

**Actions:**
1. Invoke `subagent-driven-development` when subagents are available; otherwise invoke `executing-plans`
2. Read plan, spec, context packet, manual test artifact before executing
3. After implementation complete:
   - Run `traceability-review` in `implementation-review` mode
   - If findings exist → fix → repeat review
   - If no open findings AND all automated tests pass → Gate 4 passed

**Gate 4:** `traceability-review` implementation-review passes with no open findings AND automated verification commands pass. Update `ACTIVE_CONTEXT.md`: `current_phase: test`, `gate_status: passed`. Transition to Phase 5.
```

- [ ] **Step 2: Commit**

```bash
git add skills/feature-workflow/SKILL.md
git commit -m "feat: add feature-workflow skill — Phase 3 Plan and Phase 4 Implement"
```

---

## Task 4: Add Phase 5 (Test), Gate Skip Policy, and Error Handling

**Files:**
- Modify: `skills/feature-workflow/SKILL.md`

- [ ] **Step 1: Append Phase 5, Gate Skip Policy, and Error Handling**

Append after Phase 4:

```markdown

## Phase 5: Test

**Trigger:** Gate 4 passed

**Actions:**
1. Present manual test artifact with case budget, affected existing features, and current status
2. Request human partner to run manual tests
3. Await human-reported results
4. If failures found → determine root cause:
   - If code bug → fix → run `traceability-review` in `implementation-review` mode → Gate 4 → re-request manual test
   - If spec/plan issue → back up to the appropriate phase → fix → re-execute downstream phases → re-request manual test
5. If all pass → workflow complete. Human partner may invoke `/finish-traceable` as a separate workflow.

**End:** Workflow complete.

## Gate Skip Policy

If the user requests to skip a gate:
1. Warn about the risk of skipping [phase name] phase
2. If user explicitly confirms, allow the transition
3. Record the skip warning in `ACTIVE_CONTEXT.md` under a `gate_skip_warning` field

## Error Handling

- **Session interruption:** Read `ACTIVE_CONTEXT.md` at skill load, resume from last passed gate
- **Subagents unavailable:** Fall back to `executing-plans` in Phase 4
- **No manual test applicable:** If spec includes `Manual test artifact: Not applicable`, Phase 5 skips to `verification-before-completion`
- **Multiple specs match:** Ask user to choose the correct spec
- **Review finds critical issue:** Block transition, present findings, ask user how to proceed
```

- [ ] **Step 2: Commit**

```bash
git add skills/feature-workflow/SKILL.md
git commit -m "feat: add feature-workflow skill — Phase 5 Test, Gate Skip Policy, Error Handling"
```

---

## Task 5: Add Harness Trigger Mapping and Delegation Rules

**Files:**
- Modify: `skills/feature-workflow/SKILL.md`

- [ ] **Step 1: Append Harness Trigger Mapping and Delegation Rules**

Append after Error Handling:

```markdown

## Harness Trigger Mapping

| Harness | Trigger | Fallback |
|---------|---------|----------|
| OpenCode | `/start-feature` | `Start feature workflow` |
| Claude Code | `/start-feature` | `Start feature workflow` |
| Cursor | `/start-feature` | `Start feature workflow` |
| Codex | — | `Start feature workflow` (natural prompt) |
| Gemini CLI | `/start-feature` | `Start feature workflow` |
| GitHub Copilot CLI | — | `Start feature workflow` (natural prompt) |

## Delegation Rules

| Phase | Delegated Skill | Mode/Context |
|-------|----------------|--------------|
| Discovery | `project-memory` | start mode |
| Discovery | `building-codebase-memory` | when foundational memory missing/stale |
| Discovery | `context-traceability` | brainstorm-preflight mode |
| Discovery | `brainstorming` | full workflow (design capture only, NOT spec writing) |
| Spec | `brainstorming` | `/write-spec` — finalize approved design into spec |
| Spec | `traceability-review` | spec-review mode |
| Spec | `context-traceability` | spec-update mode (via `/update-spec`) |
| Plan | `writing-plans` | full workflow (includes planning preflight) |
| Plan | `context-traceability` | planning-preflight mode |
| Plan | `traceability-review` | plan-review mode |
| Implement | `subagent-driven-development` | when subagents available |
| Implement | `executing-plans` | fallback when subagents unavailable |
| Implement | `traceability-review` | implementation-review mode |
| Test | — | present manual test artifact, await human results |
```

- [ ] **Step 2: Verify the complete skill file**

Check:
- All 8 required sections present (per spec Skill Content section)
- Uses "human partner" terminology consistently
- No duplicated behavior from existing skills
- All delegation rules reference existing skills by name
- File is under 200 lines (concise)

- [ ] **Step 3: Commit**

```bash
git add skills/feature-workflow/SKILL.md
git commit -m "feat: add feature-workflow skill — Harness Trigger Mapping and Delegation Rules"
```

---

## Task 6: Create the `/start-feature` command

**Files:**
- Create: `commands/start-feature.md`

- [ ] **Step 1: Create the command file**

```markdown
---
description: "Start the 5-phase feature development workflow with gate checks"
---

# /start-feature

Fallback phrase: `Start feature workflow`

Required skill: `superpowers:feature-workflow`

Use `feature-workflow` skill. If `ACTIVE_CONTEXT.md` contains a previous phase state, resume from the last passed gate. Otherwise start from Discovery phase.

The workflow orchestrates: Discovery → Spec → Plan → Implement → Test, with explicit gate checks at each phase boundary.
```

- [ ] **Step 2: Verify command follows existing patterns**

Compare with `commands/context-start.md`:
- Same frontmatter structure (`description`)
- Same heading format (`# /command-name`)
- Same fallback phrase line
- Same required skill line
- Concise body (3-5 lines)

- [ ] **Step 3: Commit**

```bash
git add commands/start-feature.md
git commit -m "feat: add /start-feature command trigger"
```

---

## Task 7: Update `ACTIVE_CONTEXT.md` with plan state

**Files:**
- Modify: `docs/project-memory/ACTIVE_CONTEXT.md`

- [ ] **Step 1: Update `ACTIVE_CONTEXT.md` to reflect the current plan state**

The file currently has `Plan: —` and `current_phase: spec`. Update it:

```markdown
# Active Context

Small pointer file for the current traceable workflow. Keep this file short.

## Current Work

- **Feature:** Feature workflow — 5-phase orchestrated development
- **Spec:** `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
- **Plan:** `docs/superpowers/plans/2026-05-18-feature-workflow.md`
- **Branch:** `fork/improve-workflow`
- **State:** Plan approved, ready for implementation
- **current_phase:** implement
- **gate_status:** passed
- **spec_path:** `docs/superpowers/specs/2026-05-18-feature-workflow-design.md`
- **plan_path:** `docs/superpowers/plans/2026-05-18-feature-workflow.md`
- **manual_test_artifact_path:** `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md`

## Notes

- Do not store large summaries here.
- If this file is stale, prefer explicit spec or plan paths over guessing.
```

- [ ] **Step 2: Commit**

```bash
git add docs/project-memory/ACTIVE_CONTEXT.md
git commit -m "docs: update ACTIVE_CONTEXT.md for implementation phase"
```

---

## Task 8: Update `SPEC_INDEX.md` with feature workflow entry

**Files:**
- Modify: `docs/project-memory/SPEC_INDEX.md`

- [ ] **Step 1: Update `SPEC_INDEX.md` with the current status**

The table should contain a row for the feature workflow with updated status:
```markdown
| Feature workflow — 5-phase orchestrated development | Plan approved, ready for implementation | `docs/superpowers/specs/2026-05-18-feature-workflow-design.md` | `docs/superpowers/plans/2026-05-18-feature-workflow.md` | `docs/project-memory/FEATURE_CONTEXT.md`, `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md` | New skill + command to chain existing commands into a guided flow with gate checks. |
```

- [ ] **Step 2: If entry is missing or status is stale, update it**

- [ ] **Step 3: Commit**

```bash
git add docs/project-memory/SPEC_INDEX.md
git commit -m "docs: add feature workflow entry to SPEC_INDEX.md"
```

---

## Task 9: Update manual test artifact with plan task mappings

**Files:**
- Modify: `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md`

- [ ] **Step 1: Update each manual test case's "Related plan tasks" field**

Replace `Related plan tasks: pending` with actual task references:

- MTC-01: `Related plan tasks: Task 1-5 (skill), Task 6 (command), Task 7 (state tracking), Task 8 (spec index), Task 9 (manual test refinement), Task 10 (automated test)`
- MTC-02: `Related plan tasks: Task 2 (skill — Phase 2 Spec review loop)`
- MTC-03: `Related plan tasks: Task 3 (skill — Phase 3 Plan review loop)`
- MTC-04: `Related plan tasks: Task 4 (skill — Phase 4 Implement review loop)`
- MTC-05: `Related plan tasks: Task 1 (skill — Session Resume section)`
- MTC-06: `Related plan tasks: Task 4 (skill — Gate Skip Policy section)`
- MTC-07: `Related plan tasks: Task 4 (skill — Phase 5 Test, Error Handling)`
- MTC-08: `Related plan tasks: Task 3 (skill — Phase 4 Implement, Error Handling)`
- MTC-09: `Related plan tasks: Task 2 (skill — Phase 1 Discovery, Error Handling)`
- MTC-10: `Related plan tasks: Task 4 (skill — Error Handling)`
- MTC-11: `Related plan tasks: Task 6 (command — existing commands unchanged)`
- MTC-12: `Related plan tasks: Task 7 (state tracking — backward-compatible fields)`

- [ ] **Step 2: Verify test case budget and sections**

Check:
- 12 cases total (workflow orchestrator = normal feature, 8-12 budget) ✅
- Required sections present: Happy Path, Negative/Error Path, Edge Case/Risk, Regression/Affected Existing Features ✅
- Affected Existing Features map present ✅
- All cases have Type, Priority, Related AC, Related spec, Related plan tasks, Preconditions, Steps, Expected, Cleanup, Status ✅

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md
git commit -m "docs: refine manual test artifact with plan task mappings"
```

---

## Task 10: Create automated skill trigger test

**Files:**
- Create: `tests/skill-triggering/prompts/feature-workflow.txt`
- Modify: `tests/skill-triggering/run-all.sh` (add feature-workflow to the test list)

- [ ] **Step 1: Create the prompt file**

The existing test structure uses `prompts/*.txt` files with test prompts, run by `run-test.sh` or `run-all.sh`. Create the prompt:

```
tests/skill-triggering/prompts/feature-workflow.txt
```

Content:
```
Start feature workflow
```

This is the minimal trigger phrase that should load the `feature-workflow` skill.

- [ ] **Step 2: Create a structural verification script**

Create `tests/skill-triggering/feature-workflow-structural.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Structural test: verifies the feature-workflow skill file exists and has required content.
# This complements the prompt-based test in prompts/feature-workflow.txt.

SKILL_PATH="skills/feature-workflow/SKILL.md"
PASS=0
FAIL=0

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $label"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Feature Workflow Skill Structural Tests ==="

check "Skill file exists" "[ -f '$SKILL_PATH' ]"
check "Frontmatter has name: feature-workflow" "grep -q '^name: feature-workflow' '$SKILL_PATH'"
check "Frontmatter has description" "grep -q '^description:' '$SKILL_PATH'"
check "Has Phase 1: Discovery" "grep -q 'Phase 1: Discovery' '$SKILL_PATH'"
check "Has Phase 2: Spec" "grep -q 'Phase 2: Spec' '$SKILL_PATH'"
check "Has Phase 3: Plan" "grep -q 'Phase 3: Plan' '$SKILL_PATH'"
check "Has Phase 4: Implement" "grep -q 'Phase 4: Implement' '$SKILL_PATH'"
check "Has Phase 5: Test" "grep -q 'Phase 5: Test' '$SKILL_PATH'"
check "Has gate enforcement" "grep -q 'Gate [1-4]' '$SKILL_PATH'"
check "Has state tracking" "grep -q 'current_phase' '$SKILL_PATH'"
check "Has Session Resume" "grep -q 'Session Resume' '$SKILL_PATH'"
check "Has Gate Skip Policy" "grep -q 'Gate Skip Policy' '$SKILL_PATH'"
check "Has Error Handling" "grep -q 'Error Handling' '$SKILL_PATH'"
check "Has Harness Trigger Mapping" "grep -q 'Harness Trigger Mapping' '$SKILL_PATH'"
check "Has Delegation Rules" "grep -q 'Delegation Rules' '$SKILL_PATH'"
check "Command file exists" "[ -f 'commands/start-feature.md' ]"
check "Command has fallback phrase" "grep -q 'Fallback phrase' 'commands/start-feature.md'"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

echo "=== All feature-workflow structural tests passed ==="
```

- [ ] **Step 3: Make the test executable**

```bash
chmod +x tests/skill-triggering/feature-workflow-structural.sh
```

- [ ] **Step 4: Run the test**

```bash
bash tests/skill-triggering/feature-workflow-structural.sh
```

Expected: All PASS lines printed, exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/skill-triggering/prompts/feature-workflow.txt tests/skill-triggering/feature-workflow-structural.sh
git commit -m "test: add feature-workflow skill trigger test"
```

---

## Task 11: Run plan self-review and pressure-test

**Files:**
- Modify: `docs/superpowers/plans/2026-05-18-feature-workflow.md` (this file)

- [ ] **Step 1: Spec coverage check**

Verify each spec requirement has a task:

| Spec Requirement | Task |
|-----------------|------|
| Skill with 5 phases | Task 1-5 |
| Command trigger | Task 6 |
| State tracking in ACTIVE_CONTEXT.md | Task 7 |
| SPEC_INDEX.md entry | Task 8 |
| Manual test artifact refinement | Task 9 |
| Automated skill trigger test | Task 10 |
| Harness-agnostic | Task 5 (Harness Trigger Mapping section) |
| Gate enforcement | Task 1-4 (Gate sections in each phase) |
| Session resume | Task 1 (Session Resume section) |
| Error handling | Task 4 (Error Handling section) |
| Delegation to existing skills | Task 5 (Delegation Rules section) |
| Existing commands unchanged | Task 6 (command only adds, doesn't modify) |
| Orchestrator skill pattern recorded | Task 13 |

All covered ✅

- [ ] **Step 2: Placeholder scan**

Search for: TBD, TODO, "implement later", "add appropriate", "write tests for the above", "similar to Task N"

None found ✅

- [ ] **Step 3: Manual QA traceability**

- Plan links manual test artifact ✅
- Manual test artifact has setup prerequisites ✅
- Cases mapped to plan tasks ✅
- Affected existing features identified ✅
- Case count within budget (12 cases, normal feature) ✅
- Setup clear enough for human partner ✅

- [ ] **Step 4: Pressure-test execution order**

1. Task 1 (frontmatter + core + state machine) can be completed independently ✅
2. Task 2 (Phase 1-2) depends on Task 1 file existing ✅
3. Task 3 (Phase 3-4) depends on Task 2 ✅
4. Task 4 (Phase 5 + error handling) depends on Task 3 ✅
5. Task 5 (harness mapping + delegation) depends on Task 4, can be done in parallel with Task 6 ✅
6. Task 6 (command) depends on Task 1 existing but can be done in parallel with Tasks 2-5 ✅
7. Task 7 (update ACTIVE_CONTEXT.md) can be done anytime ✅
8. Task 8 (update SPEC_INDEX.md) can be done anytime ✅
9. Task 9 (manual test refinement) depends on Task 5 being complete ✅
10. Task 10 (automated test) depends on Task 5 being complete ✅
11. Task 11 (self-review) depends on all previous tasks ✅
12. Task 12 (verification commands) depends on all previous tasks ✅
13. Task 13 (FEATURE_CONTEXT.md) can be done anytime after Task 1 ✅
14. Task 14 (final commit) depends on all previous tasks ✅

Order is correct ✅

---

## Verification Commands

After all tasks:

```bash
# Verify skill file exists and has correct frontmatter
head -4 skills/feature-workflow/SKILL.md

# Verify command file exists and has correct frontmatter
head -4 commands/start-feature.md

# Verify ACTIVE_CONTEXT.md has phase tracking fields
grep -c "current_phase\|gate_status\|spec_path\|plan_path\|manual_test_artifact_path" docs/project-memory/ACTIVE_CONTEXT.md
# Expected: 5

# Verify SPEC_INDEX.md has feature workflow entry
grep "Feature workflow" docs/project-memory/SPEC_INDEX.md
# Expected: 1 match

# Verify manual test artifact has plan task mappings
grep -c "Related plan tasks:" docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md
# Expected: 12 (one per case)

# Run automated structural test
bash tests/skill-triggering/feature-workflow-structural.sh
# Expected: All PASS, exit code 0
```

---

## Task 13: Record orchestrator skill pattern in FEATURE_CONTEXT.md

**Files:**
- Modify: `docs/project-memory/FEATURE_CONTEXT.md`

- [ ] **Step 1: Add the orchestrator skill pattern to the Terms section**

Append to the Terms section:

```markdown
- **Orchestrator skill:** A skill that defines a multi-phase workflow state machine and delegates to existing skills for each phase. It does not duplicate behavior — it specifies when and how to invoke other skills, enforces gate checks, and tracks state via `ACTIVE_CONTEXT.md`. Example: `feature-workflow`.
```

- [ ] **Step 2: Commit**

```bash
git add docs/project-memory/FEATURE_CONTEXT.md
git commit -m "docs: record orchestrator skill pattern in FEATURE_CONTEXT.md"
```

---

## Task 14: Final commit and status update

- [ ] **Step 1: Verify all files are committed**

Run:
```bash
git status
```

Expected: clean working tree (all changes committed by individual task commits).

- [ ] **Step 2: Push branch**

```bash
git push origin fork/improve-workflow
```
