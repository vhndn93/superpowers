# Conventions

## Skill Content

- Skills are behavior-shaping code. Do not rewrite tuned language casually.
- Frontmatter descriptions should describe triggering conditions, not summarize workflow steps.
- Keep skills concise and operational. Put heavy references or scripts in adjacent files only when needed.
- Preserve deliberate project terminology such as "human partner".
- Use `writing-skills` for any skill creation or skill behavior change.

## Contribution Discipline

- One real problem per PR.
- Read `.github/PULL_REQUEST_TEMPLATE.md` before preparing any PR.
- Search open and closed PRs for duplicates or prior art.
- Show the full diff to the human partner and get explicit approval before submitting.
- Do not submit speculative improvements without a concrete user/session failure.

## Core Scope

- Core accepts general-purpose workflows that benefit users across project types.
- Core rejects optional or required dependencies on third-party tools, except new harness support.
- Domain-specific, team-specific, tool-specific, or personal workflows belong in standalone plugins.

## Implementation Style

- Prefer zero-dependency shell or small JavaScript where support code is required.
- Follow existing path conventions for specs and plans.
- Avoid broad refactors while touching behavior-shaping content.
- Preserve harness differences explicitly instead of assuming Claude Code behavior applies everywhere.
