---
title: "Work Item Hierarchy"
slug: work-item-hierarchy
type: concept
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [forge, agile, hierarchy, safe, work-items]
related_sources: [sources/readme, sources/research, sources/how-to-workitems]
related_entities: []
related_concepts: [artifact-pipeline, source-traceability]
---

## Definition

The work item hierarchy is the three-level organizational structure forge uses to classify, scope, and route knowledge and artifacts. It mirrors the structure used by teams in Jira, Azure DevOps, and the Scaled Agile Framework (SAFe).

## How it works

The hierarchy has three levels:

| Level | Types | Scope | Description |
|-------|-------|-------|-------------|
| **Strategic** | Theme, Initiative | Business goals, multi-quarter efforts | High-level goals and objectives; set direction |
| **Product** | Epic, Feature | Release planning, PI increments | Product-scoped deliverables; define what gets built |
| **Tactical** | User Story, Task, Bug | Sprint execution, daily engineering work | Day-to-day work items; define how it gets built |

Work item type detail:
- **Theme** — Large area of focus or business vertical
- **Initiative** — Collection of epics driving a theme (spans multiple quarters and teams)
- **Epic** — Large body of work, too big for one sprint (weeks or months to deliver)
- **Feature** — Functionality scoped to one release or PI (SAFe: meets a stakeholder need)
- **User Story** — Smallest unit of user-facing value (`As a [user] I want [action] so that [benefit]`)
- **Task** — Technical decomposition of a story (design, coding, tests, CI/CD config)
- **Bug** — Unexpected behavior that must be fixed

Each level has a dedicated folder structure in the repository under `docs/{level}/`. The active work item at any time is tracked in `.env` via `FORGE_*` variables and in `docs/forge.yaml`. **Only one work item is active at a time.** Run `/focus` → "Select existing" to switch.

**Rule of thumb for choosing a level** (from [how-to-workitems](../sources/how-to-workitems.md)):
> "Is this something we decide (Strategic), something we build (Product), or how it gets built (Tactical)?"

**Parent linking rules:**

| Child level | Valid parent |
|-------------|-------------|
| Strategic | *(none — always root-level)* |
| Product (Epic) | Strategic (Theme or Initiative) |
| Product (Feature) | Product (Epic) |
| Tactical | Product (Epic or Feature) |

Artifacts and constraints flow **downward** through the hierarchy: strategic artifacts (e.g., quality attributes) become constraints for product-level generation; product artifacts (e.g., feature lists, feature details) feed tactical-level generation (user stories).

**Epic → Feature → User Story artifact chain:**
- `feature-list` is generated on the **Epic**
- `feature-detail` is generated on the **Feature** and reads the parent Epic's `feature-list`
- `user-story` is generated at **Tactical** level and reads `feature-detail` from the parent Feature

Each work item has its own `input/` folder for source documents and `output/` folder for the local wiki index, log, and generated artifacts. **Folder paths must not be renamed after creation** — doing so would break wiki links.

## Evidence and claims

From [readme](../sources/readme.md):
> "The work item hierarchy mirrors what teams already use in Jira, Azure DevOps, and SAFe — Strategic (Themes, Initiatives), Product (Epics, Features), and Tactical (User Stories, Tasks, Bugs). Artifacts generated at the strategic level automatically propagate as constraints into product-level work; product artifacts flow into tactical ones."

## Connections

- [artifact-pipeline](artifact-pipeline.md) — the artifact types available depend on the hierarchy level
- [source-traceability](source-traceability.md) — each level maintains its own source and artifact trail

## From [how-to-workitems](../sources/how-to-workitems.md)

Adds the decision heuristic ("decide / build / execute"), the explicit parent linking table, the one-active-at-a-time constraint, and the rename-breaks-links warning.

## Open questions

- Can a work item belong to multiple parents (e.g., a Feature shared by two Epics)?
- Can a Feature have a parent other than an Epic (e.g., directly under a Strategic Initiative)?
- Is the three-level structure a hard constraint in forge, or can it be extended?
