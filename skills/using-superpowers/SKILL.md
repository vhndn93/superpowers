---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are Superpowers' most common process skills, but the rule holds for any of them.

- "Let's build X" → superpowers:brainstorming first, then implementation skills.
- "Fix this bug" → superpowers:systematic-debugging first, then domain skills.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Platform Adaptation

If your harness appears here, read its reference file for special instructions:

- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`

## Skill Priority

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, mcp-builder) - these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Traceable Workflow Routing

When work touches an existing codebase, project memory, specs, plans, implementation, debugging, review, or finishing, consider these support skills before acting:

- Use `project-memory` when starting in an existing codebase, summarizing durable context, recording learnings, routing to specs/plans, or reviewing `docs/project-memory/`.
- Use `building-codebase-memory` when foundational architecture, structure, conventions, testing, integrations, or concern docs are missing, stale, incomplete, or inconsistent with code.
- Use `context-traceability` when a task needs related specs/plans/code, command state, context packets, spec updates, or subagent context injection.
- Use `traceability-review` when reviewing a spec, plan, implementation, bug fix, memory pack, or full active workflow chain.

Command-like prompts map to skills:

| Prompt shape | Required skill |
| --- | --- |
| `/context-start` or `Context start:` | `project-memory`, with `building-codebase-memory` when foundational memory is missing or stale |
| `/brainstorm-feature` or `Brainstorm feature:` | `brainstorming` plus `context-traceability` |
| `/write-spec` or `Write spec` | `brainstorming` plus `traceability-review` |
| `/plan-spec` or `Plan spec:` | `writing-plans` plus `context-traceability` |
| `/review-spec`, `/review-plan`, `/review-implementation`, `/review-bug-fix`, `/review-traceability` | `traceability-review` |
| `/implement-plan` or `Implement plan:` | `subagent-driven-development` or `executing-plans` |
| `/debug-with-memory` or `Debug with memory:` | `systematic-debugging` plus `context-traceability` |
| `/update-spec` or `Update spec:` | `context-traceability` |
| `/record-learning` or `Record learning:` | `project-memory` |
| `/finish-traceable` or `Finish traceable work` | `verification-before-completion` plus `traceability-review` |

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, GEMINI.md, etc, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.
