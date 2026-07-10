---
name: context-traceability
description: Use when linking current work to project memory, related specs, plans, code, tests, command state, context packets, or traceability gates before brainstorming, planning, implementation, debugging, review, or finishing
---

# Context Traceability

Discover related context and keep each workflow phase traceable from discussion to memory, spec, plan, manual test artifact, code, tests, and bug learnings.

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

1. Read the plan, referenced spec, context packet, and linked manual test artifact when present.
2. Verify the plan names related specs, memory files, likely code paths, affected existing features, edge cases, manual test artifact path, and verification commands.
3. Prepare a subagent-ready context packet that includes manual test expectations, affected existing features, touched code paths, and human-run setup requirements.
4. If context is partial, say which artifacts are missing before dispatch.

### `debug-preflight`

1. Read `BUG_PATTERNS.md`, `FEATURE_CONTEXT.md`, `SPEC_INDEX.md`, relevant specs/plans, and the linked manual test artifact when present.
2. Establish expected behavior before root-cause investigation.
3. Prepare an evidence trail with observations, hypotheses, experiments, root cause, fix, automated verification, manual regression impact, and memory/spec/manual-test updates.

### `spec-update`

1. Resolve the most relevant spec through `SPEC_INDEX.md`, filenames, and content search.
2. Ask the human partner to choose when multiple specs match.
3. Update behavior through the spec before implementation.
4. Update the linked manual test artifact when human-verifiable behavior, setup, expected results, negative cases, or regression cases change.
5. Trigger spec review after the update.

## Command State

Persist enough state for new conversations:

- `docs/project-memory/SPEC_INDEX.md`: feature, status, spec, plan, related memory, notes.
- `docs/project-memory/ACTIVE_CONTEXT.md`: active pointers only.
- Spec metadata: status, related specs, related plans, owning command, last review date, manual test artifact path or not-applicable reason.
- Plan metadata: referenced spec, status, context packet, related specs, verification commands, manual test artifact path.

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

Manual test artifact, case budget, affected existing features, touched code paths, and manual QA status:

Known risks, open questions, and untrusted context:
```

Keep the packet small enough to paste into a subagent prompt. Include paths so workers can read full artifacts when needed.

## Subagent Injection

Before dispatching implementer, reviewer, debugger, or explorer subagents:

1. Include the context packet in the prompt.
2. Name the spec, plan, manual test artifact when present, memory files, and code paths the subagent must read.
3. Tell the subagent to stop and ask if required context is missing.
4. Keep file-based project memory as the source of truth even when optional memory search tools are available.

## Optional External Memory

If `claude-mem` or another memory search tool is available, you may query it for prior discussion hints. The workflow must degrade gracefully when it is absent.
