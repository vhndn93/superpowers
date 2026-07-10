# Feature Workflow — Orchestrated 5-Phase Development

## Problem

Superpowers provides individual commands (`/context-start`, `/brainstorm-feature`, `/write-spec`, `/review-spec`, `/plan-spec`, `/review-plan`, `/implement-plan`, `/review-implementation`, `/finish-traceable`) but no mechanism to chain them into a single guided flow with explicit gate checks. Users must manually remember the sequence, track which phase they are in, and know when to transition. This leads to skipped gates, lost context between phases, and inconsistent workflow discipline across harnesses.

## Goals

- Provide a single entry point that orchestrates the full feature development flow from discovery to manual test.
- Enforce gate checks at each phase boundary — no phase transition without explicit pass.
- Support review loops (spec, plan, implementation) that iterate until no open findings remain.
- Be harness-agnostic — works on OpenCode, Codex, Antigravity, and any harness that can load skills.
- Reuse existing skills and commands; do not duplicate behavior.
- Track phase state durably so new sessions can resume mid-flow.

## Acceptance Criteria

- **AC-001:** Single entry point (`/start-feature` or fallback phrase) orchestrates all 5 phases from discovery to manual test request.
- **AC-002:** Gate checks are enforced at each phase boundary — no transition occurs without explicit pass. Agent warns but allows skip only with explicit user confirmation.
- **AC-003:** Review loops (spec, plan, implementation) iterate until no open findings remain. Each loop uses the appropriate `traceability-review` mode.
- **AC-004:** Workflow is harness-agnostic — the same skill logic works on OpenCode, Codex, Antigravity, Claude Code, Cursor, Gemini CLI, and GitHub Copilot CLI via trigger/fallback mapping.
- **AC-005:** Automated verification commands must pass before Gate 4 (Implement → Test transition).
- **AC-006:** Session interruption recovery — new session reads `ACTIVE_CONTEXT.md` and resumes from the correct phase without redoing completed work.
- **AC-007:** Graceful handling when no manual test is applicable — spec notes reason, Test phase skips directly to `/finish-traceable`.
- **AC-008:** Fallback to `executing-plans` when subagents are unavailable in the Implement phase.
- **AC-009:** Stale project memory is detected during Discovery and triggers `building-codebase-memory` refresh before continuing.
- **AC-010:** When multiple specs match during Spec phase, agent asks user to choose rather than guessing.
- **AC-011:** Existing individual commands (`/context-start`, `/review-spec`, `/finish-traceable`, etc.) remain independently usable with no behavior changes.

## Non-Goals

- Replace or modify existing individual commands — they remain independently usable.
- Add bug fix workflow — that is a separate flow (`/debug-with-memory` + `/review-bug-fix`).
- Add third-party dependencies — core remains zero-dependency.
- Automate manual test execution — the workflow requests manual test and waits for human results.

## Architecture

### Skill: `feature-workflow`

`skills/feature-workflow/SKILL.md` defines a state machine with 5 phases. The skill is loaded by `/start-feature` or by the user saying "start feature workflow". Once loaded, the skill drives the agent through each phase automatically.

### Command: `/start-feature`

`commands/start-feature.md` — thin trigger. Fallback phrase: `Start feature workflow`. Required skill: `superpowers:feature-workflow`.

**Harness trigger mapping:**

| Harness | Trigger | Fallback |
|---------|---------|----------|
| OpenCode | `/start-feature` | `Start feature workflow` |
| Claude Code | `/start-feature` | `Start feature workflow` |
| Cursor | `/start-feature` | `Start feature workflow` |
| Codex | — | `Start feature workflow` (natural prompt) |
| Gemini CLI | `/start-feature` | `Start feature workflow` |
| GitHub Copilot CLI | — | `Start feature workflow` (natural prompt) |

Every harness loads the same `feature-workflow` skill. Harnesses without slash command support use the fallback phrase as a natural prompt.

### State Tracking

`ACTIVE_CONTEXT.md` stores:
- `current_phase`: one of `discovery`, `spec`, `plan`, `implement`, `test`
- `gate_status`: `pending`, `passed`, `failed`
- `spec_path`: path to the written spec (set after Spec phase)
- `plan_path`: path to the written plan (set after Plan phase)
- `manual_test_artifact_path`: path to manual test cases (set after Spec phase)

The skill reads and updates this file at each phase transition.

### Phase State Machine

```
discovery → spec → plan → implement → test
              ↑        ↑        ↑
           [gate]   [gate]   [gate]
```

Each gate blocks transition until the corresponding `traceability-review` passes with no open findings.

## Phase Definitions

### Phase 1: Discovery

**Trigger:** `/start-feature` or user says "start feature workflow"

**Actions:**
1. Invoke `project-memory` in start mode — read memory, check freshness
2. If foundational memory is missing/stale, delegate to `building-codebase-memory`
3. Invoke `context-traceability` in `brainstorm-preflight` mode — discover related specs, plans, code paths
4. Invoke `brainstorming` — ask clarifying questions one at a time, propose approaches, present design sections
5. Capture all requirements and design decisions (do NOT write the spec yet)
6. Ask user: "Requirements captured? Confirm to proceed to Spec phase."

**Gate 1:** User confirms requirements are captured. Agent transitions to Spec phase. The spec does NOT exist yet — Spec phase begins with `/write-spec` to create it.

### Phase 2: Spec

**Trigger:** Gate 1 passed

**Actions:**
1. Invoke `/write-spec` — finalize the approved design from Discovery into a spec document at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
2. `/write-spec` creates the manual test artifact at `docs/superpowers/manual-tests/YYYY-MM-DD-<topic>-manual-tests.md` when behavior is user-visible or manually verifiable
3. Update `SPEC_INDEX.md` with the new spec entry
4. Loop:
   - Run `/review-spec` → `traceability-review` in `spec-review` mode
   - If findings exist → run `/update-spec` → fix findings → repeat
   - If no open findings → Gate 2 passed

**Gate 2:** `traceability-review` spec-review passes with no open findings. Agent transitions to Plan phase.

### Phase 3: Plan

**Trigger:** Gate 2 passed

**Actions:**
1. Invoke `writing-plans` — create implementation plan at `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`
2. Include context packet from `context-traceability` in `planning-preflight` mode
3. Refine linked manual test artifact with test setup, prerequisites, task mappings
4. Loop:
   - Run `/review-plan` → `traceability-review` in `plan-review` mode
   - If findings exist → run `/plan-spec` → fix findings → repeat
   - If no open findings → Gate 3 passed

**Gate 3:** `traceability-review` plan-review passes with no open findings. Agent transitions to Implement phase.

### Phase 4: Implement

**Trigger:** Gate 3 passed

**Actions:**
1. Invoke `subagent-driven-development` (or `executing-plans` if subagents unavailable)
2. Read plan, spec, context packet, manual test artifact before executing
3. After implementation complete:
   - Run `/review-implementation` → `traceability-review` in `implementation-review` mode
   - If findings exist → fix → repeat review
   - If no open findings AND all automated tests pass → Gate 4 passed

**Gate 4:** `traceability-review` implementation-review passes with no open findings AND automated verification commands pass. Agent transitions to Test phase.

### Phase 5: Test

**Trigger:** Gate 4 passed

**Actions:**
1. Present manual test artifact with case budget, affected existing features, and current status
2. Request human partner to run manual tests
3. Await human-reported results
4. If failures found → determine root cause:
   - If code bug → fix → run `/review-implementation` → Gate 4 → re-request manual test
   - If spec/plan issue → back up to the appropriate phase (Spec or Plan) → fix → re-execute downstream phases → re-request manual test
5. If all pass → workflow complete. Human partner may invoke `/finish-traceable` as a separate workflow.

**End:** Workflow complete.

## Skill Content

`skills/feature-workflow/SKILL.md` must contain:

- **Phase definitions:** All 5 phases (Discovery, Spec, Plan, Implement, Test) with triggers, actions, and gate conditions as defined in the Phase Definitions section.
- **State machine:** Explicit state transitions between phases with gate enforcement rules.
- **State tracking:** Instructions to read and update `ACTIVE_CONTEXT.md` at each phase transition, including field names (`current_phase`, `gate_status`, `spec_path`, `plan_path`, `manual_test_artifact_path`).
- **Delegation rules:** Which existing skills to invoke at each phase (`project-memory`, `brainstorming`, `writing-plans`, `traceability-review`, `subagent-driven-development`, `executing-plans`, `context-traceability`). Test phase does not delegate to a skill — it presents manual test results and ends.
- **Gate enforcement:** Rules that block phase transition until the corresponding `traceability-review` passes with no open findings (except Gate 1 which is user confirmation).
- **Error handling:** Session interruption recovery, gate skip warnings, subagent fallback, no-manual-test handling, multiple-spec ambiguity.
- **Harness trigger mapping:** The fallback phrase table so the skill works across all harnesses.
- **Manual test presentation:** Instructions to present the manual test artifact and await human-reported results in Test phase.

The skill must not duplicate behavior from existing skills — it delegates to them. It is an orchestrator, not an implementation.

## Error Handling

- **User wants to skip a gate:** Agent warns about risk but allows if user explicitly confirms. Records warning in `ACTIVE_CONTEXT.md`.
- **Session interruption:** New session reads `ACTIVE_CONTEXT.md`, resumes from current phase. Agent announces: "Resuming from [phase] phase. Spec at [path], Plan at [path]."
- **Subagents unavailable:** Falls back to `executing-plans` in Implement phase.
- **No manual test applicable:** Spec includes `Manual test artifact: Not applicable` with reason. Test phase skips to `/finish-traceable`.
- **Review finds critical issue:** Agent blocks transition, presents findings, asks user how to proceed.

## Testing

### Automated
- Skill trigger test: verify "start feature workflow" prompt loads `feature-workflow` skill
- Phase transition test: verify state machine transitions correctly through all 5 phases
- Gate enforcement test: verify agent does not skip gates without explicit user confirmation
- Resume test: verify new session resumes from correct phase using `ACTIVE_CONTEXT.md`

### Manual
See `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md`

## Affected Existing Features

| Feature | Touched Code Paths | Why Affected | Manual Case IDs |
|---------|-------------------|--------------|-----------------|
| Existing individual commands | None — no modification | New skill references existing commands but does not change them | MTC-01 |
| `using-superpowers` skill | None — no modification | May optionally add routing hint in future, not in scope | MTC-02 |
| `ACTIVE_CONTEXT.md` | `docs/project-memory/ACTIVE_CONTEXT.md` | New fields added for phase tracking | MTC-03 |
