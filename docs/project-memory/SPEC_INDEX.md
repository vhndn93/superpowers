# Spec Index

Fast routing index for specs, plans, implementation state, and related project memory.

This index helps commands choose relevant artifacts. It does not replace reading the actual spec or plan.

| Feature | Status | Spec | Plan | Related Memory | Notes |
| --- | --- | --- | --- | --- | --- |
| Context traceability slash commands | Implemented with follow-up manual test workflow planned | `docs/superpowers/specs/2026-05-04-context-traceability-slash-commands-design.md` | `docs/superpowers/plans/2026-05-04-context-traceability-slash-commands.md`, `docs/superpowers/plans/2026-05-04-codebase-memory-delegation.md`, `docs/superpowers/plans/2026-05-07-manual-test-artifact-workflow.md` | `docs/project-memory/FEATURE_CONTEXT.md`, `docs/project-memory/CONCERNS.md`, `docs/superpowers/manual-tests/2026-05-07-manual-test-artifact-workflow-manual-tests.md` | Follow-up separates `project-memory` gateway from `building-codebase-memory` specialist and adds traceable manual QA artifacts. |
| Feature workflow — 5-phase orchestrated development | Implemented; merged with v6.1.1 | `docs/superpowers/specs/2026-05-18-feature-workflow-design.md` | `docs/superpowers/plans/2026-05-18-feature-workflow.md` | `docs/project-memory/FEATURE_CONTEXT.md`, `docs/superpowers/manual-tests/2026-05-18-feature-workflow-manual-tests.md` | Orchestrator skill for structured 5-phase feature development; automated structural checks pass and manual QA remains not run. |
