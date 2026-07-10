---
name: traceability-review
description: Use when reviewing whether a spec, plan, implementation, bug fix, memory pack, or active work is aligned with discussion, project memory, related specs, plans, code, tests, and bug learnings
---

# Traceability Review

Review specs, plans, implementations, bug fixes, memory, or full workflow chains for drift and missing context.

## Core Principle

Lead with findings. Review artifacts against their sources of truth. Do not edit files during standalone review unless the human partner explicitly approves.

## Report Contract

```text
Blocking findings
- [severity] [artifact/path] Problem. Evidence. Required action.

Non-blocking concerns
- [severity] [artifact/path] Concern. Evidence. Suggested action.

Missing updates
- Spec/plan/memory/test/manual-test update needed, with target file.

Recommended next command
- One command, such as /update-spec, /review-plan, /implement-plan, or /finish-traceable.
```

If there are no findings in a section, write `None found`.

## Edit Contract

Standalone review modes may read freely. They may edit only after explicit human approval.

Internal self-review gates may fix the artifact they just created:

- `/write-spec` may fix the spec it is writing.
- `/plan-spec` may fix the plan it is writing.

## Modes

### `spec-review`

Review a spec for mismatch with current discussion when available, approved design, related specs, project memory, feature context, assumptions, unknowns, edge cases, user-facing surface, acceptance criteria, manual test artifact link or not-applicable reason, manual test budget, required manual test sections, affected-existing-feature coverage, and testability.

### `plan-review`

Review a plan for spec coverage, missing code areas, missing tests, missing manual test coverage for human-verifiable behavior, missing affected-existing-feature coverage, task size, ordering problems, unclear acceptance criteria, missing docs/config/migrations, missing context packet inputs, and risk of behavior outside the spec.

Then pressure-test the plan:

1. Can each task be completed from the given context?
2. Are task dependencies ordered correctly?
3. Does any task write before required discovery?
4. Does every acceptance criterion have automated verification or manual test coverage?
5. Do likely edge cases appear in tasks, tests, or manual test cases?
6. Do affected existing features and touched shared code paths have regression coverage?
7. Is the manual test case count within the right budget?
8. Is manual setup clear enough for the human partner?

### `implementation-review`

Review the current diff against the active plan and spec. Check that every plan task is complete, every acceptance criterion is satisfied, feature-context invariants still hold, tests cover edge cases, manual test expectations still match implemented user-facing behavior, behavior has not drifted beyond the spec, unrelated changes are absent, and docs/spec/memory/manual-test updates are identified.

### `bug-fix-review`

Review whether root-cause evidence exists, the fix addresses root cause, an automated regression test exists when feasible, a manual regression case was added or updated when the bug is human-verifiable, no new edge case was introduced, the spec was updated if behavior changed, and `BUG_PATTERNS.md` was updated when the pattern is reusable.

### `memory-review`

Review `docs/project-memory/*.md` for stale facts, missing files, missing feature context, missing bug patterns, duplicate information, and stale `SPEC_INDEX.md` entries.

### `full`

Review the whole chain: discussion or available context, project memory, feature context, related specs, plan, manual test artifact and manual QA status, code, automated tests, bug patterns, and finishing hygiene. Include `bug-fix-review` when the target is a bug fix or when the active diff is bug-fix work.
