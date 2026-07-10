# Integrations

## Harnesses

Superpowers documents support for Claude Code, Cursor, Codex, OpenCode, GitHub Copilot CLI, and Gemini CLI. Recent commits also touch Codex plugin mirroring.

## Hook Surface

- `hooks/session-start` injects `using-superpowers` into new sessions.
- `hooks/hooks.json` configures Claude Code-style `SessionStart` behavior.
- `hooks/hooks-cursor.json` configures Cursor-style session start behavior.
- The hook output format branches by environment variables such as `CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`, and `COPILOT_CLI`.

## Codex Plugin Sync

- `scripts/sync-to-codex-plugin.sh` mirrors source into `prime-radiant-inc/openai-codex-plugins`.
- The script excludes non-shipped core paths and generates `.codex-plugin/plugin.json`.
- It requires authenticated GitHub CLI access and is intentionally deterministic.

## Third-Party Memory Systems

- The project currently has no built-in dependency on external memory databases, MCP servers, vector stores, or hosted services.
- A third-party memory integration such as `claude-mem` would cross the core/plugin boundary unless framed as a separate optional plugin or absent-safe dependency-free design guidance.

## Upstream PR Context

- GitHub API search found an open upstream PR titled `feat(skills): add project memory workflow` at `obra/superpowers#880`.
- Other open context/memory-related PRs include `#1129`, `#1113`, and `#935`.
- Any upstream-facing memory work must explicitly address this prior art.
