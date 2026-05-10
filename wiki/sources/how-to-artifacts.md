---
title: "How To: Artifacts"
slug: how-to-artifacts
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/HOW_TO_ARTIFACTS.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, artifacts, draft, guide, how-to]
related_concepts: [artifact-pipeline, cross-work-item-context, source-traceability]
related_entities: [yan-justino]
---

## Summary

This guide is the practical reference for generating artifacts using `/draft`. It specifies prerequisites, available artifact types by level, the recommended generation order, how context flows between hierarchy levels, and how artifacts are stored.

The central principle is that artifacts are generated exclusively from ingested wiki knowledge — Claude will never invent content from training data. Gaps in wiki coverage are surfaced explicitly with `> [!gap]` callouts. Prerequisite enforcement is strict: same-level dependencies are enforced (Claude stops and tells you what to generate first); cross-level hard dependencies are also enforced (`feature-list` before `feature-detail` or `user-story`).

A key artifact type introduced in detail here is `feature-detail` (Product/Feature level) — a deep specification that includes Personas, Business Rules, Entity Interactions, and a Proposed User Story Breakdown. It is optional but acts as the primary source for `user-story` generation when present, producing richer stories with less wiki re-reading.

Context flow between levels is one-way and read-on-demand: strategic artifacts act as guardrails (unaligned features flagged, constraint violations flagged, ADR contradictions flagged). Nothing is copied — upstream artifacts are read directly from the parent's `output/artifacts/` folder.

## Key claims

- Two hard prerequisites: (1) active work item (`/focus`); (2) at least one ingested source (`/ingest`).
- Same-level artifact dependencies are enforced — Claude stops and specifies what to generate first.
- `feature-list` is a hard dependency for both `feature-detail` (Product/Feature) and `user-story` (Tactical).
- `feature-detail` is optional but recommended for `user-story` — when present, it is the primary source.
- Artifact never contains invented content — only wiki-sourced claims. Gaps get `> [!gap]` callouts.
- Context guardrails: `brief.md` → flags features not serving any strategic goal; `requirements.md` → flags functional requirements that violate constraints; `adr/` → flags new ADRs that contradict upstream decisions.
- Artifacts are saved under `output/artifacts/` in type-specific subfolders; `index.md` and `log.md` are updated automatically after each generation.

## Connections to existing wiki

This source substantially enriches [[concepts/artifact-pipeline]] with:
- `feature-detail` as a distinct artifact type (not fully described in prior sources)
- Explicit dependency enforcement rules
- Gap callout convention

It also enriches [[concepts/cross-work-item-context]] with the guardrail detail (unaligned features, constraint violations, ADR contradictions).

## Open questions

- When regenerating an artifact after new sources are ingested, are the old `> [!gap]` callouts automatically removed if coverage now exists?
- Can artifacts be version-controlled (tagged/named) so a regeneration history is preserved?

## Notable quotes

> "Artifacts do not come from Claude's training knowledge. Every claim in an artifact traces back to a wiki page, which in turn traces back to a source document you ingested."

> "If the parent has no artifacts yet, Claude warns you before proceeding: 'No artifacts found in parent work item. Run /draft on the parent first to generate upstream context.'"
