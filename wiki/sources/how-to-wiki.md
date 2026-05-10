---
title: "How To: Create and Maintain a Wiki"
slug: how-to-wiki
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/HOW_TO_WIKI.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, wiki, ingest, query, lint, guide, how-to]
related_concepts: [wiki-architecture, source-traceability, artifact-pipeline]
related_entities: [yan-justino]
---

## Summary

This guide covers the three wiki operations — `/ingest`, `/query`, and `/lint` — and explains the structure and philosophy of the forge wiki system.

The wiki is the structured layer between raw source documents and generated artifacts. It lives at `docs/wiki/` (global, shared across all work items) and is made up of four directories: `sources/`, `concepts/`, `entities/`, plus `index.md` and `log.md` at the root. Each page carries a `source_workitem` field that records which work item originated it — enabling `/lint` to detect orphaned pages when work items are removed.

Two complementary indexes are maintained: the global index (`docs/wiki/index.md`) lists every page from all work items and is used by `/query` and `/lint`; the local index (`{workitem}/output/index.md`) is a scoped view used by artifact skills to ensure they are only informed by relevant work item sources.

The ingest process follows a strict "no fabrication" principle: contradictions are flagged with `> [!contradiction]` callouts and never silently resolved; gaps in wiki coverage are surfaced explicitly; and content pasted directly into chat is rejected — sources must be files in `input/`. Re-ingestion is prevented by slug-based filtering against the local index.

The `/lint` command performs two categories of checks: structural problems (auto-fixable: orphan pages, broken wikilinks, missing frontmatter, stub pages) and content problems (require user input: contradictions, outdated content, concept gaps, stale synthesis).

## Key claims

- Wiki structure: `docs/wiki/sources/`, `docs/wiki/concepts/`, `docs/wiki/entities/`, `docs/wiki/index.md`, `docs/wiki/log.md`.
- Two indexes: global (`docs/wiki/index.md`) for all work items; local (`output/index.md`) scoped to one work item — artifact skills read the local index.
- Default `/ingest`: processes all `input/` files in batches of 5 sequentially; `-buddy` pauses at takeaways, page list, and close loop.
- Re-ingest prevention: `/ingest` checks the local `output/index.md` before processing and skips already-ingested slugs.
- Contradictions: flagged with `> [!contradiction]`; never silently resolved; user decides resolution.
- Outdated content: marked with `> [!outdated]` or `> [!deprecated]`; pages should not be deleted — use these callouts and remove from index instead.
- `/query`: answers only from wiki; cites inline; never invents; surfaces contradictions rather than picking a side; can save answers as new concept pages.
- `/lint` trigger: after every 3–5 ingests or before any `/draft`.
- Supported source formats: Markdown, plain text, PDF, images (charts, screenshots, diagrams).

## Connections to existing wiki

This source completes the picture of the wiki system:
- Introduces the two-index architecture (new concept: [[concepts/wiki-architecture]])
- Adds callout conventions (`> [!contradiction]`, `> [!outdated]`) to [[concepts/source-traceability]]
- Confirms `/ingest` batch size of 5 (consistent with current ingest behavior)

## Open questions

- When a query answer is saved as a wiki page, is it stored under `concepts/` always, or can it also go to `entities/`?
- Does the local index scoping for artifact skills apply recursively (parent work item's local index is also consulted), or only the current work item?
- What is the exact behavior when a file was re-added to `input/` after editing — is removing its slug from `output/index.md` the only mechanism to force re-ingest?

## Notable quotes

> "Contradictions are flagged but never silently resolved. Claude marks them with a `> [!contradiction]` callout and leaves the decision to you."

> "There is no required number of sources before running `/draft`. The wiki tells you — gaps in the lint report or in query answers are the signal to ingest more before generating."

> "Avoid deleting a wiki page. If a page is wrong or outdated, use `> [!outdated]` or `> [!deprecated]` and remove it from `index.md`. The file stays — it may be referenced by other pages or by `log.md`."
