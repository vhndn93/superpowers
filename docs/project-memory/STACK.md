# Stack

## Observed

- Superpowers is primarily a Markdown skill library with small shell/JavaScript support scripts.
- `package.json` declares an npm package named `superpowers`, version `5.0.7`, with `"type": "module"` and no runtime dependencies.
- Skills live as `skills/<skill-name>/SKILL.md`.
- Shell scripts power hooks, tests, release/version helpers, and Codex plugin sync.
- The browser brainstorming companion uses Node scripts under `skills/brainstorming/scripts/`.
- Test coverage is shell-heavy, with some Node-based tests for the brainstorming server.

## Tooling

- Required baseline tools: `bash`, `git`, and platform-specific agent CLIs for integration tests.
- `scripts/sync-to-codex-plugin.sh` additionally requires `rsync`, `gh`, and `python3`.
- Claude Code integration tests require the `claude` command and a development plugin setup.
- Brainstorm server tests use the npm package under `tests/brainstorm-server/`.

## External Dependencies

- The core project is intentionally zero-dependency for shipped skills.
- New third-party service/tool integrations are rejected from core unless they add support for a new harness.
- Tool-specific, domain-specific, or personal workflows belong in separate plugins.
