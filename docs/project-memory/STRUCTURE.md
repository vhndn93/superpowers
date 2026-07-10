# Structure

## Important Paths

- `skills/`: canonical skill library. Add or modify skills here only after using `writing-skills` and gathering eval evidence.
- `skills/brainstorming/scripts/`: zero-dependency browser companion server and helper scripts.
- `commands/`: prompt entry points for brainstorming, planning, and plan execution.
- `hooks/`: session-start hook definitions for Claude Code and Cursor-style harnesses.
- `scripts/`: release, sync, and utility scripts. `sync-to-codex-plugin.sh` mirrors core into the Codex plugin repository.
- `tests/`: shell and Node tests for skill triggering, explicit skill requests, subagent behavior, OpenCode support, and brainstorming server behavior.
- `docs/superpowers/specs/`: approved design docs from brainstorming.
- `docs/superpowers/plans/`: implementation plans derived from approved specs.
- `docs/project-memory/`: durable codebase briefing pack for future work.

## Where To Add Things

- New general-purpose behavior workflow: `skills/<new-skill>/SKILL.md`, after design, writing-skills, and evals.
- Refinement to an existing workflow: the relevant `skills/*/SKILL.md`, with narrow scope and before/after eval evidence.
- Harness support: harness docs, hooks, or install/sync tooling, not unrelated skill content.
- Personal or third-party integrations: separate plugin, not core.
- Design-only proposal: `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`.

## Current Memory-Relevant Context

- There is no built-in persistent memory database or external retrieval service in core.
- The repo does contain workflow docs and specs, and now this `docs/project-memory/` pack.
- Upstream has open memory/context-related PRs, so duplicate work must be checked before proposing upstream changes.
