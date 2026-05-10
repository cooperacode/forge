---
title: "How To: Work Items"
slug: how-to-workitems
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/HOW_TO_WORKITEMS.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, work-items, focus, hierarchy, guide, how-to]
related_concepts: [work-item-hierarchy, artifact-pipeline, cross-work-item-context]
related_entities: [yan-justino]
---

## Summary

This guide is the beginner-facing reference for creating and managing work items in forge. It covers the three-level hierarchy, the step-by-step `/focus` creation flow, the parent-linking rules, what gets created on disk, and how to switch between active work items.

The central workflow is simple: run `/focus`, choose a level and type, fill in a title (description and tags are optional), optionally link a parent, and the work item is ready. forge creates the folder structure (`input/`, `output/`, `output/artifacts/`), appends the item to `docs/forge.yaml`, and writes `.env` so all subsequent commands target the correct work item.

A key practical constraint: only one work item is active at a time — `.env` tracks it. Run `/focus` → "Select an existing work item" to switch. The folder path should never be renamed after creation because it would break existing wiki links.

The parent linking rules determine how the artifact pipeline's cross-work-item context flows: Strategic items are always root-level; Product Epics can be children of Strategic items; Product Features can be children of Epics; Tactical items are children of Product items. The Epic → Feature → User Story chain drives the entire artifact pipeline: `feature-list` (Epic) → `feature-detail` reads parent Epic's `feature-list` → `user-story` reads parent Feature's `feature-detail`.

## Key claims

- Three-level hierarchy: Strategic (Theme, Initiative), Product (Epic, Feature), Tactical (User Story, Task, Bug). Start where your current work is — you don't need all three levels.
- Rule of thumb: "Decide = Strategic. Build = Product. Execute = Tactical."
- `/focus` first-run behavior: prompts for language once, saved in `docs/forge.yaml`; never asked again. To change: run `/lang`.
- Parent linking: Strategic = always root; Product (Epic) = child of Strategic; Product (Feature) = child of Epic; Tactical = child of Product.
- Only one active work item at a time, tracked in `.env`. Run `/focus` → "Select existing" to switch.
- Folder path must not be renamed after creation — it would break wiki links.
- To fix a wrong level/type: delete the folder and its `forge.yaml` entry, then run `/focus` again.

## Connections to existing wiki

This source largely confirms [work-item-hierarchy](../concepts/work-item-hierarchy.md) and [cross-work-item-context](../concepts/cross-work-item-context.md). It adds:
- The practical decision rule ("decide / build / execute")
- The parent linking table with specific valid combinations
- The one-active-at-a-time constraint
- The rename-breaks-links warning

No contradictions with existing wiki pages.

## Open questions

- If a folder path is accidentally renamed, is there a repair command, or must all wiki links be updated manually?
- Can a Feature have a parent other than an Epic (e.g., directly under an Initiative)?
- Is there a limit on the depth of nesting for work items, or is the three-level structure a hard constraint?

## Notable quotes

> "You don't need to fill all three levels at once. Start where your current work is."

> "Is this something we decide, or something we build? Decisions live at Strategic. What gets built lives at Product. How it gets built lives at Tactical."

> "Do not rename the folder path — it would break existing wiki links."
