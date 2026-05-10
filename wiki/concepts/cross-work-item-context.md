---
title: "Cross-Work-Item Context"
slug: cross-work-item-context
type: concept
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [forge, context, hierarchy, propagation, parent]
related_sources: [sources/research, sources/how-to-artifacts]
related_entities: []
related_concepts: [artifact-pipeline, work-item-hierarchy, source-traceability]
---

## Definition

Cross-work-item context is the mechanism by which artifacts from a parent work item act as constraints and guardrails for artifact generation in child work items. It is how strategic decisions travel downward through the [work item hierarchy](work-item-hierarchy.md) without manual copying.

## How it works

When a work item has a declared parent (via the `parent` field in `docs/forge.yaml`), the orchestrator resolves a `CONTEXT_PATH` pointing directly to the parent's `output/artifacts/` folder before invoking any `/draft` skill. The skill reads upstream artifacts on demand — nothing is copied to the child's folder.

Propagation mapping:

| Parent artifact | Influences child artifact |
|----------------|--------------------------|
| `brief.md` | Product `requirements.md` |
| `requirements.md` | Product `requirements.md`, `feature-list.md` |
| `adr/` | Product `adr/`, `feature-list.md` |
| `diagrams/` | Product `diagrams/` |

Upstream artifacts take precedence over inferences from local sources when there is a conflict.

**Guardrail behavior** (from [how-to-artifacts](../sources/how-to-artifacts.md)):
- `brief.md` — features that don't serve any strategic goal are flagged as unaligned.
- `requirements.md` — functional requirements that violate an established constraint are flagged.
- `adr/` — new ADRs that contradict an upstream decision are flagged explicitly.

If the parent work item has no published artifacts, the orchestrator warns:
```
No artifacts found in parent work item.
Run /draft on the parent first to generate upstream context.
```

## Evidence and claims

From [research](../sources/research.md):
> "Before invoking any skill, the orchestrator resolves `CONTEXT_PATH` pointing directly to the parent's `output/artifacts/` folder. Skills read from it on demand — nothing is copied. Upstream artifacts take precedence over inferences from local sources when there is a conflict."

## Connections

- [artifact-pipeline](artifact-pipeline.md) — the artifact chain that cross-work-item context constrains
- [work-item-hierarchy](work-item-hierarchy.md) — the parent-child relationship that determines what `CONTEXT_PATH` resolves to

## Open questions

- What happens to `CONTEXT_PATH` if the parent work item is deleted or its path changes?
- Is cross-work-item context read-only, or can a child work item override a parent constraint?
- Does the propagation extend beyond one level (grandparent to grandchild), or only one hop up the hierarchy?
