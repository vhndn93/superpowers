---
name: building-codebase-memory
description: Use when working in an existing codebase and foundational architecture, structure, conventions, testing, integrations, or concern docs are missing, stale, incomplete, or inconsistent with code
---

# Building Codebase Memory

Create and refresh foundational codebase memory so future work starts from durable docs instead of repeated source archaeology.

## Overview

This is the deep codebase-memory specialist. Use it when directly requested or when `project-memory` finds missing, stale, incomplete, or code-disagreeing foundational docs.

`project-memory` owns workflow memory and routing. This skill owns foundational codebase mapping and refresh.

Default target docs: `STACK.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, `INTEGRATIONS.md`, and `CONCERNS.md` under `docs/project-memory/`. User preferences override this location.

## Checklist

You MUST complete these in order:

1. **Check existing memory** - read current memory docs, `AGENTS.md`, README, and architecture docs.
2. **Assess freshness** - inspect relevant source and classify docs as missing, stale, partial, or sufficient.
3. **Map the codebase** - inspect entrypoints, structure, data flow, tests, integrations, and pain points.
4. **Write or refresh only needed foundational docs** from current source facts.
5. **Hand off trust level** - report authoritative, partial, and still-unverified docs plus next workflow step.

## When To Create vs Refresh

Create from scratch when the project has no durable foundational docs or existing docs are abandoned. Refresh selectively when only some areas changed or a focused source check is enough. Avoid rewriting everything when a narrow refresh will do.

## Artifact Focus

| File | Capture |
| --- | --- |
| `STACK.md` | languages, frameworks, build tools, package managers, runtime requirements |
| `ARCHITECTURE.md` | boundaries, source-of-truth layers, data flow, state ownership |
| `STRUCTURE.md` | repo layout, entrypoints, module organization, where new code belongs |
| `CONVENTIONS.md` | naming, file organization, dependency patterns, patterns to follow |
| `TESTING.md` | frameworks, commands, fixtures, coverage expectations |
| `INTEGRATIONS.md` | external APIs, SDKs, services, auth/config/secrets boundaries |
| `CONCERNS.md` | risks, hotspots, flaky areas, coupling, migration hazards |

## Mapping Rules

- Prefer code facts over filenames or guesses.
- Use existing repo terminology; do not rename concepts.
- Label observed fact, likely inference, and open question.
- Keep docs concise and operational: paths, modules, patterns to follow, and risks to avoid.

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

- `project-memory` delegates deep foundational creation and refresh here.
- `brainstorming` and `writing-plans` rely on `project-memory`; it invokes this skill when foundational docs are missing or stale.
- `context-traceability` consumes these docs when building context packets.
