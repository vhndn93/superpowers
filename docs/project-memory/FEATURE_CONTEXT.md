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

## Memory Skill Roles

- **project-memory:** Workflow gateway for reading, summarizing, routing, recording, reviewing, and next-command handoff.
- **building-codebase-memory:** Deep specialist for creating or refreshing foundational codebase memory such as architecture, structure, conventions, testing, integrations, and concerns.

## Repeated Corrections

- Do not add `claude-mem` as a required or optional core dependency.
- Do not create duplicate workflows named after slash commands when an existing skill owns the phase.
- Keep fork-specific workflow additions separate from upstream PR claims until there is evidence and human review.

## Orchestrator Skill Pattern

The `feature-workflow` skill is the first orchestrator skill in Superpowers. It defines a pattern for composing existing skills into a multi-phase workflow with explicit gate checks.

### Pattern Rules

1. **Orchestrator skills delegate, never duplicate.** Each phase invokes an existing skill for its behavior. The orchestrator defines when, how, and in what order.
2. **Gate checks are explicit.** Each phase boundary has a gate that blocks transition until conditions are met (review pass, user confirmation, test pass).
3. **State is file-based.** `ACTIVE_CONTEXT.md` tracks current phase, gate status, and artifact paths. This enables session resume.
4. **Review loops iterate until clean.** If `traceability-review` finds issues, fix and re-review. No transition until clean.
5. **Fallback paths are defined.** If a preferred skill is unavailable (e.g., subagents), fall back to an alternative (e.g., executing-plans).
6. **Harness-agnostic entry.** The skill works via slash command (`/start-feature`) or natural prompt across all supported harnesses.

### Delegated Skills by Phase

| Phase | Primary Skill | Review Skill | Gate Condition |
|-------|--------------|--------------|----------------|
| Discovery | brainstorming (design capture only) | — | User confirmation |
| Spec | brainstorming (/write-spec) | traceability-review (spec-review) + context-traceability (/update-spec) | No open findings |
| Plan | writing-plans | traceability-review (plan-review) | No open findings |
| Implement | subagent-driven-development | traceability-review (implementation-review) | No open findings + tests pass |
| Test | — | — | Manual tests pass (human-reported) |

### When to Use This Pattern

Use the orchestrator pattern when:
- A workflow has 3+ distinct phases with different skill requirements
- Each phase has clear entry/exit criteria
- Session interruption and resume is important
- Multiple harnesses need to support the same workflow

Do NOT use this pattern for single-phase workflows or when a single existing skill already covers the entire workflow.
