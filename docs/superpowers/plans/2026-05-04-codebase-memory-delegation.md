# Codebase Memory Delegation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the deep foundational memory builder role to `building-codebase-memory` and make `project-memory` a clear workflow gateway that delegates deep codebase mapping instead of duplicating it.

**Architecture:** Add a focused `building-codebase-memory` skill for creating and refreshing foundational codebase docs. Narrow `project-memory` to reading, summarizing, routing, recording, reviewing, and delegating; update routing, commands, static checks, and eval prompts so agents understand the split.

**Tech Stack:** Markdown skills, Markdown commands, shell static checks, existing skill-triggering eval prompts.

**Project Memory:** `docs/project-memory/ARCHITECTURE.md`, `docs/project-memory/CONVENTIONS.md`, `docs/project-memory/TESTING.md`, `docs/project-memory/CONCERNS.md`, `docs/project-memory/STRUCTURE.md`, `docs/project-memory/INTEGRATIONS.md`, `docs/project-memory/FEATURE_CONTEXT.md`, `docs/project-memory/SPEC_INDEX.md`.

---

## Implementation Context Packet

**Active spec:** `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md`

**Related artifacts:**
- `skills/project-memory/SKILL.md`
- `skills/using-superpowers/SKILL.md`
- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`
- `commands/context-start.md`
- `commands/review-memory.md`
- `tests/context-traceability/run-static-checks.sh`
- `tests/skill-triggering/prompts/project-memory.txt`
- `tests/explicit-skill-requests/prompts/project-memory.txt`
- `/Users/vohongnghia/.codex/superpowers/skills/building-project-memory/SKILL.md`

**Feature context:** `project-memory` is the workflow gateway. `building-codebase-memory` is the deep specialist for foundational codebase memory. Do not keep both skills claiming ownership of generic project memory creation and refresh.

**Acceptance criteria:**
- `skills/building-codebase-memory/SKILL.md` exists with `name: building-codebase-memory`.
- `skills/project-memory/SKILL.md` no longer claims broad deep create/refresh ownership.
- `project-memory` explicitly delegates missing, stale, incomplete, or code-disagreeing foundational docs to `building-codebase-memory`.
- Static checks verify the new skill and delegation relationship.
- `using-superpowers`, `brainstorming`, and `writing-plans` route missing/stale foundational docs through `project-memory` and `building-codebase-memory` with no old `building-project-memory` references.
- `/context-start` documents delegation to `building-codebase-memory`.
- Eval prompts include the new skill split.

**Edge cases and negative cases:**
- Agent calls `building-codebase-memory` for a small `record-learning` update that belongs in `project-memory`.
- Agent uses `project-memory` to perform broad code archaeology instead of delegating.
- Existing install still has an old external `building-project-memory` skill; repository skills should use only `building-codebase-memory`.
- Static check misses old references because it only checks existence.
- `claude-mem` remains optional and absent-safe.

**Verification commands:**
- `bash tests/context-traceability/run-static-checks.sh`
- `rg -n "building-project-memory" skills commands tests docs/project-memory docs/superpowers/specs`
- `git diff --check`

**Known risks:**
- This changes behavior-shaping skill text; use `superpowers:writing-skills` before editing skills.
- `AGENTS.md` currently has an unrelated typechange. Do not stage or edit it.
- Long-running Claude eval scripts may still be unavailable locally because this environment lacks `timeout` and `claude`.

## File Structure

Create:
- `skills/building-codebase-memory/SKILL.md`: specialist skill for foundational codebase memory.
- `tests/skill-triggering/prompts/building-codebase-memory.txt`: naive trigger prompt for the new specialist.
- `tests/explicit-skill-requests/prompts/building-codebase-memory.txt`: explicit request prompt for the new specialist.

Modify:
- `skills/project-memory/SKILL.md`: gateway/delegation wording and modes.
- `skills/using-superpowers/SKILL.md`: routing table includes `building-codebase-memory`.
- `skills/brainstorming/SKILL.md`: project memory step names gateway plus specialist delegation.
- `skills/writing-plans/SKILL.md`: prerequisite names gateway plus specialist delegation.
- `commands/context-start.md`: command behavior includes delegation.
- `commands/review-memory.md`: review mode reports when deep refresh should be delegated.
- `tests/context-traceability/run-static-checks.sh`: verifies new skill and old-name absence.
- `tests/skill-triggering/prompts/project-memory.txt`: clarifies gateway behavior.
- `tests/explicit-skill-requests/prompts/project-memory.txt`: clarifies gateway behavior.

## Task 1: Strengthen Static Checks For Codebase Memory Split

**Files:**
- Modify: `tests/context-traceability/run-static-checks.sh`

- [ ] **Step 1: Update support skill list**

In `tests/context-traceability/run-static-checks.sh`, replace:

```bash
support_skills=(
  skills/project-memory/SKILL.md
  skills/context-traceability/SKILL.md
  skills/traceability-review/SKILL.md
)
```

with:

```bash
support_skills=(
  skills/project-memory/SKILL.md
  skills/building-codebase-memory/SKILL.md
  skills/context-traceability/SKILL.md
  skills/traceability-review/SKILL.md
)
```

- [ ] **Step 2: Add delegation and rename assertions**

After:

```bash
require_contains skills/using-superpowers/SKILL.md "project-memory"
require_contains skills/using-superpowers/SKILL.md "traceability-review"
```

add:

```bash
require_contains skills/using-superpowers/SKILL.md "building-codebase-memory"
require_contains skills/project-memory/SKILL.md "delegates to `building-codebase-memory`"
require_contains skills/project-memory/SKILL.md "Workflow Memory"
require_contains skills/project-memory/SKILL.md "Foundational Codebase Memory"
require_contains skills/building-codebase-memory/SKILL.md "Trust-Level Handoff"
require_contains skills/brainstorming/SKILL.md "building-codebase-memory"
require_contains skills/writing-plans/SKILL.md "building-codebase-memory"
require_contains commands/context-start.md "building-codebase-memory"
```

- [ ] **Step 3: Add old-name guard**

Before the `claude-mem` guard, add:

```bash
if grep -R "building-project-memory" skills commands tests docs/project-memory docs/superpowers/specs -n; then
  fail "Use building-codebase-memory instead of building-project-memory"
fi
```

- [ ] **Step 4: Run static check and verify it fails**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing required file: skills/building-codebase-memory/SKILL.md`.

- [ ] **Step 5: Commit the failing check**

```bash
git add tests/context-traceability/run-static-checks.sh
git commit -m "test: require codebase memory delegation"
```

## Task 2: Add `building-codebase-memory` Skill

**Files:**
- Create: `skills/building-codebase-memory/SKILL.md`

- [ ] **Step 1: Use skill-writing discipline**

Announce and use `superpowers:writing-skills` before creating the skill because this is behavior-shaping content.

Expected: the implementer reports that `writing-skills` was used before editing.

- [ ] **Step 2: Create the new skill**

Create `skills/building-codebase-memory/SKILL.md` with:

```markdown
---
name: building-codebase-memory
description: Use when working in an existing codebase and foundational architecture, structure, conventions, testing, integrations, or concern docs are missing, stale, incomplete, or inconsistent with code
---

# Building Codebase Memory

Create and refresh foundational codebase memory so future feature work can start from durable project docs instead of re-reading source from scratch.

## Overview

This is the deep codebase-memory specialist. Use it when `project-memory` finds missing, stale, incomplete, or code-disagreeing foundational docs.

`project-memory` owns workflow memory and routing. This skill owns foundational codebase mapping and refresh.

Use this skill to create or refresh:

- `docs/project-memory/STACK.md`
- `docs/project-memory/ARCHITECTURE.md`
- `docs/project-memory/STRUCTURE.md`
- `docs/project-memory/CONVENTIONS.md`
- `docs/project-memory/TESTING.md`
- `docs/project-memory/INTEGRATIONS.md`
- `docs/project-memory/CONCERNS.md`

User preferences for artifact location override this default.

## Checklist

You MUST complete these in order:

1. **Check existing memory** — read current memory docs, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, README, architecture docs
2. **Assess freshness** — inspect relevant codebase areas and decide whether docs are missing, stale, partial, or sufficient
3. **Map the codebase** — inspect entrypoints, structure, shared components, data flow, tests, integrations, and current pain points
4. **Write or refresh foundational memory** — create or update only the docs needed for current accuracy
5. **Summarize trust level** — state which docs are authoritative, partial, and still need source verification
6. **Hand off** — tell `project-memory` and the next workflow step which docs to read

## When To Create vs Refresh

Create from scratch when:

- `docs/project-memory/` does not exist
- the project has no durable architecture, structure, convention, testing, integration, or concern docs
- existing docs are obviously incomplete or abandoned

Refresh selectively when:

- only some areas changed
- the task only touches a few subsystems
- existing docs are mostly correct

Avoid rewriting everything if a focused refresh will do.

## What Each Artifact Must Capture

### `STACK.md`

- languages, frameworks, build tools, package managers
- persistence, networking, backend dependencies
- test frameworks and local dev/runtime requirements

### `ARCHITECTURE.md`

- top-level architecture and boundaries
- source-of-truth layers and data flow
- where business logic lives
- state ownership and dependency flow

### `STRUCTURE.md`

- repo layout and important modules/directories
- entrypoints and feature organization
- where to add new code for common feature types

### `CONVENTIONS.md`

- naming, file organization, code style, dependency injection
- UI/component patterns and state management patterns when applicable
- explicit guidance about patterns to follow rather than reinvent

### `TESTING.md`

- test pyramid in practice for this repo
- frameworks, commands, naming patterns, fixtures
- what must be covered before a feature is considered done

### `INTEGRATIONS.md`

- external APIs, services, SDKs, background jobs, feature flags
- where integration code lives
- auth/config/secrets boundaries relevant to development

### `CONCERNS.md`

- known risks, legacy hotspots, flaky areas, coupling, migration seams
- things planners and implementers must be careful not to break

## Mapping Rules

- Prefer facts from code over guesses from filenames.
- Follow existing terminology from the repo. Do not rename concepts.
- Distinguish clearly between observed fact, likely inference, and open question.
- If a detail is uncertain, say so explicitly rather than pretending.
- Summaries should be high-signal and skimmable. Avoid dumping raw notes.

## Output Style

Each artifact should be concise and operational:

- short sections
- concrete paths/modules
- specific patterns to follow
- no generic textbook explanations

Write docs for future agents and engineers who need to move quickly:

- Where do I change this?
- What pattern does this repo expect?
- What will I break if I do this wrong?

## Trust-Level Handoff

After writing or refreshing foundational memory, report:

```text
Authoritative memory
- Files that match inspected source.

Partial memory
- Files or sections that are useful but based on limited inspection.

Still needs source verification
- Areas not inspected or facts that remain uncertain.

Recommended next workflow step
- One command or skill, such as project-memory, brainstorming, or writing-plans.
```

## Relationship To Other Skills

- `project-memory` delegates to this skill for deep foundational memory creation and refresh.
- `brainstorming` should rely on `project-memory`; `project-memory` invokes this skill when foundational docs are missing or stale.
- `writing-plans` should rely on `project-memory`; `project-memory` invokes this skill when foundational docs are missing or stale.
- `context-traceability` consumes the memory this skill creates when building context packets.
```

- [ ] **Step 3: Run static check and verify the next failure**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing pattern in skills/using-superpowers/SKILL.md: building-codebase-memory`.

- [ ] **Step 4: Commit the new skill**

```bash
git add skills/building-codebase-memory/SKILL.md
git commit -m "feat: add codebase memory builder skill"
```

## Task 3: Narrow `project-memory` To Gateway And Delegation

**Files:**
- Modify: `skills/project-memory/SKILL.md`

- [ ] **Step 1: Replace overview and core principle**

In `skills/project-memory/SKILL.md`, replace the paragraph under `# Project Memory` through the `## Core Principle` paragraph with:

```markdown
Read, summarize, route, record, and review durable project memory during traceable workflows.

## Core Principle

Project memory is a briefing pack, not an oracle. Prefer observed repository facts. Label inferences. Preserve open questions. If foundational memory and code disagree, delegate deep refresh to `building-codebase-memory`.

`project-memory` is the workflow gateway. It does not perform broad codebase archaeology. It delegates to `building-codebase-memory` when foundational codebase memory is missing, stale, incomplete, or inconsistent with code.
```

- [ ] **Step 2: Replace memory surface section**

Replace `## Memory Surface` through the optional list with:

```markdown
## Memory Surface

Use `docs/project-memory/` unless the human partner explicitly chooses a different location.

### Foundational Codebase Memory

Owned by `building-codebase-memory`:

- `STACK.md`
- `ARCHITECTURE.md`
- `STRUCTURE.md`
- `CONVENTIONS.md`
- `TESTING.md`
- `INTEGRATIONS.md`
- `CONCERNS.md`

### Workflow Memory

Owned by `project-memory`:

- `FEATURE_CONTEXT.md`
- `BUG_PATTERNS.md`
- `SPEC_INDEX.md`
- `ACTIVE_CONTEXT.md`
```

- [ ] **Step 3: Replace Start mode**

Replace the `### Start` mode body with:

```markdown
Use at the beginning of work in an existing codebase.

1. Check whether `docs/project-memory/` exists.
2. Read existing memory docs relevant to the current task.
3. Classify foundational memory as authoritative, partial, missing, stale, or inconsistent with code.
4. If foundational docs are missing, stale, incomplete, or inconsistent with code, invoke `building-codebase-memory` before feature work continues.
5. Read `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, `BUG_PATTERNS.md`, and `ACTIVE_CONTEXT.md` when present.
6. Output a compact context summary, related artifacts, memory trust level, missing or untrusted memory, and a recommended next command.
```

- [ ] **Step 4: Replace Review mode**

Replace the `### Review` mode numbered list with:

```markdown
1. Read all `docs/project-memory/*.md`.
2. Compare memory against current repo structure and recent specs/plans.
3. Report stale facts, missing files, duplicate information, missing feature context, missing bug patterns, stale `SPEC_INDEX.md` entries, and foundational docs that need `building-codebase-memory`.
4. Ask for approval before editing workflow memory files.
5. Delegate broad foundational refreshes to `building-codebase-memory` rather than editing them here.
```

- [ ] **Step 5: Add delegation section**

After the Review mode, add:

```markdown
## Delegation Rule

Use `building-codebase-memory` for deep creation or refresh of foundational codebase memory:

- architecture or structure docs are missing
- conventions or testing docs are stale
- integrations or concerns need source inspection
- memory disagrees with code
- refresh requires broad archaeology across multiple unrelated areas

Stay in `project-memory` for workflow memory:

- summarizing relevant memory
- routing to specs/plans/code paths
- recording feature context
- recording bug patterns
- updating `SPEC_INDEX.md`
- updating `ACTIVE_CONTEXT.md`
- reviewing memory freshness and recommending next commands
```

- [ ] **Step 6: Run static check and verify next failure**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: FAIL with `Missing pattern in skills/using-superpowers/SKILL.md: building-codebase-memory`.

- [ ] **Step 7: Commit project-memory narrowing**

```bash
git add skills/project-memory/SKILL.md
git commit -m "feat: make project memory delegate codebase mapping"
```

## Task 4: Update Routing Skills And Commands

**Files:**
- Modify: `skills/using-superpowers/SKILL.md`
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `commands/context-start.md`
- Modify: `commands/review-memory.md`

- [ ] **Step 1: Update `using-superpowers` support skill bullets**

In `skills/using-superpowers/SKILL.md`, replace:

```markdown
- Use `project-memory` when starting in an existing codebase, refreshing durable context, recording learnings, or reviewing `docs/project-memory/`.
```

with:

```markdown
- Use `project-memory` when starting in an existing codebase, summarizing durable context, recording learnings, routing to specs/plans, or reviewing `docs/project-memory/`.
- Use `building-codebase-memory` when foundational architecture, structure, conventions, testing, integrations, or concern docs are missing, stale, incomplete, or inconsistent with code.
```

- [ ] **Step 2: Update `using-superpowers` command table**

In the command table, replace:

```markdown
| `/context-start` or `Context start:` | `project-memory` |
```

with:

```markdown
| `/context-start` or `Context start:` | `project-memory`, with `building-codebase-memory` when foundational memory is missing or stale |
```

- [ ] **Step 3: Update `brainstorming` checklist**

In `skills/brainstorming/SKILL.md`, replace:

```markdown
2. **Establish project memory for existing codebases** — if durable architecture/convention/testing/concern docs are missing or stale, invoke `project-memory`
```

with:

```markdown
2. **Establish project memory for existing codebases** — invoke `project-memory`; if foundational architecture/convention/testing/concern docs are missing or stale, it delegates to `building-codebase-memory`
```

- [ ] **Step 4: Update `brainstorming` process bullet**

In `skills/brainstorming/SKILL.md`, replace:

```markdown
- In existing codebases, prefer durable project memory over repeated archaeology. If `docs/project-memory/` is missing or stale, invoke `project-memory` before design work continues.
```

with:

```markdown
- In existing codebases, prefer durable project memory over repeated archaeology. Invoke `project-memory` before design work continues; it delegates to `building-codebase-memory` when foundational codebase docs are missing, stale, incomplete, or inconsistent with code.
```

- [ ] **Step 5: Update `writing-plans` prerequisite**

In `skills/writing-plans/SKILL.md`, replace:

```markdown
- If those docs are missing or stale, stop and invoke `project-memory` before continuing.
```

with:

```markdown
- If those docs are missing or stale, stop and invoke `project-memory`; it delegates foundational refreshes to `building-codebase-memory` before planning continues.
```

- [ ] **Step 6: Update `context-start` command**

In `commands/context-start.md`, replace:

```markdown
Use `project-memory` in start mode. If a task summary is provided, also use `context-traceability` to discover related specs, plans, memory files, and likely code paths.
```

with:

```markdown
Use `project-memory` in start mode. If foundational codebase memory is missing or stale, invoke `building-codebase-memory` before continuing. If a task summary is provided, also use `context-traceability` to discover related specs, plans, memory files, and likely code paths.
```

- [ ] **Step 7: Update `review-memory` command**

In `commands/review-memory.md`, replace:

```markdown
Use `project-memory` in review mode, then use `traceability-review` in `memory-review` mode for the report. Ask before editing memory files.
```

with:

```markdown
Use `project-memory` in review mode, then use `traceability-review` in `memory-review` mode for the report. Ask before editing workflow memory files. Delegate broad foundational refreshes to `building-codebase-memory`.
```

- [ ] **Step 8: Run static check and verify it passes or reaches eval prompt failure**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 9: Commit routing updates**

```bash
git add skills/using-superpowers/SKILL.md skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md commands/context-start.md commands/review-memory.md
git commit -m "feat: route foundational memory to codebase builder"
```

## Task 5: Update Eval Prompts For Memory Split

**Files:**
- Create: `tests/skill-triggering/prompts/building-codebase-memory.txt`
- Create: `tests/explicit-skill-requests/prompts/building-codebase-memory.txt`
- Modify: `tests/skill-triggering/prompts/project-memory.txt`
- Modify: `tests/explicit-skill-requests/prompts/project-memory.txt`

- [ ] **Step 1: Create naive trigger prompt**

Create `tests/skill-triggering/prompts/building-codebase-memory.txt` with:

```text
This is an existing codebase and its architecture, conventions, testing, integrations, and concern docs are missing or stale. Inspect the relevant codebase areas and create durable foundational memory docs before feature planning.
```

- [ ] **Step 2: Create explicit request prompt**

Create `tests/explicit-skill-requests/prompts/building-codebase-memory.txt` with:

```text
Please use building-codebase-memory to refresh the foundational architecture, structure, conventions, testing, integrations, and concerns docs for this existing codebase.
```

- [ ] **Step 3: Update project-memory naive prompt**

Replace `tests/skill-triggering/prompts/project-memory.txt` with:

```text
This is an existing codebase. Start by summarizing durable project context, related specs, active workflow memory, missing or untrusted memory, and the next command. If foundational codebase docs are stale, say that they should be delegated to the codebase memory builder.
```

- [ ] **Step 4: Update project-memory explicit prompt**

Replace `tests/explicit-skill-requests/prompts/project-memory.txt` with:

```text
Please use project-memory to audit docs/project-memory, summarize workflow context, identify missing or untrusted memory, and recommend whether building-codebase-memory is needed before brainstorming.
```

- [ ] **Step 5: Run static check**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 6: Commit eval prompt updates**

```bash
git add tests/skill-triggering/prompts/building-codebase-memory.txt tests/explicit-skill-requests/prompts/building-codebase-memory.txt tests/skill-triggering/prompts/project-memory.txt tests/explicit-skill-requests/prompts/project-memory.txt
git commit -m "test: add codebase memory eval prompts"
```

## Task 6: Refresh Memory Index And Final Verification

**Files:**
- Modify: `docs/project-memory/SPEC_INDEX.md`
- Modify: `docs/project-memory/FEATURE_CONTEXT.md`

- [ ] **Step 1: Update `FEATURE_CONTEXT.md`**

Add this section to `docs/project-memory/FEATURE_CONTEXT.md` after `## Invariants`:

```markdown
## Memory Skill Roles

- **project-memory:** Workflow gateway for reading, summarizing, routing, recording, reviewing, and next-command handoff.
- **building-codebase-memory:** Deep specialist for creating or refreshing foundational codebase memory such as architecture, structure, conventions, testing, integrations, and concerns.
```

- [ ] **Step 2: Update `SPEC_INDEX.md` status row**

In `docs/project-memory/SPEC_INDEX.md`, replace the context traceability row with:

```markdown
| Context traceability slash commands | Implemented with follow-up memory split planned | `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md` | `docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`, `docs/superpowers/plans/2026-05-04-codebase-memory-delegation.md` | `docs/project-memory/FEATURE_CONTEXT.md`, `docs/project-memory/CONCERNS.md` | Follow-up separates `project-memory` gateway from `building-codebase-memory` specialist. |
```

- [ ] **Step 3: Run final static verification**

Run:

```bash
bash tests/context-traceability/run-static-checks.sh
```

Expected: PASS with `[PASS] Context traceability static checks passed`.

- [ ] **Step 4: Confirm old name is gone**

Run:

```bash
rg -n "building-project-memory" skills commands tests docs/project-memory docs/superpowers/specs
```

Expected: exit 1 with no output.

- [ ] **Step 5: Check formatting**

Run:

```bash
git diff --check
```

Expected: no output and exit 0.

- [ ] **Step 6: Note unavailable long-running evals**

If `timeout` or `claude` are unavailable, record that the skill-triggering eval scripts were not run. Do not claim they passed.

- [ ] **Step 7: Commit memory index updates**

```bash
git add docs/project-memory/SPEC_INDEX.md docs/project-memory/FEATURE_CONTEXT.md
git commit -m "docs: record codebase memory role split"
```

## Self-Review

**Spec coverage:** This plan covers the new `building-codebase-memory` skill, `project-memory` gateway/delegation behavior, `/context-start` delegation, routing skill updates, static checks, eval prompts, trust-level handoff, old-name removal, and memory index updates.

**Placeholder scan:** The plan uses concrete file paths, exact Markdown content, exact shell commands, and expected outputs. It avoids deferrals and implementation gaps.

**Pressure-test:** The sequence starts with a failing static check, adds the missing specialist skill, narrows `project-memory`, updates routing and commands, updates eval prompts, then refreshes memory docs and verifies. No task depends on a later file being present.
