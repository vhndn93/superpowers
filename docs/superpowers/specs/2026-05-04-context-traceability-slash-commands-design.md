# Context Traceability Slash Commands Design

## Problem

Superpowers' Basic Workflow gives strong phase discipline: brainstorm, write a spec, write a plan, implement, review, and finish. In a long-lived project, that is not enough by itself. New conversations and subagents can start without durable project context, specs can miss related decisions, plans can drift from specs, implementations can satisfy local tasks while missing edge cases, and bug fixes can fail to update the source-of-truth spec or memory.

The goal is to add a lightweight workflow layer that makes every phase traceable back to project memory, related specs, accepted plans, code, tests, and bug learnings while keeping the user's prompts short.

## Goals

- Let the user drive the workflow with short slash commands instead of long procedural prompts.
- Add durable project memory as a first-class workflow input.
- Add explicit related-spec discovery before brainstorming, planning, implementation, and debugging.
- Add independent review commands for specs, plans, implementations, bug fixes, memory, and full traceability.
- Add a separate manual test artifact that the human partner can run after implementation, linked from spec and plan so manual QA stays traceable.
- Make spec, plan, code, test, and memory drift visible before work is considered complete.
- Keep third-party memory systems optional. The file-based workflow must work without `claude-mem`.

## Non-Goals

- Do not integrate `claude-mem` into Superpowers core.
- Do not replace `brainstorming`, `writing-plans`, `subagent-driven-development`, `executing-plans`, `systematic-debugging`, or `verification-before-completion`.
- Do not add a database, vector store, MCP server, or external dependency.
- Do not submit this as an upstream PR without separate eval evidence and duplicate-PR review.

## User-Facing Workflow

The user should be able to run the full workflow with concise commands. These commands are shortcuts into existing Superpowers workflows plus the new traceability support layer. They are not parallel replacements for the existing skills.

```text
/context-start
/brainstorm-feature <idea>
/write-spec
/review-spec <spec path>
/plan-spec <spec path>
/review-plan <plan path>
/implement-plan <plan path>
/review-implementation
/debug-with-memory <bug summary>
/review-bug-fix <bug summary>
/update-spec <change summary>
/record-learning <lesson>
/review-memory
/review-traceability [target]
/finish-traceable
```

The most common path is:

```text
/context-start
/brainstorm-feature <idea>
/write-spec
/plan-spec <spec path>
/implement-plan <plan path>
/review-implementation
/finish-traceable
```

Review commands are intentionally callable at any time. They are not only internal gates.

## Command Principles

- Existing Superpowers skills remain the workflow source of truth.
- Slash commands are thin entrypoints, aliases, or mode selectors.
- New skills provide shared support behavior that existing skills and slash commands can both call.
- A slash command must not duplicate the full process of an existing skill. It should invoke that skill and add only the requested mode/context.
- Structural process/checklist changes belong inside the existing skills they affect, not only inside command prose.

## Harness Command Surface

Different harnesses expose commands differently. The design uses slash-command names as the canonical user-facing vocabulary, but implementation must map them per harness:

| Harness | Preferred surface | Fallback surface | Notes |
| --- | --- | --- | --- |
| Claude Code | `commands/*.md` slash commands | Skill names in natural language | Native slash commands are expected. |
| Cursor | `commands/*.md` or Cursor-supported command files where available | Skill names in natural language | Must match the currently supported Cursor plugin command surface. |
| OpenCode | Slash commands where supported by the plugin layout | Skill names in natural language | Keep parity with existing OpenCode docs and tests. |
| Gemini CLI | Gemini namespaced slash commands if supported | Skill names in natural language | Command names may need namespace rewriting. |
| Codex | Skills or command-like skill aliases | Natural prompts such as `Brainstorm feature: <idea>` | Codex may not execute `commands/*.md` as slash commands in all installs, so every slash command needs an equivalent skill trigger phrase. |
| GitHub Copilot CLI | Copilot command surface where supported | Skill names in natural language | Keep the command vocabulary, but do not assume Claude Code command mechanics. |

Each command implementation must document its fallback phrase. For example, `/brainstorm-feature <idea>` maps to `Brainstorm feature: <idea>` when the harness does not support slash commands.

## Architecture

Add four support skills:

- `project-memory`: reads, summarizes, routes, records, and reviews durable project memory during the workflow.
- `building-codebase-memory`: creates or deeply refreshes foundational codebase memory when architecture, structure, conventions, testing, integrations, or concerns are missing or stale.
- `context-traceability`: discovers related specs/plans/code, builds context packets, and defines phase gates.
- `traceability-review`: independently reviews specs, plans, implementations, bug fixes, memory, or the full chain.

Add command files or command-equivalent skill aliases that route user intent to existing Superpowers workflow skills. Commands should stay thin. Detailed behavior lives in skills so it can be reused by multiple commands and existing workflow gates.

## PR Inspiration Coverage

This design intentionally uses the PR research as design input, not as code or behavior to copy wholesale. The workflow should combine the useful ideas into one coherent traceability layer:

| Inspiration | What to learn from it | Spec coverage |
| --- | --- | --- |
| `#880` memory artifacts | Keep durable, file-based context that survives new conversations and does not require an external memory service. | `docs/project-memory/`, minimum memory pack, `SPEC_INDEX.md`, `BUG_PATTERNS.md`, `/context-start`, `/review-memory`, `/record-learning`. |
| `#1113` feature context | Capture feature/domain knowledge that future specs, plans, and subagents must understand before making decisions. | `FEATURE_CONTEXT.md`, feature context in command state, `/brainstorm-feature`, `/write-spec`, `/review-spec`, `/review-implementation`. |
| `#1129` context injection | Inject the right bounded context into agents instead of assuming they share the coordinator's conversation memory. | `Context Packet And Injection`, subagent injection rules, `/plan-spec`, `/implement-plan`, `subagent-driven-development`, `executing-plans`. |
| `#334` document review | Treat specs and plans as reviewable artifacts, with explicit findings and fix contracts. | `traceability-review`, `Review Report Contract`, `/review-spec`, `/review-plan`, `/review-traceability`. |
| `#622` plan pressure-test | Simulate plan execution before implementation to catch ordering, missing discovery, and unverified acceptance criteria. | Plan pressure-test in `/plan-spec`, `/review-plan`, `traceability-review`, eval scenario 12. |
| `#1145` debug evidence trail | Debug from evidence and root cause, then preserve reusable lessons so the same failure is less likely to recur. | `/debug-with-memory`, `/review-bug-fix`, `BUG_PATTERNS.md`, `systematic-debugging` integration, eval scenario 8. |

The resulting implementation should feel like one extension to Basic Workflow: memory gives the project baseline, feature context gives durable domain meaning, context packets brief humans/subagents, document review checks specs and plans, pressure-testing checks executable plan quality, and debug evidence turns incidents into reusable project knowledge.

The core mapping is:

| Command | Primary skill authority | Support skill/mode |
| --- | --- | --- |
| `/context-start` | `project-memory` | `building-codebase-memory` when foundational memory is missing/stale; `context-traceability` discovery when a task summary is present |
| `/brainstorm-feature` | `brainstorming` | `context-traceability brainstorm-preflight` |
| `/write-spec` | `brainstorming` Documentation phase | `traceability-review spec-review` |
| `/plan-spec` | `writing-plans` | `context-traceability planning-preflight`, `traceability-review plan-review`, plan pressure-test |
| `/implement-plan` | `subagent-driven-development` or `executing-plans` | `context-traceability implementation-context` |
| `/debug-with-memory` | `systematic-debugging` | `context-traceability debug-preflight`, `project-memory bug-patterns` |
| `/review-*` | `traceability-review` | Reads project memory and related artifacts as needed |
| `/update-spec` | `context-traceability spec-update` | `traceability-review spec-review` |
| `/record-learning` | `project-memory record` | Optional `context-traceability` links |
| `/finish-traceable` | `verification-before-completion`, then `finishing-a-development-branch` | `traceability-review full`, `project-memory refresh` |

This mapping is deliberately conservative:

- Do not create `brainstorm-feature` as a new workflow that competes with `brainstorming`; upgrade `brainstorming` and expose the command as a shorter entrypoint.
- Do not create `plan-spec` as a new workflow that competes with `writing-plans`; upgrade `writing-plans` with traceability preflight and review gates.
- Do not create `implement-plan` as a new workflow that competes with `executing-plans` or `subagent-driven-development`; route to the existing execution skill based on harness capability and task shape.
- Do not create `debug-with-memory` as a new workflow that competes with `systematic-debugging`; upgrade debugging with memory, spec, and bug-pattern context.
- Do not treat `review-bug-fix` as a replacement for `verification-before-completion`; it is a specialized review mode that can be called directly or from final verification when the active work is a bug fix.

The file-based memory surface is:

```text
docs/project-memory/
  STACK.md
  ARCHITECTURE.md
  STRUCTURE.md
  CONVENTIONS.md
  TESTING.md
  INTEGRATIONS.md
  CONCERNS.md
  FEATURE_CONTEXT.md
  BUG_PATTERNS.md
  SPEC_INDEX.md
```

`SPEC_INDEX.md` is the fast lookup table for feature/module/spec/plan relationships. It should not replace reading the actual spec. It is a routing index.

`FEATURE_CONTEXT.md` captures domain and feature knowledge that does not belong cleanly in architecture or conventions: terminology, business rules, invariants, user-facing concepts, repeated corrections from the human partner, and feature-specific constraints that future sessions or subagents must not rediscover from scratch.

## Manual Test Artifact

Manual test cases are a separate traceable artifact, not a replacement for automated tests or verification commands.

Use this path pattern:

```text
docs/superpowers/manual-tests/YYYY-MM-DD-<feature>-manual-tests.md
```

The artifact is created in the spec phase when the feature has user-visible or manually verifiable behavior. It is refined in the plan phase after code paths, setup, test data, migrations, config, and implementation risks are better understood. The finish phase reports the artifact path and manual QA status, but must not claim the human partner has run the cases unless the human partner explicitly says so.

Manual test artifacts should use the smallest useful set, not an exhaustive QA matrix. A normal feature should default to 8-12 manual cases split across these sections:

| Feature size or risk | Total cases | Section budget |
| --- | ---: | --- |
| Small, low-risk change | 4-6 | 1-2 happy path, 1 negative/error, 1 edge/risk, 1-2 regression/affected-feature |
| Normal feature | 8-12 | 2-3 happy path, 2-3 negative/error, 2-3 edge/risk, 2-3 regression/affected-feature |
| Large or high-risk feature | 12-18 | 3-5 happy path, 3-4 negative/error, 3-4 edge/risk, 3-5 regression/affected-feature |
| Bug fix | 3-6 | 1 expected behavior, 0-1 negative/error, 1-2 edge/risk, 1-2 regression |
| Internal refactor | 0-3 | Only create cases for behavior that is meaningfully human-verifiable |

Use these sections in the artifact:

```markdown
## Happy Path

## Negative / Error Path

## Edge Case / Risk

## Regression / Affected Existing Features
```

The regression section must explicitly cover existing features affected by the new work. During spec writing, identify likely affected existing features from related specs, feature context, and shared user-facing flows. During planning, refine this with inspected code paths.

Add an affected-feature map before the regression cases:

```markdown
## Affected Existing Features

- Feature: <name>
  Code paths touched:
  - `path/to/file`
  Why affected:
  - Shared component / state / API / config / workflow
  Manual coverage:
  - TC-009
  - TC-010
```

Each manual test case should use this shape:

```markdown
### TC-001: <behavior>

Type: happy path | negative/error path | edge/risk | regression/affected-feature
Priority: P0 | P1 | P2
Related acceptance criteria: AC-001
Related spec: <path>
Related plan tasks: <path or pending until plan exists>

Preconditions:
- ...

Steps:
1. ...

Expected:
- ...

Cleanup:
- ...

Status:
- Not run
```

Allowed statuses are:

- `Not run`: default status created by the agent.
- `Blocked`: the human partner reports the case cannot be run yet; include the blocking reason.
- `Passed by human`: only after the human partner reports the case passed.
- `Failed by human`: only after the human partner reports the case failed; include observed behavior and follow-up target when known.

Agents may create and refine manual test cases, but they must not mark a case as passed, failed, or blocked without human-reported evidence.

Spec and plan files should link to the manual test artifact instead of embedding long manual QA scripts. The artifact should map cases back to acceptance criteria and, once a plan exists, to plan tasks. If a spec has no meaningful manual verification surface, it should say "Manual test artifact: Not applicable" with a short reason.

## Command State Model

Commands must not depend only on fragile conversation memory. They should persist enough state for a new conversation to resume safely.

State lives in:

- `docs/project-memory/SPEC_INDEX.md`: feature/module/spec/plan relationships, current status, related artifacts, and last known implementation state.
- `docs/project-memory/FEATURE_CONTEXT.md`: durable domain terms, invariants, and feature rules that affect interpretation of specs and implementation choices.
- Spec frontmatter or top metadata section: title, status, related specs, related plans, owning command, and last review date.
- Spec top metadata or QA section: manual test artifact path, or an explicit "not applicable" reason.
- Plan frontmatter or top metadata section: referenced spec, status, context packet location, related specs, verification commands, and manual test artifact path.
- Optional `docs/project-memory/ACTIVE_CONTEXT.md`: a small pointer file for the current active spec/plan/branch when the user wants command defaults. This file should contain only pointers and status, not large summaries.

If a command cannot resolve the active spec, plan, or brainstorm from persisted state, it asks the user to choose rather than guessing.

`/write-spec` has a special handoff rule:

- If the normal `brainstorming` flow runs continuously through user approval, it may write the spec itself as it does today.
- If the user wants a shorter command-driven flow, `/brainstorm-feature` stops after an approved design and records an "approved design pending spec" handoff in the current conversation and, where possible, `ACTIVE_CONTEXT.md`.
- `/write-spec` is only for finalizing that pending approved design. It must not duplicate a spec already written by `brainstorming`.

## Project Memory Policy

For the minimal-prompt goal, project memory should be active rather than passive:

- If `docs/project-memory/` is missing in an existing codebase, `/context-start` invokes `project-memory`, which delegates foundational memory creation to `building-codebase-memory` before continuing into feature work.
- The minimum pack is `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`, `FEATURE_CONTEXT.md`, and `SPEC_INDEX.md`.
- If foundational memory exists but appears stale against obvious repo facts, `project-memory` decides whether the stale area is narrow enough to summarize directly or should be delegated to `building-codebase-memory`.
- If refresh would require broad archaeology or many unrelated files, `project-memory` summarizes the stale areas and asks for approval before invoking `building-codebase-memory` for a larger refresh.
- Feature, plan, implementation, and debug commands may proceed with partial memory only if they explicitly state which memory docs are missing or untrusted.

`FEATURE_CONTEXT.md` should be updated when the human partner corrects terminology, business rules, user-facing interpretation, or domain invariants more than once, or when a spec introduces a durable feature concept that future specs/plans must understand.

### Foundational vs Workflow Memory

`building-codebase-memory` owns foundational codebase memory:

- `STACK.md`
- `ARCHITECTURE.md`
- `STRUCTURE.md`
- `CONVENTIONS.md`
- `TESTING.md`
- `INTEGRATIONS.md`
- `CONCERNS.md`

`project-memory` owns workflow memory and routing:

- `FEATURE_CONTEXT.md`
- `BUG_PATTERNS.md`
- `SPEC_INDEX.md`
- `ACTIVE_CONTEXT.md`
- compact context summaries
- memory review reports
- record-learning updates
- next-command handoff

`project-memory` should not duplicate deep codebase mapping. When foundational docs are missing, stale, incomplete, or inconsistent with code, it invokes `building-codebase-memory` and then uses that skill's trust-level handoff.

## Context Packet And Injection

`context-traceability` owns a concise context packet format used before planning, implementation, subagent dispatch, debug work, and traceability review.

A context packet contains:

- task or feature summary
- relevant project-memory excerpts
- related specs and plans
- feature context: terms, invariants, user-facing concepts, and durable business rules
- acceptance criteria mapped from the active spec
- likely edge cases and negative cases
- relevant code paths inspected or needing inspection
- test obligations and verification commands
- manual test artifact path, case budget, affected existing features, touched code paths, and cases that require human/device/account/data verification
- known risks, open questions, and untrusted/missing context

The packet must be small enough to paste into a subagent prompt. It is not a dump of entire specs or memory files. It should include paths so the worker can read full artifacts when needed.

Subagent injection rules:

- Before dispatching implementer, reviewer, debugger, or explorer subagents, the coordinator must include the context packet in the prompt.
- The prompt must name related specs and project-memory files that the subagent must read before editing or judging.
- If a domain context provider or memory search tool is available, the coordinator may query it before building the packet, but file-based project memory remains the source of truth.
- If no context packet can be built, the coordinator must say why and ask whether to proceed with partial context.

## Review Report Contract

All review commands must use a shared report shape:

```text
Blocking findings
- [severity] [artifact/path] Problem. Evidence. Required action.

Non-blocking concerns
- [severity] [artifact/path] Concern. Evidence. Suggested action.

Missing updates
- Spec/plan/memory/test/manual-test update needed, with target file.

Recommended next command
- One command, such as /update-spec, /review-plan, /implement-plan, or /finish-traceable.
```

Review commands may read freely. They may only edit specs, plans, code, or memory after explicit user approval, except when they are running as an internal self-review step inside a command that already owns writing that artifact, such as `/write-spec` or `/plan-spec`.

## Command Behavior

### `/context-start [task summary]`

Starts a conversation with durable context.

1. Invoke `project-memory`.
2. Read `docs/project-memory/` if present.
3. If foundational codebase memory is missing in an existing codebase, invoke `building-codebase-memory` to create the foundational pack before continuing.
4. If foundational memory is stale, use `project-memory` to classify whether the stale area is narrow, partial, or broad; invoke `building-codebase-memory` for substantive refreshes.
5. Read `docs/project-memory/SPEC_INDEX.md` if present.
6. If `[task summary]` is present, discover related specs, plans, and likely code areas.
7. If a memory search tool such as `claude-mem` is available, optionally search prior sessions for `[task summary]`.
8. Output relevant project context, related specs/plans, likely code areas, memory trust level, open questions, and the recommended next command.

This command must not implement or edit code unless the user explicitly asks for implementation.

### `/brainstorm-feature <idea>`

Starts memory-aware brainstorming.

1. Invoke `brainstorming`.
2. Invoke `context-traceability` in `brainstorm-preflight` mode.
3. Load project memory.
4. Discover related specs, plans, and code areas for `<idea>`.
5. Summarize prior decisions, feature context, domain terms, and constraints.
6. Ask one clarifying question at a time.
7. Before design presentation, call out assumptions, unknowns, related specs, likely edge cases, and user-facing surface when applicable.
8. Present two or three approaches with tradeoffs and a recommendation.
9. Follow the normal `brainstorming` approval flow.
10. If the user asks for command-driven finalization, stop after approval and leave an approved-design handoff for `/write-spec`. Otherwise, let `brainstorming` continue to its existing Documentation phase and write the spec.

### `/write-spec [title or current brainstorm]`

Writes an approved brainstorm into a spec.

1. Confirm there is an approved design pending spec finalization.
2. If no approved design exists, stop and ask the user to run `/brainstorm-feature` or continue the existing `brainstorming` flow.
3. If a spec was already written by `brainstorming`, do not write another one; offer `/review-spec <spec path>` instead.
4. Write the spec to `docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md`.
5. If the feature has user-visible or manually verifiable behavior, create `docs/superpowers/manual-tests/YYYY-MM-DD-<slug>-manual-tests.md` from acceptance criteria, user flows, edge cases, negative cases, related specs, feature context, and likely affected existing features.
6. Link the manual test artifact from the spec. If manual testing is not applicable, record the reason in the spec.
7. Invoke `traceability-review` in `spec-review` mode.
8. Verify the spec and manual test artifact against the discussion, approved design, related specs, project memory, feature context, assumptions, unknowns, likely edge cases, target case budget, required sections, and likely affected existing features.
9. Fix review issues inline because `/write-spec` owns this artifact creation.
10. Add or update a draft `SPEC_INDEX.md` entry, or explicitly note why index update is pending.
11. Output the spec path, manual test path when present, and ask the user to review them.

This command must not write the implementation plan.

### `/review-spec <spec path>`

Reviews a spec independently.

1. Read `<spec path>`.
2. Read project memory and `SPEC_INDEX.md`.
3. Discover related specs and plans.
4. Review for mismatch with current discussion when available, missing requirements, vague acceptance criteria, unhandled edge cases, hidden assumptions, conflicts with related specs, missing user-facing surface, missing feature-context updates, missing or stale manual test artifact link, missing required manual test sections, under- or over-sized manual test budget, missing affected-existing-feature coverage, and testability.
5. Output findings by severity.
6. If the user asks to fix, update the spec and re-run the review.

### `/plan-spec <spec path>`

Creates a traceable implementation plan.

1. Invoke `writing-plans`.
2. Invoke `context-traceability` in `planning-preflight` mode.
3. Read the approved spec.
4. Read project memory.
5. Read related specs and plans.
6. Inspect relevant code files.
7. Build a concise implementation context packet in the plan or an adjacent section.
8. Read the spec-linked manual test artifact when present, refine it with implementation setup, data/device/account prerequisites, plan task mappings, affected code paths, affected existing features, regression risks, and any newly discovered edge cases.
9. Write the plan to `docs/superpowers/plans/YYYY-MM-DD-<slug>.md`.
10. Link the manual test artifact from the plan. If no manual test artifact applies, include the same "not applicable" reason as the spec.
11. Invoke `traceability-review` in `plan-review` mode.
12. Pressure-test the plan by simulating execution against the spec, related specs, context packet, manual test artifact, codebase structure, likely edge cases, affected code paths, and affected existing features.
13. Fix review and pressure-test issues before asking user approval.

The plan must include exact files likely to change, task sequence, tests per task, acceptance criteria mapped back to the spec, edge cases, context packet, manual test artifact path, affected existing features/code paths, and verification commands.

### `/review-plan <plan path>`

Reviews an implementation plan independently.

1. Read the plan.
2. Resolve and read the referenced spec.
3. Read project memory and related specs.
4. Inspect relevant code paths named by the plan.
5. Read the manual test artifact linked by the spec or plan when present.
6. Review for spec coverage, missing code areas, missing tests, missing manual test coverage for human-verifiable behavior, missing affected-existing-feature coverage, task size and ordering problems, unclear acceptance criteria, missing migrations/config/docs, edge cases, missing context packet inputs, and risk of behavior outside the spec.
7. Pressure-test execution by asking whether each task can be completed from the given context, whether task dependencies are ordered correctly, whether any task writes before required discovery, whether affected existing features and touched shared code paths have regression coverage, whether any acceptance criterion lacks automated verification or manual test coverage, and whether manual test setup is clear enough for the human partner.
8. Output findings by severity.
9. If the user asks to fix, update the plan and re-run the review.

### `/implement-plan <plan path>`

Implements an approved plan.

1. Invoke `subagent-driven-development` when available and appropriate; otherwise invoke `executing-plans`.
2. Ensure an isolated worktree if the workflow requires it.
3. Read the plan, referenced spec, implementation context packet, linked manual test artifact when present, related specs, feature context, and relevant code files.
4. Execute task by task.
5. For each task, use TDD where possible, verify red/green evidence, verify the task against plan acceptance criteria, verify behavior against the spec, feature context, and manual test expectations, and commit a small unit when the active workflow calls for commits.
6. After all tasks, invoke or recommend `/review-implementation`.

### `/review-implementation [spec or plan path]`

Verifies code against plan and spec.

1. Inspect the current git diff.
2. Resolve the active plan and spec from the argument, latest plan, branch context, or explicit user choice.
3. Read project memory, feature context, and related specs.
4. Read the linked manual test artifact when present.
5. Review whether every plan task is complete, every spec acceptance criterion is satisfied, feature-context invariants still hold, tests cover expected edge cases, manual tests still match the implemented user-facing behavior, behavior has not drifted beyond the spec, unrelated changes are absent, and docs/spec/memory/manual-test updates are needed.
6. Output findings by severity.
7. Recommend whether to fix code, update spec, update plan, update manual tests, update memory, or proceed to finish.

### `/debug-with-memory <bug summary>`

Debugs with durable context.

1. Invoke `systematic-debugging`.
2. Invoke `context-traceability` in `debug-preflight` mode.
3. Read project memory, `FEATURE_CONTEXT.md`, and `BUG_PATTERNS.md`.
4. Find related specs, plans, and code.
5. Establish expected behavior from the spec.
6. Track observations, hypotheses, experiments, evidence, and root cause.
7. Fix only after root cause is identified.
8. Run verification after the fix.
9. If behavior changed, prompt to update the spec.
10. If the bug pattern is reusable, update `BUG_PATTERNS.md`.

### `/review-bug-fix <bug summary>`

Verifies that a bug fix addresses root cause rather than symptoms.

1. Read the current diff.
2. Read the related spec and plan.
3. Read `BUG_PATTERNS.md`.
4. Read the linked manual test artifact when present.
5. Review whether root cause evidence exists, the fix addresses root cause, an automated regression test exists when feasible, a manual regression case was added or updated when the bug is human-verifiable, no new edge case was introduced, the spec was updated if behavior changed, and the bug pattern was recorded if repeatable.
6. Output findings and required follow-up.

### `/update-spec <change summary>`

Changes behavior through the spec first.

1. Find the most relevant spec via `SPEC_INDEX.md`, filenames, and content search.
2. If multiple candidates exist, ask the user to choose.
3. Read related plan and code if needed.
4. Update the spec with changed requirement, rationale, affected acceptance criteria, affected edge cases, compatibility notes, and manual QA impact.
5. Update the linked manual test artifact when the changed behavior affects human-verifiable flows, setup, expected results, negative cases, or regression cases.
6. Update affected plan sections if a plan exists.
7. Run `/review-spec` on the updated spec.
8. Do not implement until the user approves.

### `/review-memory`

Audits project memory freshness.

1. Read all `docs/project-memory/*.md`.
2. Compare memory against current repo structure and recent specs/plans.
3. Check for stale architecture, missing conventions, missing integrations, missing testing guidance, missing bug patterns, and stale `SPEC_INDEX.md`.
4. Output proposed updates.
5. If the user approves, update memory docs.

### `/record-learning <lesson>`

Captures a durable learning.

1. Classify the lesson as bug pattern, feature context, architecture decision, convention, testing lesson, integration caveat, or spec relationship.
2. Update the appropriate memory file.
3. Link related spec, plan, or code when possible.
4. Keep the entry concise and operational.
5. If the lesson affects future workflow, suggest whether a skill update is needed.

### `/review-traceability [target]`

Runs the general traceability review.

1. Determine whether the target is a spec path, plan path, current diff, bug fix, or latest active work.
2. Run the relevant review modes: spec-review, plan-review, implementation-review, and memory-review. Include bug-fix-review when the target is a bug fix or when the active diff is bug-fix work.
3. Check the full chain: discussion/context, project memory, feature context, related specs, plan, manual test artifact and manual QA status, code, automated tests, and bug patterns.
4. Output blocking findings, non-blocking concerns, missing updates, and the recommended next command.

### `/finish-traceable`

Finishes work with memory and spec hygiene.

1. Invoke `verification-before-completion`.
2. Run `/review-traceability`.
3. Run the required tests and verification commands.
4. Resolve the linked manual test artifact, report its path, and mark it as ready for human manual QA. Do not mark cases passed unless the human partner explicitly reports results.
5. Call out manual cases that require device, account, data, permission, or environment setup.
6. Update `SPEC_INDEX.md`.
7. Update project memory if architecture, conventions, testing, or integrations changed.
8. Update `BUG_PATTERNS.md` if applicable.
9. Summarize specs changed, plans changed, manual tests changed, code changed, automated tests run, manual tests requiring human execution, and remaining risks.
10. Invoke `finishing-a-development-branch`.

## Skill Responsibilities

### `project-memory`

Owns workflow-level use of `docs/project-memory/`: reading, summarizing, routing, record-learning updates, memory review, and next-command handoff.

It should distinguish authoritative, partial, and untrusted memory. It should avoid pretending memory is authoritative when code disagrees. It owns `FEATURE_CONTEXT.md`, `BUG_PATTERNS.md`, `SPEC_INDEX.md`, and `ACTIVE_CONTEXT.md`.

When foundational codebase memory is missing, stale, incomplete, or inconsistent with code, it delegates to `building-codebase-memory` rather than duplicating deep codebase mapping.

### `building-codebase-memory`

Owns deep creation and refresh of foundational codebase memory.

It should inspect relevant codebase areas, create or refresh only the needed foundational docs, distinguish observed facts from likely inferences and open questions, and return a trust-level handoff that `project-memory`, `brainstorming`, and `writing-plans` can use.

### `context-traceability`

Owns related-context discovery and phase gates.

It should build context packets, inject them into subagent prompts, map spec requirements to plan tasks, map plan tasks to implementation evidence, carry manual test artifact paths through the workflow, carry case budget, required manual test sections, affected existing features, and touched shared code paths, and flag missing updates to specs, plans, manual tests, or memory.

### `traceability-review`

Owns independent review.

It should lead with findings by severity. It should be callable by commands and by existing workflow gates. Spec, plan, implementation, bug-fix, and finish reviews include manual test artifact coverage when the work has human-verifiable behavior. Reviews must check case budget, required manual test sections, affected existing features, touched shared code paths, manual QA status, and missing manual regression coverage. Plan review includes pressure-testing the task sequence against the spec, context packet, manual test artifact, codebase structure, and edge cases.

## Existing Skill Integration

Keep integrations small and structural:

- `using-superpowers`: route existing-codebase work toward `project-memory` and feature/plan/debug/implementation work toward `context-traceability`.
- `brainstorming`: call `project-memory` first; let it invoke `building-codebase-memory` for missing/stale foundational docs; then call context discovery before detailed questions, create/link a manual test artifact during spec writing when applicable, and run spec review before presenting the final spec.
- `writing-plans`: require `project-memory`; let it invoke `building-codebase-memory` for missing/stale foundational docs; then require planning preflight, context packet creation, manual test artifact refinement, plan trace review, and plan pressure-test.
- `subagent-driven-development` and `executing-plans`: inject context packets, feature context, and related specs into implementer prompts.
- `systematic-debugging`: preserve observations/hypotheses/experiments/evidence, then update spec and bug memory after fixes when behavior changes or a reusable pattern appears.
- `verification-before-completion`: require traceability evidence before completion and report the manual test artifact path as ready for human QA when applicable, without claiming it was run by the agent.

The structural checklist or process flow must mention these gates directly. Do not hide them in trailing prose sections, because agents skip non-structural integration notes.

## Optional `claude-mem` Adapter

If `claude-mem` is installed and exposes usable search or transcript context, the workflow may search it during:

- `/context-start`
- `/brainstorm-feature`
- `/plan-spec`
- `/debug-with-memory`
- `/review-traceability`

The command must degrade gracefully when `claude-mem` is absent. File-based project memory remains the source of truth.

## Error Handling

- If project memory is missing, `/context-start` creates the minimum memory pack before continuing when the task depends on existing codebase understanding.
- If project memory refresh would be broad or risky, the command proposes the refresh and asks for approval.
- If multiple related specs match, ask the user to choose instead of guessing.
- If discussion context is unavailable during review, say so and review against available artifacts.
- If code and spec disagree, do not silently choose. Recommend either fixing code or updating spec.
- If the target path is missing, stop with a clear message and suggest the nearest matching specs/plans.

## Testing And Evaluation

This changes behavior-shaping content, so implementation must use `writing-skills` and include pressure tests.

Minimum eval scenarios:

1. New conversation starts with `/context-start` and summarizes project memory without editing code.
2. `/brainstorm-feature` discovers a related spec before asking detailed questions.
3. `/write-spec` refuses to write without an approved design.
4. `/review-spec` catches missing edge cases and vague acceptance criteria.
5. `/plan-spec` reads relevant code before writing tasks.
6. `/review-plan` catches a plan task that does not map to any spec requirement.
7. `/review-implementation` catches code behavior that exceeds the approved spec.
8. `/debug-with-memory` records root cause evidence and updates `BUG_PATTERNS.md` for a reusable issue.
9. Commands degrade gracefully when `claude-mem` is not installed.
10. `/brainstorm-feature` records durable terminology or invariants in `FEATURE_CONTEXT.md` when the feature introduces reusable domain context.
11. `/implement-plan` injects a context packet into subagent prompts before dispatch.
12. `/review-plan` catches an execution-order problem through pressure-testing, even when the plan superficially covers all spec requirements.
13. `/context-start` delegates to `building-codebase-memory` when foundational codebase memory is missing or stale, then returns to `project-memory` for summary and next-command handoff.
14. `project-memory` records a lesson in `FEATURE_CONTEXT.md` or `BUG_PATTERNS.md` without invoking `building-codebase-memory`.
15. `building-codebase-memory` produces a trust-level handoff that identifies authoritative, partial, and still-unverified memory docs.
16. `/write-spec` creates and links a manual test artifact for a user-visible feature, with cases mapped to acceptance criteria.
17. `/plan-spec` refines the linked manual test artifact with setup, task mappings, regression cases, and human-run prerequisites.
18. `/finish-traceable` reports automated verification separately from manual QA and does not mark manual test cases passed without human-reported results.
19. Manual test artifact generation uses the feature-size budget and required sections, including regression coverage for affected existing features and touched shared code paths.

## Scope Check

This is one cohesive workflow addition: concise user commands backed by project memory, traceability gates, and review modes. It is large enough to need a multi-step implementation plan, but it does not require splitting into unrelated PRs inside this fork.

If upstreaming later, split into smaller candidates:

1. `project-memory` only.
2. `building-codebase-memory` rename and delegation only.
3. `traceability-review` only.
4. Optional lifecycle hooks or context provider conventions.
