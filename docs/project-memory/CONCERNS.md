# Concerns

## High-Risk Areas

- Behavior-shaping skill text is high risk. Small wording changes can alter agent behavior and require eval evidence.
- The project has strict anti-slop contribution rules and a stated high PR rejection rate.
- Third-party integrations are explicitly rejected from core unless they add harness support.
- Memory/context improvements are already an active upstream area, so duplicate PR risk is high.

## Current Task Risks

- Directly adding `claude-mem` to core would likely violate the zero-dependency and third-party integration policies; any use must remain optional and absent-safe.
- Borrowing broad GSD concepts wholesale would likely be too large, bundled, or philosophy-changing for one PR.
- A memory feature without a concrete session failure and before/after evals would be speculative.
- A fork-only customization should not be presented as upstream-ready.

## Safer Direction

- Treat `claude-mem` as inspiration for a separate plugin or optional personal workflow, not core.
- Treat GSD as prior art for workflow ideas such as context budgets, minimal install surfaces, state files, validation gates, and continuation handoff.
- For upstream core, prefer one narrow, dependency-free improvement tied to a real failure mode and backed by evals.

## Open Questions

- Whether the target is a private fork enhancement, an upstream PR to `obra/superpowers`, or a standalone plugin.
- What concrete memory failure motivated the request: lost project context, poor resume after compaction, missed prior decisions, or weak retrieval of past sessions.
- Which harness matters first: Codex, Claude Code, or multi-harness parity.
