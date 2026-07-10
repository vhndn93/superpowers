# Context Traceability Slash Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fork-first, dependency-free traceability workflow that gives Superpowers durable project memory, related-context gates, review modes, and concise command entrypoints.

**Architecture:** Keep existing workflow skills as the source of truth, add three support skills, and expose thin command files that route to those skills. Store durable context in Markdown files under `docs/project-memory/`, and keep `claude-mem` as an optional adapter idea rather than a core dependency.

**Tech Stack:** Markdown skills, Markdown command files, shell-based static checks, existing Claude/OpenCode integration tests.

**Project Memory:** `docs/project-memory/ARCHITECTURE.md`, `docs/project-memory/CONVENTIONS.md`, `docs/project-memory/TESTING.md`, `docs/project-memory/CONCERNS.md`, `docs/project-memory/STRUCTURE.md`, `docs/project-memory/INTEGRATIONS.md`, `docs/project-memory/STACK.md`.

---

## Implementation Context Packet

**Active spec:** `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`

**Related source files inspected:**
- `skills/using-superpowers/SKILL.md`
- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`
- `skills/subagent-driven-development/SKILL.md`
- `skills/subagent-driven-development/implementer-prompt.md`
- `skills/subagent-driven-development/spec-reviewer-prompt.md`
- `skills/executing-plans/SKILL.md`
- `skills/systematic-debugging/SKILL.md`
- `skills/verification-before-completion/SKILL.md`
- `skills/finishing-a-development-branch/SKILL.md`
- `commands/brainstorm.md`
- `commands/write-plan.md`
- `commands/execute-plan.md`
- `tests/skill-triggering/run-test.sh`
- `tests/explicit-skill-requests/run-test.sh`
- `tests/claude-code/test-document-review-system.sh`

**Acceptance criteria mapped from spec:**
- Durable file memory exists and includes `FEATURE_CONTEXT.md`, `BUG_PATTERNS.md`, and `SPEC_INDEX.md`.
- New support skills exist: `project-memory`, `context-traceability`, and `traceability-review`.
- Existing skills call the support layer structurally, not only in trailing prose.
- Slash-command files or command-equivalent entrypoints exist for every command in the spec.
- Commands document fallback phrases for harnesses without native slash commands.
- Planning and implementation include a context packet and subagent injection rules.
- Review commands use the shared report contract and do not edit artifacts without approval, except internal self-review gates.
- Debugging preserves evidence and can update bug memory after root cause.
- `claude-mem` remains optional and absent-safe.
- Tests or eval scaffolding cover the minimum scenarios listed in the spec.

**Likely edge cases:**
- A harness reads `commands/*.md` but the command name conflicts with deprecated existing command behavior.
- A new conversation has no `ACTIVE_CONTEXT.md`; commands must resolve from explicit path or ask.
- `docs/project-memory/` exists but new memory files are missing.
- Multiple specs match a command target.
- A subagent receives a plan without the context packet.
- A bug fix changes behavior but no spec update is made.
- `claude-mem` is not installed.
- Upstream contribution rules reject third-party dependency or fork-specific behavior.

**Verification commands:**
- `bash tests/context-traceability/run-static-checks.sh`
- `bash tests/skill-triggering/run-test.sh context-traceability tests/skill-triggering/prompts/context-traceability.txt 3`
- `bash tests/skill-triggering/run-test.sh project-memory tests/skill-triggering/prompts/project-memory.txt 3`
- `bash tests/skill-triggering/run-test.sh traceability-review tests/skill-triggering/prompts/traceability-review.txt 3`
- `bash tests/explicit-skill-requests/run-test.sh context-traceability tests/explicit-skill-requests/prompts/context-traceability.txt 3`
- `bash tests/explicit-skill-requests/run-test.sh project-memory tests/explicit-skill-requests/prompts/project-memory.txt 3`
- `bash tests/explicit-skill-requests/run-test.sh traceability-review tests/explicit-skill-requests/prompts/traceability-review.txt 3`

**Known risks:**
- Skill wording changes can alter agent behavior. Use `superpowers:writing-skills` before modifying skill content and keep edits narrow.
- Existing command files are deprecated. This fork can add new slash commands, but upstreaming this command surface later needs separate discussion.
- Long-running Claude-based tests may require the `claude` CLI and may not run in every local environment.
- `AGENTS.md` currently has an unrelated typechange in the worktree. Do not stage or modify it.

## File Structure

Create:
- `skills/project-memory/SKILL.md`: owns durable memory creation, refresh, summarization, and learning capture.
- `skills/context-traceability/SKILL.md`: owns related-context discovery, command state, context packets, and phase gates.
- `skills/traceability-review/SKILL.md`: owns independent review modes and report contract.
- `docs/project-memory/FEATURE_CONTEXT.md`: durable feature/domain context.
- `docs/project-memory/BUG_PATTERNS.md`: reusable bug patterns and root-cause learnings.
- `docs/project-memory/SPEC_INDEX.md`: routing index from features/modules to specs/plans/status.
- `docs/project-memory/ACTIVE_CONTEXT.md`: optional current-work pointer file.
- `commands/context-start.md`
- `commands/brainstorm-feature.md`
- `commands/write-spec.md`
- `commands/review-spec.md`
- `commands/plan-spec.md`
- `commands/review-plan.md`
- `commands/implement-plan.md`
- `commands/review-implementation.md`
- `commands/debug-with-memory.md`
- `commands/review-bug-fix.md`
- `commands/update-spec.md`
- `commands/record-learning.md`
- `commands/review-memory.md`
- `commands/review-traceability.md`
- `commands/finish-traceable.md`
- `tests/context-traceability/run-static-checks.sh`
- `tests/skill-triggering/prompts/context-traceability.txt`
- `tests/skill-triggering/prompts/project-memory.txt`
- `tests/skill-triggering/prompts/traceability-review.txt`
- `tests/explicit-skill-requests/prompts/context-traceability.txt`
- `tests/explicit-skill-requests/prompts/project-memory.txt`
- `tests/explicit-skill-requests/prompts/traceability-review.txt`

Modify:
- `skills/using-superpowers/SKILL.md`: route memory, traceability, review, and command-like requests.
- `skills/brainstorming/SKILL.md`: add project-memory and brainstorm-preflight gates.
- `skills/writing-plans/SKILL.md`: add project-memory prerequisite, planning preflight, context packet, plan review, and pressure-test.
- `skills/subagent-driven-development/SKILL.md`: require context packets before dispatch.
- `skills/subagent-driven-development/implementer-prompt.md`: add context packet section.
- `skills/subagent-driven-development/spec-reviewer-prompt.md`: add spec/plan/feature-context review inputs.
- `skills/executing-plans/SKILL.md`: require context packet and traceability review before execution.
- `skills/systematic-debugging/SKILL.md`: add debug memory preflight and evidence trail persistence.
- `skills/verification-before-completion/SKILL.md`: add traceability evidence before completion claims.
- `skills/finishing-a-development-branch/SKILL.md`: add `finish-traceable` hygiene before branch integration.

## Task 1: Add Static Check Harness First

**Files:**
- Create: `tests/context-traceability/run-static-checks.sh`

- [ ] **Step 1: Create the failing static check script**

Create `tests/context-traceability/run-static-checks.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

require_file() {
  local path="$1"
  [ -f "$path" ] || fail "Missing required file: $path"
}

require_contains() {
  local path="$1"
  local pattern="$2"
  require_file "$path"
  grep -Fq "$pattern" "$path" || fail "Missing pattern in $path: $pattern"
}

support_skills=(
  skills/project-memory/SKILL.md
  skills/context-traceability/SKILL.md
  skills/traceability-review/SKILL.md
)

memory_files=(
  docs/project-memory/FEATURE_CONTEXT.md
  docs/project-memory/BUG_PATTERNS.md
  docs/project-memory/SPEC_INDEX.md
  docs/project-memory/ACTIVE_CONTEXT.md
)

commands=(
  context-start
  brainstorm-feature
  write-spec
  review-spec
  plan-spec
  review-plan
  implement-plan
  review-implementation
  debug-with-memory
  review-bug-fix
  update-spec
  record-learning
  review-memory
  review-traceability
  finish-traceable
)

for path in "${support_skills[@]}"; do
  require_file "$path"
  require_contains "$path" "description:"
done

for path in "${memory_files[@]}"; do
  require_file "$path"
done

for command in "${commands[@]}"; do
  path="commands/${command}.md"
  require_file "$path"
  require_contains "$path" "Fallback phrase:"
  require_contains "$path" "Required skill"
done

require_contains skills/using-superpowers/SKILL.md "context-traceability"
require_contains skills/using-superpowers/SKILL.md "project-memory"
require_contains skills/using-superpowers/SKILL.md "traceability-review"
require_contains skills/brainstorming/SKILL.md "brainstorm-preflight"
require_contains skills/writing-plans/SKILL.md "planning-preflight"
require_contains skills/writing-plans/SKILL.md "Plan Pressure-Test"
require_contains skills/subagent-driven-development/SKILL.md "context packet"
require_contains skills/subagent-driven-development/implementer-prompt.md "Context Packet"
require_contains skills/executing-plans/SKILL.md "context packet"
require_contains skills/systematic-debugging/SKILL.md "BUG_PATTERNS.md"
require_contains skills/verification-before-completion/SKILL.md "traceability evidence"
require_contains skills/finishing-a-development-branch/SKILL.md "finish-traceable"

require_contains skills/traceability-review/SKILL.md "Blocking findings"
require_contains skills/traceability-review/SKILL.md "Non-blocking concerns"
require_contains skills/traceability-review/SKILL.md "Missing updates"
require_contains skills/traceability-review/SKILL.md "Recommended next command"

if grep -R "claude-mem" skills commands docs/project-memory tests/context-traceability -n | grep -v "optional" | grep -v "absent" | grep -v "optional adapter"; then
  fail "claude-mem must remain optional and absent-safe"
fi

echo "[PASS] Context traceability static checks passed"
```

- [ ] **Step 2: Run the static check and verify it fails**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: skills/project-memory/SKILL.md`.

- [ ] **Step 3: Commit the failing check**

```bash
git add tests/context-traceability/run-static-checks.sh
git commit -m "test: add context traceability static checks"
```

## Task 2: Add Project Memory Artifacts

**Files:**
- Create: `docs/project-memory/FEATURE_CONTEXT.md`
- Create: `docs/project-memory/BUG_PATTERNS.md`
- Create: `docs/project-memory/SPEC_INDEX.md`
- Create: `docs/project-memory/ACTIVE_CONTEXT.md`

- [ ] **Step 1: Create `FEATURE_CONTEXT.md`**

Create `docs/project-memory/FEATURE_CONTEXT.md` with:

```markdown
# Feature Context

Durable feature and domain knowledge that future sessions should not rediscover from scratch.

## Terms

- **Basic Workflow:** The existing Superpowers flow: brainstorm, spec, plan, implement, verify, finish.
- **Traceability layer:** A support workflow that connects discussion, project memory, related specs, plans, code, tests, and bug learnings.
- **Context packet:** A concise briefing that names the active task, related artifacts, acceptance criteria, feature invariants, code paths, tests, and risks.

## Invariants

- Existing Superpowers skills remain the source of truth for workflow behavior.
- Slash commands are thin entrypoints or aliases, not competing workflows.
- File-based project memory is authoritative for this workflow; external memory tools are optional adapters.
- Skill behavior changes require eval evidence because skills are behavior-shaping content.

## Repeated Corrections

- Do not add `claude-mem` as a required or optional core dependency.
- Do not create duplicate workflows named after slash commands when an existing skill owns the phase.
- Keep fork-specific workflow additions separate from upstream PR claims until there is evidence and human review.
```

- [ ] **Step 2: Create `BUG_PATTERNS.md`**

Create `docs/project-memory/BUG_PATTERNS.md` with:

````markdown
# Bug Patterns

Reusable debugging learnings captured after root-cause evidence exists.

## Entry Format

```text
### Pattern: Context mismatch after resume

- **Symptom:** What failed.
- **Root cause:** What evidence showed.
- **Detection:** Command, log, or reproduction that reveals it.
- **Fix pattern:** The durable fix, not a symptom patch.
- **Regression test:** Test or check that should fail before the fix and pass after.
- **Related artifacts:** Specs, plans, code paths, or commits.
```

## Current Patterns

- No repeatable project-specific bug patterns recorded yet.
````

- [ ] **Step 3: Create `SPEC_INDEX.md`**

Create `docs/project-memory/SPEC_INDEX.md` with:

```markdown
# Spec Index

Fast routing index for specs, plans, implementation state, and related project memory.

This index helps commands choose relevant artifacts. It does not replace reading the actual spec or plan.

| Feature | Status | Spec | Plan | Related Memory | Notes |
| --- | --- | --- | --- | --- | --- |
| Context traceability slash commands | Planned | `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md` | `docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md` | `docs/project-memory/FEATURE_CONTEXT.md`, `docs/project-memory/CONCERNS.md` | Fork-first workflow enhancement. |
```

- [ ] **Step 4: Create `ACTIVE_CONTEXT.md`**

Create `docs/project-memory/ACTIVE_CONTEXT.md` with:

```markdown
# Active Context

Small pointer file for the current traceable workflow. Keep this file short.

## Current Work

- **Feature:** Context traceability slash commands
- **Spec:** `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`
- **Plan:** `docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`
- **Branch:** `fork/nghia`
- **State:** Planning

## Notes

- Do not store large summaries here.
- If this file is stale, prefer explicit spec or plan paths over guessing.
```

- [ ] **Step 5: Run the static check and verify the remaining failure moved forward**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: skills/project-memory/SKILL.md`.

- [ ] **Step 6: Commit memory artifacts**

```bash
git add docs/project-memory/FEATURE_CONTEXT.md docs/project-memory/BUG_PATTERNS.md docs/project-memory/SPEC_INDEX.md docs/project-memory/ACTIVE_CONTEXT.md
git commit -m "docs: add traceability memory artifacts"
```

## Task 3: Add `project-memory` Skill

**Files:**
- Create: `skills/project-memory/SKILL.md`

- [ ] **Step 1: Use the skill-writing workflow**

Announce and invoke `superpowers:writing-skills` before editing skill content.

Expected behavior: the skill is loaded before creating `skills/project-memory/SKILL.md`.

- [ ] **Step 2: Create `skills/project-memory/SKILL.md`**

Create the file with:

````markdown
---
name: project-memory
description: Use when starting work in an existing codebase, refreshing durable project context, recording reusable learnings, or auditing docs/project-memory before brainstorming, planning, implementation, debugging, or review
---

# Project Memory

Create, refresh, read, and summarize durable project memory for existing codebases.

## Core Principle

Project memory is a briefing pack, not an oracle. Prefer observed repository facts. Label inferences. Preserve open questions. If memory and code disagree, trust the code and refresh the memory.

## Memory Surface

Use `docs/project-memory/` unless the human partner explicitly chooses a different location.

Required minimum pack:

- `ARCHITECTURE.md`
- `STRUCTURE.md`
- `CONVENTIONS.md`
- `TESTING.md`
- `CONCERNS.md`
- `FEATURE_CONTEXT.md`
- `SPEC_INDEX.md`

Optional but recommended:

- `STACK.md`
- `INTEGRATIONS.md`
- `BUG_PATTERNS.md`
- `ACTIVE_CONTEXT.md`

## Modes

### Start

Use at the beginning of work in an existing codebase.

1. Check whether `docs/project-memory/` exists.
2. If missing, create the minimum pack from repository facts before feature work continues.
3. If present, read the relevant files for the current task.
4. Compare memory against obvious repo facts such as top-level files, skill names, command names, and recent specs/plans.
5. Refresh stale focused sections immediately when the correction is narrow.
6. Ask before broad archaeology across many unrelated files.
7. Output a compact context summary, missing or untrusted memory, related specs/plans, and a recommended next command.

### Record

Use when the human partner says to remember a lesson or when a workflow discovers durable context.

1. Classify the lesson as feature context, bug pattern, architecture fact, convention, testing lesson, integration caveat, concern, or spec relationship.
2. Update the narrowest appropriate memory file.
3. Link related specs, plans, code paths, or commits when known.
4. Keep entries operational and short.

### Review

Use for `/review-memory`.

1. Read all `docs/project-memory/*.md`.
2. Compare against current repo structure and recent specs/plans.
3. Report stale facts, missing files, duplicate information, missing bug patterns, and stale `SPEC_INDEX.md` entries.
4. Ask for approval before editing memory during review mode.

## File Guidance

### `FEATURE_CONTEXT.md`

Record terminology, user-facing concepts, business rules, invariants, repeated corrections, and feature constraints that future specs/plans/subagents need.

### `BUG_PATTERNS.md`

Record only evidence-backed repeatable patterns. Include symptom, root cause, detection, fix pattern, regression test, and related artifacts.

### `SPEC_INDEX.md`

Record feature, status, spec path, plan path, related memory, and notes. This is a routing index and never replaces reading the full spec or plan.

### `ACTIVE_CONTEXT.md`

Store only current pointers: feature, spec, plan, branch, state, and short notes. If stale, prefer explicit user-provided paths.

## Optional External Memory

If a memory search tool such as `claude-mem` is available, you may search it for prior discussion context. Treat results as hints. File-based project memory remains the source of truth, and the workflow must work when `claude-mem` is absent.

## Output Shape

```text
Project context
- Relevant facts and paths.

Related artifacts
- Specs, plans, memory files, and likely code areas.

Missing or untrusted memory
- Files or facts that are absent, stale, or inferred.

Recommended next command
- One command or fallback phrase.
```
````

- [ ] **Step 3: Run static check and verify next missing skill**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: skills/context-traceability/SKILL.md`.

- [ ] **Step 4: Commit project-memory skill**

```bash
git add skills/project-memory/SKILL.md
git commit -m "feat: add project memory skill"
```

## Task 4: Add `context-traceability` Skill

**Files:**
- Create: `skills/context-traceability/SKILL.md`

- [ ] **Step 1: Create `skills/context-traceability/SKILL.md`**

Create the file with:

````markdown
---
name: context-traceability
description: Use when linking current work to project memory, related specs, plans, code, tests, command state, context packets, or traceability gates before brainstorming, planning, implementation, debugging, review, or finishing
---

# Context Traceability

Discover related context and keep each workflow phase traceable from discussion to memory, spec, plan, code, tests, and bug learnings.

## Core Principle

Do not rely on fragile conversation memory when file-backed context exists. Build the smallest useful context packet, name the artifacts that need full reading, and flag missing or untrusted context.

## Modes

### `brainstorm-preflight`

1. Read relevant project memory.
2. Search specs, plans, and likely code areas for related decisions.
3. Summarize prior decisions, feature context, assumptions, unknowns, and likely edge cases.
4. Return the summary to `brainstorming` before detailed questions.

### `planning-preflight`

1. Read the approved spec.
2. Read `SPEC_INDEX.md`, `FEATURE_CONTEXT.md`, and relevant memory files.
3. Discover related specs, plans, and code paths.
4. Build a context packet for the plan.
5. Flag missing context before plan tasks are written.

### `implementation-context`

1. Read the plan, referenced spec, and context packet.
2. Verify the plan names related specs, memory files, likely code paths, edge cases, and verification commands.
3. Prepare a subagent-ready context packet.
4. If context is partial, say which artifacts are missing before dispatch.

### `debug-preflight`

1. Read `BUG_PATTERNS.md`, `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, and relevant specs/plans.
2. Establish expected behavior before root-cause investigation.
3. Prepare an evidence trail with observations, hypotheses, experiments, root cause, fix, verification, and memory/spec updates.

### `spec-update`

1. Resolve the most relevant spec through `SPEC_INDEX.md`, filenames, and content search.
2. Ask the human partner to choose when multiple specs match.
3. Update behavior through the spec before implementation.
4. Trigger spec review after the update.

## Command State

Persist enough state for new conversations:

- `docs/project-memory/SPEC_INDEX.md`: feature, status, spec, plan, related memory, notes.
- `docs/project-memory/ACTIVE_CONTEXT.md`: active pointers only.
- Spec metadata: status, related specs, related plans, owning command, last review date.
- Plan metadata: referenced spec, status, context packet, related specs, verification commands.

If the active spec or plan cannot be resolved, ask the human partner to choose instead of guessing.

## Context Packet

Build this compact packet before planning, implementation, subagent dispatch, debugging, and traceability review:

```text
Task or feature summary:

Relevant project memory:

Related specs and plans:

Feature context:

Acceptance criteria:

Edge cases and negative cases:

Relevant code paths:

Test obligations and verification commands:

Known risks, open questions, and untrusted context:
```

Keep the packet small enough to paste into a subagent prompt. Include paths so workers can read full artifacts when needed.

## Subagent Injection

Before dispatching implementer, reviewer, debugger, or explorer subagents:

1. Include the context packet in the prompt.
2. Name the spec, plan, memory files, and code paths the subagent must read.
3. Tell the subagent to stop and ask if required context is missing.
4. Keep file-based project memory as the source of truth even when optional memory search tools are available.

## Optional External Memory

If `claude-mem` or another memory search tool is available, you may query it for prior discussion hints. The workflow must degrade gracefully when it is absent.
````

- [ ] **Step 2: Run static check and verify next missing skill**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: skills/traceability-review/SKILL.md`.

- [ ] **Step 3: Commit context-traceability skill**

```bash
git add skills/context-traceability/SKILL.md
git commit -m "feat: add context traceability skill"
```

## Task 5: Add `traceability-review` Skill

**Files:**
- Create: `skills/traceability-review/SKILL.md`

- [ ] **Step 1: Create `skills/traceability-review/SKILL.md`**

Create the file with:

````markdown
---
name: traceability-review
description: Use when reviewing whether a spec, plan, implementation, bug fix, memory pack, or active work is aligned with discussion, project memory, related specs, plans, code, tests, and bug learnings
---

# Traceability Review

Review specs, plans, implementations, bug fixes, memory, or full workflow chains for drift and missing context.

## Core Principle

Lead with findings. Review artifacts against their sources of truth. Do not edit files during standalone review unless the human partner explicitly approves.

## Report Contract

```text
Blocking findings
- [severity] [artifact/path] Problem. Evidence. Required action.

Non-blocking concerns
- [severity] [artifact/path] Concern. Evidence. Suggested action.

Missing updates
- Spec/plan/memory/test update needed, with target file.

Recommended next command
- One command, such as /update-spec, /review-plan, /implement-plan, or /finish-traceable.
```

If there are no findings in a section, write `None found`.

## Edit Contract

Standalone review modes may read freely. They may edit only after explicit human approval.

Internal self-review gates may fix the artifact they just created:

- `/write-spec` may fix the spec it is writing.
- `/plan-spec` may fix the plan it is writing.

## Modes

### `spec-review`

Review a spec for mismatch with current discussion when available, approved design, related specs, project memory, feature context, assumptions, unknowns, edge cases, user-facing surface, acceptance criteria, and testability.

### `plan-review`

Review a plan for spec coverage, missing code areas, missing tests, task size, ordering problems, unclear acceptance criteria, missing docs/config/migrations, missing context packet inputs, and risk of behavior outside the spec.

Then pressure-test the plan:

1. Can each task be completed from the given context?
2. Are task dependencies ordered correctly?
3. Does any task write before required discovery?
4. Does every acceptance criterion have a verification step?
5. Do likely edge cases appear in tasks or tests?

### `implementation-review`

Review the current diff against the active plan and spec. Check that every plan task is complete, every acceptance criterion is satisfied, feature-context invariants still hold, tests cover edge cases, behavior has not drifted beyond the spec, unrelated changes are absent, and docs/spec/memory updates are identified.

### `bug-fix-review`

Review whether root-cause evidence exists, the fix addresses root cause, a regression test exists, no new edge case was introduced, the spec was updated if behavior changed, and `BUG_PATTERNS.md` was updated when the pattern is reusable.

### `memory-review`

Review `docs/project-memory/*.md` for stale facts, missing files, missing feature context, missing bug patterns, duplicate information, and stale `SPEC_INDEX.md` entries.

### `full`

Review the whole chain: discussion or available context, project memory, feature context, related specs, plan, code, tests, bug patterns, and finishing hygiene.
````

- [ ] **Step 2: Run static check and verify command failure**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: commands/context-start.md`.

- [ ] **Step 3: Commit traceability-review skill**

```bash
git add skills/traceability-review/SKILL.md
git commit -m "feat: add traceability review skill"
```

## Task 6: Add Slash Command Files

**Files:**
- Create all command files listed in File Structure.

- [ ] **Step 1: Create command files**

Use this exact content for each file, changing only the command name, fallback phrase, required skill, and behavior lines shown below.

`commands/context-start.md`:

```markdown
---
description: "Start with durable project memory and related context"
---

# /context-start

Fallback phrase: `Context start: summarize traceability workflow`

Required skill: `superpowers:project-memory`

Use `project-memory` in start mode. If a task summary is provided, also use `context-traceability` to discover related specs, plans, memory files, and likely code paths.

Output project context, related artifacts, missing or untrusted memory, and the recommended next command.
```

`commands/brainstorm-feature.md`:

```markdown
---
description: "Start memory-aware brainstorming for a feature idea"
---

# /brainstorm-feature

Fallback phrase: `Brainstorm feature: add durable memory to workflow`

Required skill: `superpowers:brainstorming`

Use `brainstorming` as the primary workflow. Before detailed questions, use `context-traceability` in `brainstorm-preflight` mode to read project memory, feature context, related specs, related plans, and likely code areas.

If the human partner wants command-driven finalization, stop after approved design and leave a handoff for `/write-spec`.
```

`commands/write-spec.md`:

```markdown
---
description: "Write the approved brainstorm into a trace-reviewed spec"
---

# /write-spec

Fallback phrase: `Write spec for the approved design`

Required skill: `superpowers:brainstorming`

Finalize only an approved design that is pending spec writing. Use `traceability-review` in `spec-review` mode before presenting the spec path. Do not write an implementation plan.
```

`commands/review-spec.md`:

```markdown
---
description: "Review a spec against memory, discussion, related specs, and edge cases"
---

# /review-spec

Fallback phrase: `Review spec: docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`

Required skill: `superpowers:traceability-review`

Use `traceability-review` in `spec-review` mode. Read the spec, project memory, `SPEC_INDEX.md`, `FEATURE_CONTEXT.md`, and related specs/plans before reporting findings.
```

`commands/plan-spec.md`:

```markdown
---
description: "Write a traceable implementation plan from an approved spec"
---

# /plan-spec

Fallback phrase: `Plan spec: docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`

Required skill: `superpowers:writing-plans`

Use `writing-plans`. Before writing tasks, use `context-traceability` in `planning-preflight` mode and include a context packet in the plan. Run `traceability-review` in `plan-review` mode and pressure-test the plan before asking for approval.
```

`commands/review-plan.md`:

```markdown
---
description: "Review and pressure-test an implementation plan"
---

# /review-plan

Fallback phrase: `Review plan: docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`

Required skill: `superpowers:traceability-review`

Use `traceability-review` in `plan-review` mode. Resolve the referenced spec, read project memory and related specs, inspect named code paths, and pressure-test task ordering and verification coverage.
```

`commands/implement-plan.md`:

```markdown
---
description: "Implement an approved plan with traceable context"
---

# /implement-plan

Fallback phrase: `Implement plan: docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`

Required skill: `superpowers:subagent-driven-development`

Use `subagent-driven-development` when subagents are available; otherwise use `executing-plans`. Read the plan, referenced spec, context packet, feature context, related specs, and relevant code before executing.
```

`commands/review-implementation.md`:

```markdown
---
description: "Review the current implementation against plan and spec"
---

# /review-implementation

Fallback phrase: `Review implementation for the active plan`

Required skill: `superpowers:traceability-review`

Use `traceability-review` in `implementation-review` mode. Inspect the current diff and verify plan completion, spec acceptance criteria, feature-context invariants, tests, docs, and memory updates.
```

`commands/debug-with-memory.md`:

```markdown
---
description: "Debug using specs, project memory, and bug patterns"
---

# /debug-with-memory

Fallback phrase: `Debug with memory: implementation skipped related spec after resume`

Required skill: `superpowers:systematic-debugging`

Use `systematic-debugging`. Before root-cause investigation, use `context-traceability` in `debug-preflight` mode and read `BUG_PATTERNS.md`, `FEATURE_CONTEXT.md`, related specs, plans, and code.
```

`commands/review-bug-fix.md`:

```markdown
---
description: "Review a bug fix for root-cause evidence and regression coverage"
---

# /review-bug-fix

Fallback phrase: `Review bug fix: fix for missing context packet`

Required skill: `superpowers:traceability-review`

Use `traceability-review` in `bug-fix-review` mode. Check root-cause evidence, regression test coverage, spec updates for behavior changes, and reusable bug-pattern recording.
```

`commands/update-spec.md`:

```markdown
---
description: "Update the relevant spec before changing behavior"
---

# /update-spec

Fallback phrase: `Update spec: require context packets before subagent dispatch`

Required skill: `superpowers:context-traceability`

Use `context-traceability` in `spec-update` mode. Resolve the target spec through `SPEC_INDEX.md`, filenames, and content search. Ask when multiple specs match. Run `traceability-review` in `spec-review` mode after the update.
```

`commands/record-learning.md`:

```markdown
---
description: "Record a durable project learning"
---

# /record-learning

Fallback phrase: `Record learning: subagents need explicit feature context before implementation`

Required skill: `superpowers:project-memory`

Use `project-memory` in record mode. Classify the lesson and update the narrowest appropriate memory file with links to related specs, plans, code paths, or commits.
```

`commands/review-memory.md`:

```markdown
---
description: "Audit project memory freshness"
---

# /review-memory

Fallback phrase: `Review project memory`

Required skill: `superpowers:project-memory`

Use `project-memory` in review mode, then use `traceability-review` in `memory-review` mode for the report. Ask before editing memory files.
```

`commands/review-traceability.md`:

```markdown
---
description: "Review the full traceability chain for active work"
---

# /review-traceability

Fallback phrase: `Review traceability: current implementation`

Required skill: `superpowers:traceability-review`

Use `traceability-review` in `full` mode unless the target clearly maps to a narrower review mode. Check discussion or available context, project memory, feature context, related specs, plan, code, tests, and bug patterns.
```

`commands/finish-traceable.md`:

```markdown
---
description: "Finish work with verification, traceability, and memory hygiene"
---

# /finish-traceable

Fallback phrase: `Finish traceable work`

Required skill: `superpowers:verification-before-completion`

Use `verification-before-completion`, then run `traceability-review` in `full` mode. Update `SPEC_INDEX.md`, project memory, and `BUG_PATTERNS.md` when required before invoking `finishing-a-development-branch`.
```

- [ ] **Step 2: Run static check and verify existing skill integration is next failure**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with a message naming the first missing integration pattern, such as `Missing pattern in skills/using-superpowers/SKILL.md: context-traceability`.

- [ ] **Step 3: Commit command files**

```bash
git add commands/context-start.md commands/brainstorm-feature.md commands/write-spec.md commands/review-spec.md commands/plan-spec.md commands/review-plan.md commands/implement-plan.md commands/review-implementation.md commands/debug-with-memory.md commands/review-bug-fix.md commands/update-spec.md commands/record-learning.md commands/review-memory.md commands/review-traceability.md commands/finish-traceable.md
git commit -m "feat: add traceability slash commands"
```

## Task 7: Integrate Existing Workflow Skills

**Files:**
- Modify: `skills/using-superpowers/SKILL.md`
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md`
- Modify: `skills/executing-plans/SKILL.md`
- Modify: `skills/systematic-debugging/SKILL.md`
- Modify: `skills/verification-before-completion/SKILL.md`
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Update `using-superpowers` routing**

In `skills/using-superpowers/SKILL.md`, after the `## Skill Priority` list, add:

```markdown
## Traceable Workflow Routing

When work touches an existing codebase, project memory, specs, plans, implementation, debugging, review, or finishing, consider these support skills before acting:

- Use `project-memory` when starting in an existing codebase, refreshing durable context, recording learnings, or reviewing `docs/project-memory/`.
- Use `context-traceability` when a task needs related specs/plans/code, command state, context packets, spec updates, or subagent context injection.
- Use `traceability-review` when reviewing a spec, plan, implementation, bug fix, memory pack, or full active workflow chain.

Command-like prompts map to skills:

| Prompt shape | Required skill |
| --- | --- |
| `/context-start` or `Context start:` | `project-memory` |
| `/brainstorm-feature` or `Brainstorm feature:` | `brainstorming` plus `context-traceability` |
| `/write-spec` or `Write spec` | `brainstorming` plus `traceability-review` |
| `/plan-spec` or `Plan spec:` | `writing-plans` plus `context-traceability` |
| `/review-spec`, `/review-plan`, `/review-implementation`, `/review-bug-fix`, `/review-traceability` | `traceability-review` |
| `/implement-plan` or `Implement plan:` | `subagent-driven-development` or `executing-plans` |
| `/debug-with-memory` or `Debug with memory:` | `systematic-debugging` plus `context-traceability` |
| `/update-spec` or `Update spec:` | `context-traceability` |
| `/record-learning` or `Record learning:` | `project-memory` |
| `/finish-traceable` or `Finish traceable work` | `verification-before-completion` plus `traceability-review` |
```

- [ ] **Step 2: Update `brainstorming` checklist structurally**

In `skills/brainstorming/SKILL.md`, replace the current checklist with:

```markdown
## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, recent commits
2. **Establish project memory for existing codebases** — if durable architecture/convention/testing/concern docs are missing or stale, invoke `project-memory`
3. **Run brainstorm-preflight** — for existing codebases, invoke `context-traceability` in `brainstorm-preflight` mode before detailed questions
4. **Offer visual companion** (if topic will involve visual questions) — this is its own message, not combined with a clarifying question. See the Visual Companion section below.
5. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
6. **Propose 2-3 approaches** — with trade-offs and your recommendation, including assumptions, unknowns, related specs, and likely edge cases
7. **Present design** — in sections scaled to their complexity, get user approval after each section
8. **Write design doc** — save to a date-stamped design file under `docs/superpowers/specs/` and commit
9. **Spec self-review** — invoke `traceability-review` in `spec-review` mode, then fix issues in the spec you just wrote
10. **User reviews written spec** — ask user to review the spec file before proceeding
11. **Transition to implementation** — invoke writing-plans skill to create implementation plan
```

- [ ] **Step 3: Add project memory bullets to `brainstorming` process**

In `skills/brainstorming/SKILL.md`, under `**Understanding the idea:**`, add these bullets after `Check out the current project state first`:

```markdown
- In existing codebases, prefer durable project memory over repeated archaeology. If `docs/project-memory/` is missing or stale, invoke `project-memory` before design work continues.
- If project memory exists, read the relevant artifacts before asking detailed feature questions. At minimum, pull in architecture, structure, conventions, testing, concerns, feature context, and spec index docs for the subsystem you're changing.
- Use `context-traceability` in `brainstorm-preflight` mode to discover related specs, plans, code paths, feature context, assumptions, unknowns, and likely edge cases.
```

- [ ] **Step 4: Update `writing-plans` with traceable planning gates**

In `skills/writing-plans/SKILL.md`, after `## Scope Check`, add:

```markdown
## Project Memory Prerequisite

In existing codebases, plans must be grounded in durable project memory rather than rediscovering architecture from scratch.

Before writing the plan:

- Read the relevant files from `docs/project-memory/` or the human partner's preferred equivalent.
- At minimum, read architecture, conventions, testing, concerns, feature context, and spec index docs for the area you're changing.
- If those docs are missing or stale, stop and invoke `project-memory` before continuing.

Plans must preserve the project's established structure, conventions, and integration boundaries unless the approved spec explicitly changes them.

## Traceability Preflight

Before defining tasks:

1. Invoke `context-traceability` in `planning-preflight` mode.
2. Read the approved spec and related specs/plans.
3. Inspect relevant code paths named by the spec, memory, or preflight.
4. Build a context packet in the plan.
5. Invoke `traceability-review` in `plan-review` mode after writing the plan.

## Plan Pressure-Test

Before asking the human partner to approve the plan, simulate execution:

1. Can each task be completed from the provided context packet?
2. Are task dependencies ordered correctly?
3. Does any task write before required discovery?
4. Does every acceptance criterion have a verification step?
5. Are likely edge cases covered by tasks or tests?

Fix review and pressure-test issues in the plan before presenting it.
```

- [ ] **Step 5: Update `writing-plans` header template**

In `skills/writing-plans/SKILL.md`, replace the plan header template with:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Project Memory:** [Relevant docs/project-memory/*.md files used for this plan, or "None - greenfield"]

---

## Implementation Context Packet

**Active spec:** [path]

**Related artifacts:** [paths]

**Feature context:** [terms, invariants, user-facing concepts, and durable business rules]

**Acceptance criteria:** [mapped requirements]

**Edge cases and negative cases:** [covered cases]

**Relevant code paths:** [paths inspected or needing inspection]

**Verification commands:** [commands]

**Known risks and open questions:** [specific risks]
```

- [ ] **Step 6: Update `subagent-driven-development`**

In `skills/subagent-driven-development/SKILL.md`, after the paragraph beginning `**Core principle:**`, add:

```markdown
**Traceability requirement:** Before dispatching any implementer, spec reviewer, code quality reviewer, debugger, or explorer subagent, build or read the plan's context packet. Include that packet in the subagent prompt with the active spec path, plan path, related memory files, feature context, acceptance criteria, edge cases, relevant code paths, verification commands, and missing or untrusted context.
```

In the `## Red Flags` list, add:

```markdown
- Dispatch subagents without a context packet when the plan or active work has one
```

- [ ] **Step 7: Update subagent prompt templates**

In `skills/subagent-driven-development/implementer-prompt.md`, after `## Context`, add:

```markdown
    ## Context Packet

    [Paste the active context packet here. Include spec path, plan path, project-memory files, feature context, acceptance criteria, edge cases, relevant code paths, verification commands, known risks, and untrusted context.]

    Before editing, read the named spec, plan, and memory files. If any required artifact is missing or contradictory, report NEEDS_CONTEXT instead of guessing.
```

In `skills/subagent-driven-development/spec-reviewer-prompt.md`, after `## What Was Requested`, add:

```markdown
    ## Traceability Inputs

    [Paste active spec path, plan path, context packet, related specs, project-memory files, feature context, acceptance criteria, and edge cases.]

    Verify the implementation against the requested task, active spec, feature context, and related artifacts. If the task conflicts with the spec or feature context, report the conflict instead of choosing silently.
```

- [ ] **Step 8: Update `executing-plans`**

In `skills/executing-plans/SKILL.md`, under `### Step 1: Load and Review Plan`, replace the numbered list with:

```markdown
1. Read plan file.
2. Read the referenced spec, related specs, project memory, and the plan's context packet.
3. If the plan lacks a context packet for existing-codebase work, stop and ask the human partner to review the exact plan path or regenerate the plan.
4. Review critically - identify any questions or concerns about the plan.
5. If concerns: Raise them with your human partner before starting.
6. If no concerns: Create TodoWrite and proceed.
```

- [ ] **Step 9: Update `systematic-debugging`**

In `skills/systematic-debugging/SKILL.md`, after `## The Iron Law`, add:

```markdown
## Memory And Evidence Preflight

For existing-codebase bugs, invoke `context-traceability` in `debug-preflight` mode before proposing fixes. Read project memory, `FEATURE_CONTEXT.md`, `BUG_PATTERNS.md`, related specs, related plans, and likely code paths.

Preserve an evidence trail:

- Observations
- Reproduction steps
- Hypotheses
- Experiments
- Root cause
- Fix
- Verification
- Spec or memory updates needed

After the fix, update the relevant spec if behavior changed. If the root cause is reusable, record it in `BUG_PATTERNS.md`.
```

- [ ] **Step 10: Update `verification-before-completion`**

In `skills/verification-before-completion/SKILL.md`, after `## The Gate Function`, add:

```markdown
## Traceability Evidence

For traceable feature, plan, implementation, or bug-fix work, completion requires evidence beyond test output:

1. Identify the active spec and plan when they exist.
2. Verify the current diff against plan tasks and spec acceptance criteria.
3. Check whether feature context, project memory, `SPEC_INDEX.md`, or `BUG_PATTERNS.md` need updates.
4. Run or request `traceability-review` when the work touches specs, plans, behavior, bug fixes, or memory.
5. Only then make completion claims.
```

- [ ] **Step 11: Update `finishing-a-development-branch`**

In `skills/finishing-a-development-branch/SKILL.md`, after `### Step 1: Verify Tests`, add:

```markdown
### Step 1.5: Finish Traceable Work

If the branch has an active spec, plan, or traceability context, run the `finish-traceable` hygiene before presenting integration options:

1. Run `traceability-review` in `full` mode.
2. Update `SPEC_INDEX.md`.
3. Update project memory if architecture, conventions, testing, integrations, feature context, or concerns changed.
4. Update `BUG_PATTERNS.md` if the work fixed a reusable bug pattern.
5. Summarize specs changed, plans changed, code changed, tests run, and remaining risks.
```

- [ ] **Step 12: Run static check and verify it passes**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 13: Commit skill integrations**

```bash
git add skills/using-superpowers/SKILL.md skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/spec-reviewer-prompt.md skills/executing-plans/SKILL.md skills/systematic-debugging/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: integrate traceability gates into workflows"
```

## Task 8: Add Skill Trigger And Explicit Request Evals

**Files:**
- Create: `tests/skill-triggering/prompts/context-traceability.txt`
- Create: `tests/skill-triggering/prompts/project-memory.txt`
- Create: `tests/skill-triggering/prompts/traceability-review.txt`
- Create: `tests/explicit-skill-requests/prompts/context-traceability.txt`
- Create: `tests/explicit-skill-requests/prompts/project-memory.txt`
- Create: `tests/explicit-skill-requests/prompts/traceability-review.txt`

- [ ] **Step 1: Create skill-triggering prompt for context traceability**

Create `tests/skill-triggering/prompts/context-traceability.txt` with:

```text
I have a spec and plan for a feature, but this is a new conversation. Before implementing, check related specs, project memory, edge cases, and build the context that a worker agent needs.
```

- [ ] **Step 2: Create skill-triggering prompt for project memory**

Create `tests/skill-triggering/prompts/project-memory.txt` with:

```text
This is an existing codebase and I want you to start by summarizing durable project context, stale memory, related specs, and what we should read before planning.
```

- [ ] **Step 3: Create skill-triggering prompt for traceability review**

Create `tests/skill-triggering/prompts/traceability-review.txt` with:

```text
Review whether this implementation matches the spec and plan, whether any edge cases are missing, and whether memory or bug-pattern docs need updates.
```

- [ ] **Step 4: Create explicit request prompt for context traceability**

Create `tests/explicit-skill-requests/prompts/context-traceability.txt` with:

```text
Please use context-traceability to prepare an implementation context packet for the active plan before any coding starts.
```

- [ ] **Step 5: Create explicit request prompt for project memory**

Create `tests/explicit-skill-requests/prompts/project-memory.txt` with:

```text
Please use project-memory to audit docs/project-memory and summarize what context is missing before we brainstorm.
```

- [ ] **Step 6: Create explicit request prompt for traceability review**

Create `tests/explicit-skill-requests/prompts/traceability-review.txt` with:

```text
Please use traceability-review to review this plan against the spec, related memory, and likely edge cases.
```

- [ ] **Step 7: Run static check**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 8: Commit eval prompts**

```bash
git add tests/skill-triggering/prompts/context-traceability.txt tests/skill-triggering/prompts/project-memory.txt tests/skill-triggering/prompts/traceability-review.txt tests/explicit-skill-requests/prompts/context-traceability.txt tests/explicit-skill-requests/prompts/project-memory.txt tests/explicit-skill-requests/prompts/traceability-review.txt
git commit -m "test: add traceability skill eval prompts"
```

## Task 9: Run Verification And Capture Results

**Files:**
- Modify: none unless test failures reveal plan-approved fixes are needed.

- [ ] **Step 1: Run static checks**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 2: Run skill-triggering evals when Claude CLI is available**

Run:

```bash
bash tests/skill-triggering/run-test.sh context-traceability tests/skill-triggering/prompts/context-traceability.txt 3
bash tests/skill-triggering/run-test.sh project-memory tests/skill-triggering/prompts/project-memory.txt 3
bash tests/skill-triggering/run-test.sh traceability-review tests/skill-triggering/prompts/traceability-review.txt 3
```

Expected: each script exits 0 and prints that the requested skill was triggered.

- [ ] **Step 3: Run explicit request evals when Claude CLI is available**

Run:

```bash
bash tests/explicit-skill-requests/run-test.sh context-traceability tests/explicit-skill-requests/prompts/context-traceability.txt 3
bash tests/explicit-skill-requests/run-test.sh project-memory tests/explicit-skill-requests/prompts/project-memory.txt 3
bash tests/explicit-skill-requests/run-test.sh traceability-review tests/explicit-skill-requests/prompts/traceability-review.txt 3
```

Expected: each script exits 0 and prints that the requested skill was triggered, with no premature non-skill tool invocation before the first skill.

- [ ] **Step 4: Run existing relevant static and integration tests when available**

Run:

```bash
bash tests/skill-triggering/run-test.sh writing-plans tests/skill-triggering/prompts/writing-plans.txt 3
bash tests/skill-triggering/run-test.sh systematic-debugging tests/skill-triggering/prompts/systematic-debugging.txt 3
bash tests/explicit-skill-requests/run-test.sh subagent-driven-development tests/explicit-skill-requests/prompts/subagent-driven-development-please.txt 3
```

Expected: each script exits 0 and prints that the requested skill was triggered.

- [ ] **Step 5: Record unavailable verification explicitly**

If a command cannot run because `claude` or another harness is unavailable, do not mark it passing. Record the exact command, the error, and the reason it remains unverified in the final implementation report.

- [ ] **Step 6: Review final diff against spec**

Run:

```bash
git diff --stat
git diff -- docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md skills commands docs/project-memory tests/context-traceability tests/skill-triggering/prompts tests/explicit-skill-requests/prompts
```

Expected: the diff only includes files named in this plan, except `AGENTS.md` may remain an unrelated unstaged typechange that must not be staged.

## Self-Review

**Spec coverage:** This plan covers the user-facing workflow, command principles, harness fallback phrases, three support skills, file-based memory surface, command state model, context packets, subagent injection, review report contract, command behavior, existing skill integration, optional `claude-mem` behavior, error handling, and eval scenarios.

**Placeholder scan:** The plan avoids empty sections and gives exact file paths, command content, skill content, test script content, eval prompt content, verification commands, and expected outcomes.

**Pressure-test:** Each task can be executed from the context packet and the file-specific instructions. The ordering starts with a failing static check, adds memory files, adds support skills, adds commands, integrates existing skills, adds eval prompts, then verifies. No task writes implementation behavior before the support artifacts it depends on exist.
