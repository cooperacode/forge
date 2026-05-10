---
title: "Wiki Architecture"
slug: wiki-architecture
type: concept
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [forge, wiki, architecture, indexes, structure]
related_sources: [sources/how-to-wiki]
related_entities: []
related_concepts: [source-traceability, artifact-pipeline, cross-work-item-context]
---

## Definition

The forge wiki is a centralized, plain-Markdown knowledge base at `docs/wiki/`, shared across all work items in the repository. It is the structured layer between raw source documents and generated artifacts.

## How it works

**Directory structure:**

```
docs/
  wiki/
    sources/      ← one page per ingested document
    concepts/     ← themes, patterns, techniques extracted from sources
    entities/     ← people, organizations, systems, datasets named in sources
    index.md      ← global navigation index + running synthesis
    log.md        ← audit trail: every ingest, query, and lint recorded
```

Only `index.md` and `log.md` may exist at the root of `docs/wiki/`. All other pages go inside `sources/`, `concepts/`, or `entities/`.

**Two complementary indexes:**

| Index | Path | Scope | Used by |
|-------|------|-------|---------|
| Global | `docs/wiki/index.md` | All work items | `/query`, `/lint` |
| Local | `{workitem}/output/index.md` | One work item | `/draft` (artifact skills) |

The local index is scoped to a single work item and uses repo-root paths. Artifact skills read the local index to ensure they are informed only by sources relevant to the active work item — preventing cross-contamination from unrelated work items' sources.

**Page frontmatter fields:**

All wiki pages carry a `source_workitem` field that records which work item originated the page. This enables `/lint` to detect orphaned pages when work items are removed or moved.

**Supported source formats for ingest:** Markdown, plain text, PDF, images (charts, screenshots, diagrams).

**Callout conventions:**

| Callout | Meaning | Resolution |
|---------|---------|------------|
| `> [!contradiction]` | Two sources or pages conflict on a claim | User decides — never auto-resolved |
| `> [!outdated]` | Content has been superseded by a newer source | User updates or removes the section |
| `> [!deprecated]` | Page or section is no longer relevant | Keep file; remove from `index.md` |
| `> [!gap]` | A section in an artifact has no wiki coverage | Ingest more sources or consult stakeholders |

Pages should never be deleted — use `> [!outdated]` or `> [!deprecated]` and remove from `index.md`. The file stays because it may be referenced by other pages or by `log.md`.

## Evidence and claims

From [how-to-wiki](../sources/how-to-wiki.md):
> "The wiki lives in a single centralized folder at `docs/wiki/`, shared across all work items."

> "The local index is created as an empty stub when you run `/focus` and populated automatically each time you run `/ingest`. You never need to edit it manually."

## Connections

- [source-traceability](source-traceability.md) — the `source_workitem` field and callout conventions are the operational layer of the traceability principle
- [artifact-pipeline](artifact-pipeline.md) — the local index is the scoping mechanism that prevents artifacts from being informed by unrelated sources
- [cross-work-item-context](cross-work-item-context.md) — complements the local scoping: parent context is read on demand, not merged into the local index

## Open questions

- Does the local index scoping for artifact skills extend to the parent work item's local index (recursive lookup), or is it strictly one work item at a time?
- When a query answer is saved as a new wiki page, can it go to `entities/` or only to `concepts/`?
