---
description: "Update the relevant spec before changing behavior"
---

# /update-spec

Fallback phrase: `Update spec: require context packets before subagent dispatch`

Required skill: `superpowers:context-traceability`

Use `context-traceability` in `spec-update` mode. Resolve the target spec through `SPEC_INDEX.md`, filenames, and content search. Ask when multiple specs match. Update the linked manual test artifact when the change affects human-verifiable behavior, setup, expected results, negative cases, or regression cases. Run `traceability-review` in `spec-review` mode after the update.
