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
- If `current_phase` is set and `gate_status` is `passed`, announce: "Resuming from [phase] phase. Spec at [path], Plan at [path]." Resume from the next phase after the last passed gate.
- If `gate_status` is `pending`, resume from the current phase.
- If `gate_status` is `failed`, resume from the current phase to retry the review that produced the failure.
- If `ACTIVE_CONTEXT.md` is missing or has no phase data, start from Discovery.

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
