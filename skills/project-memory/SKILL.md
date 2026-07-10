---
name: project-memory
description: Use when starting work in an existing codebase, summarizing durable workflow context, recording reusable learnings, routing to specs or plans, or auditing docs/project-memory before brainstorming, planning, implementation, debugging, or review
---

# Project Memory

Read, summarize, route, record, and review durable project memory during traceable workflows.

## Core Principle

Project memory is a briefing pack, not an oracle. Prefer observed repository facts. Label inferences. Preserve open questions. If foundational memory and code disagree, delegate deep refresh to `building-codebase-memory`.

`project-memory` is the workflow gateway. It does not perform broad codebase archaeology. It delegates to `building-codebase-memory` when foundational codebase memory is missing, stale, incomplete, or inconsistent with code.

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

## Modes

### Start

Use at the beginning of work in an existing codebase.

1. Check whether `docs/project-memory/` exists.
2. Read existing memory docs relevant to the current task.
3. Classify foundational memory as authoritative, partial, missing, stale, or inconsistent with code.
4. If foundational docs are missing, stale, incomplete, or inconsistent with code, invoke `building-codebase-memory` before feature work continues.
5. Read `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, `BUG_PATTERNS.md`, and `ACTIVE_CONTEXT.md` when present.
6. Output a compact context summary, related artifacts, memory trust level, missing or untrusted memory, and a recommended next command.

### Record

Use when the human partner says to remember a lesson or when a workflow discovers durable context.

1. Classify the lesson as feature context, bug pattern, spec relationship, active context, or foundational codebase fact.
2. Write directly only to workflow memory: `FEATURE_CONTEXT.md`, `BUG_PATTERNS.md`, `SPEC_INDEX.md`, or `ACTIVE_CONTEXT.md`.
3. Link related specs, plans, code paths, or commits when known.
4. Propose a foundational memory update instead of editing foundational docs directly when the lesson affects architecture, structure, conventions, testing, integrations, or concerns.
5. If the proposed foundational update needs source inspection or broad refresh, delegate to `building-codebase-memory`.
6. Keep entries operational and short.

### Review

Use for `/review-memory`.

1. Read all `docs/project-memory/*.md`.
2. Compare against current repo structure and recent specs/plans.
3. Report stale facts, missing files, duplicate information, missing feature context, missing bug patterns, stale `SPEC_INDEX.md` entries, and foundational docs that need `building-codebase-memory`.
4. Ask for approval before editing workflow memory files.
5. Delegate broad foundational refreshes to `building-codebase-memory` rather than editing them here.

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
