# Testing

## Test Areas

- `tests/skill-triggering/`: verifies natural prompts trigger expected skills.
- `tests/explicit-skill-requests/`: verifies named skills are loaded before work begins.
- `tests/claude-code/`: long-running Claude Code integration tests for complex workflows.
- `tests/subagent-driven-dev/`: fixture projects for subagent-driven development.
- `tests/brainstorm-server/`: Node tests for the browser companion server and protocol.
- `tests/opencode/`: OpenCode plugin loading and priority checks.

## Commands

- Brainstorm server tests: inspect `tests/brainstorm-server/package.json`; typical flow is install dependencies there and run the Node test suite.
- Claude Code integration tests: run from the superpowers plugin directory using scripts under `tests/claude-code/`.
- Skill trigger checks: use `tests/skill-triggering/run-test.sh` and `tests/explicit-skill-requests/run-test.sh`.

## Skill Change Requirements

- Skill changes require before/after evals, not only manual inspection.
- For new or modified skills, use `writing-skills`, run adversarial pressure testing across multiple sessions, and report the results.
- Changes to Red Flags tables, rationalization lists, or other tuned language need especially strong evidence.

## Trust Notes

- Some integration tests require external CLIs and can take 10-30 minutes.
- The local environment may not have all harnesses installed.
- Passing shell/unit tests does not replace skill eval evidence when behavior changes.
