# Architecture

## Top-Level Model

Superpowers is a workflow plugin made of composable skills plus startup instructions that force agents to load the relevant skill before acting.

The core runtime boundary is intentionally simple:

- `hooks/session-start` injects the full `using-superpowers` skill at session start for hook-capable harnesses.
- `skills/using-superpowers/SKILL.md` teaches the agent when and how to load other skills.
- Each `skills/*/SKILL.md` file owns one behavior-shaping workflow or technique.
- `commands/*.md` provide convenience entry points for some harnesses.
- Tests verify skill triggering, explicit skill requests, subagent workflows, and browser companion behavior.

## Workflow Shape

The default software-development flow is:

1. `brainstorming`
2. `using-git-worktrees`
3. `writing-plans`
4. `subagent-driven-development` or `executing-plans`
5. `test-driven-development`
6. `requesting-code-review`
7. `finishing-a-development-branch`

Skills are treated as executable behavioral code, not prose. Changes to skills require eval evidence.

## Source Of Truth

- User-facing philosophy and install docs: `README.md`.
- Agent contribution rules: `CLAUDE.md` and `.github/PULL_REQUEST_TEMPLATE.md`.
- Skill behavior: each `skills/*/SKILL.md`.
- Existing design records: `docs/superpowers/specs/`.
- Existing implementation plans: `docs/superpowers/plans/` and `docs/plans/`.

## Integration Boundaries

- Harness-specific startup behavior belongs in `hooks/`, install docs, or generated plugin overlays.
- Shared workflow behavior belongs in `skills/`.
- Codex plugin mirroring is handled by `scripts/sync-to-codex-plugin.sh`; generated Codex metadata is not part of core source.
- Third-party memory/search systems should be treated as external integrations or separate plugins unless a core, dependency-free abstraction is being proposed.
