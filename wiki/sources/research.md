---
title: "forge — Research & Documentation (Deep-dive Reference)"
slug: research
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/RESEARCH.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, reference, commands, artifacts, installation, agile, lineage]
related_concepts: [artifact-pipeline, work-item-hierarchy, source-traceability, cross-work-item-context]
related_entities: [yan-justino, protocolo-es-ai, spread-methodology]
---

## Summary

This document is the comprehensive reference guide for forge. It covers the project's intellectual lineage, the agile-aligned work item hierarchy, installation instructions, and step-by-step walkthroughs of every major command.

The origins section traces a clear three-generation lineage: SPReaD (Springer, 2021) established the principle that software engineering must follow a traceable, repeatable process with defined artifacts; protocolo-es-ai (2025) extended this to AI-assisted development across the full software lifecycle; forge (2026) operationalizes that protocol as a running tool inside a standard git repository and editor.

The artifacts section is the most detailed reference: it enumerates artifact types per hierarchy level, the recommended generation order within a work item, and the cross-work-item context propagation mechanism. Parent artifacts are never copied — they are resolved on demand via a `CONTEXT_PATH` pointing to the parent's `output/artifacts/` folder. Strategic artifacts act as guardrails for product-level generation.

Installation is zero-configuration: `git clone`, and the plugin discovers itself via `.claude-plugin/plugin.json` (Claude Code) or `.vscode/settings.json` (VS Code).

## Key claims

- forge's lineage: SPReaD (2021) → protocolo-es-ai (2025) → forge (2026). Each layer inherits a structured, artifact-driven, traceable process model.
- Six core commands: `/lang`, `/focus`, `/ingest`, `/query`, `/lint`, `/draft`.
- Artifact types by level — **Strategic**: brief, requirements, adr, diagram; **Product**: requirements, der, adr, feature-list, diagram; **Tactical**: user-story, diagram.
- Recommended generation order: `brief → requirements → feature-list → adr → der → diagram → user-story → diagram (seq/state)`.
- `feature-list` is a **hard dependency** for `user-story`; all others are soft (enrich if present, not required).
- Cross-work-item context: the orchestrator resolves `CONTEXT_PATH` to the parent's `output/artifacts/` folder; upstream artifacts take precedence over local inferences when there is a conflict.
- Installation: `git clone` — no extra config; Claude Code reads `.claude-plugin/plugin.json`, VS Code reads `.vscode/settings.json`.

## Connections to existing wiki

This source substantially extends [[sources/readme]] with:
- Explicit artifact type enumeration and generation ordering (adds to [[concepts/artifact-pipeline]])
- Cross-work-item context propagation mechanics (new concept, see [[concepts/cross-work-item-context]])
- SPReaD-to-forge lineage detail (new entity, see [[entities/spread-methodology]])
- Full command reference table

## Open questions

- What happens to `CONTEXT_PATH` if the parent work item has been deleted or moved?
- The recommended generation order is documented, but is it enforced — does `/draft user-story` fail if `feature-list` does not exist?
- How does the `der` (Entity-Relationship Diagram) artifact relate to the concept model already in the wiki?

## Notable quotes

> "forge operationalizes the protocolo-es-ai as a running tool. Where the protocol defines *what* AI-assisted engineering activities should look like, forge provides the commands, skills, and wiki infrastructure that make those activities executable inside a standard git repository and editor."

> "Each artifact that exists enriches the next one. `feature-list` is a hard dependency for `user-story`; all others are soft (enrich if present, not required)."

> "Upstream artifacts take precedence over inferences from local sources when there is a conflict."
