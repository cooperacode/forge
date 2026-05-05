---
name: feature-detail
description: "Generate a Feature Detail artifact for a specific feature from the feature list. Provides deep analysis of scope, business rules, entity interactions, and a proposed user story breakdown. Product level only."
---

# Skill: Feature Detail

You were invoked by the orchestrator because the user wants to detail a specific feature from the active wiki. Your job is to select one feature from the existing `feature-list.md`, analyze it in depth across all wiki content, and produce a detailed specification with a proposed user story breakdown.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, `WORK_ITEM_TYPE`, `CONTEXT_PATH`, and `LANGUAGE` — use those values for all file operations and metadata.

This skill is for **Product-level work items only** (Epic, Feature). If `{WORK_ITEM_TYPE}` is Strategic or Tactical, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

---

## Step 1 — Verify wiki and feature-list

Attempt to read `{OUTPUT_PATH}index.md` and set `LOCAL_WIKI`:

| `{OUTPUT_PATH}index.md` | Action |
|-------------------------|--------|
| exists and has content  | Set `LOCAL_WIKI = true`. Note the total number of pages indexed. |
| missing or empty        | Set `LOCAL_WIKI = false`. Warn the user: "Local wiki is empty — the feature detail will rely on the parent's artifacts only." |

The `feature-list.md` is an **Epic-level artifact** and lives in the parent work item's output. Check `{CONTEXT_PATH}`:

- **If `{CONTEXT_PATH}` is empty**, stop and tell the user:

  > No parent work item is configured. Feature Detail requires an Epic-level parent with a feature list. Set up a parent work item via `/workitem` and generate its feature list with `/artifact feature-list` first.

- **If `{CONTEXT_PATH}` is non-empty**, check whether `{CONTEXT_PATH}feature-list.md` exists.

  - **If it does not exist**, stop and tell the user:

    > No `feature-list.md` found in the parent work item (`{CONTEXT_PATH}`). Run `/artifact feature-list` on the parent Epic first, then come back here.

  - **If it exists**, read it in full. Extract all feature rows: `ID`, name, description, beneficiary, priority, and dependencies.

---

## Step 2 — Ask the user to select a feature

Show the list of features and ask which one to detail:

```
Feature list loaded. Which feature do you want to detail?

| ID    | Feature         | Priority        |
|-------|----------------|-----------------|
| F-001 | {name}         | {priority}      |
| F-002 | {name}         | {priority}      |
...

Reply with the feature ID (e.g. F-001).
```

Wait for the user's reply. Record:

```
SELECTED_FEATURE_ID   = {e.g. F-001}
SELECTED_FEATURE_NAME = {full name from feature-list}
SELECTED_FEATURE_DESC = {description from feature-list}
SELECTED_FEATURE_SLUG = {kebab-case short name, ASCII only}
```

Check whether `{OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md` already exists. If it does, warn the user:

> A detail for `{SELECTED_FEATURE_ID}` already exists. Continuing will overwrite it. Proceed?

Wait for confirmation before continuing.

---

## Step 3 — Read all wiki pages

Read in this order:

1. `{CONTEXT_PATH}feature-list.md` (already read in Step 1 — the authoritative feature scope)

**If `LOCAL_WIKI = true`**, also read:

2. `{OUTPUT_PATH}overview.md`
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
4. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
5. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

6. Any other files present in `{CONTEXT_PATH}` (remaining parent Epic artifacts):
   - `brief.md` — strategic goals; any behavior in this feature that doesn't serve a stated goal should be flagged.
   - `requirements.md` (NFR) — constraints that shape implementation; carry them into the business rules section.
   - Note each upstream source when carrying a constraint or framing forward.

While reading, focus exclusively on `{SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}`. Extract:

**Personas** — roles or user types who interact with this feature. Look in `entities/` pages with `subtype: person` and in source pages.

**Behaviors** — discrete actions or outcomes this feature must deliver. Each distinct behavior is a user story candidate. Look for:
- Action verbs with a subject ("the customer submits", "the system validates")
- Described flows or interactions
- Rules that gate or shape behavior
- Success and failure conditions

**Business rules** — validations, limits, or constraints scoped to this feature.

**Entity and data interactions** — which entities are created, read, updated, or deleted by this feature. Use canonical names from `entities/` pages.

**Dependencies** — other features this one requires or enables.

**Gaps** — areas where the wiki describes a need but without enough detail to specify behavior.

---

## Step 4 — Propose the feature detail and user story breakdown

Before writing, present a summary for confirmation:

```
Analysis of {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}:

Personas identified: {list}
Behaviors found: {N}
Business rules found: {N}
Entities touched: {list}
Gaps detected: {N}

Proposed user story breakdown ({N} stories) — evaluated against INVEST:

US-001 · As a {persona}, I want {action}, so that {benefit}.
         {INVEST concern if any — e.g., "Not Small: consider splitting" · "Not Testable: acceptance criteria unclear"}
US-002 · As a {persona}, I want {action}, so that {benefit}.
...

{For any behavior that fails Estimable or Testable:}
> [!gap] {behavior} — not documented in sufficient detail to write a story. Confirm or discard.

Does this analysis look right? Any behaviors to add, remove, or merge?
```

Wait for confirmation or corrections. Do not write any file until the user approves.

---

## Step 5 — Write the feature detail artifact

Create `{OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md`:

```markdown
---
title: "Feature Detail — {SELECTED_FEATURE_ID}: {SELECTED_FEATURE_NAME}"
type: artifact
subtype: feature-detail
feature_id: {SELECTED_FEATURE_ID}
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Product
generated: YYYY-MM-DD
sources_read: N
total_stories: N
---

# Feature Detail: {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}

> **Feature list entry:** [{SELECTED_FEATURE_ID}](../feature-list.md) · {priority} · {beneficiary}

## Feature Statement

1–2 paragraphs: what this feature is, who it's for, and why it matters. Cite wiki pages using [[wikilinks]].

---

## Goal

What success looks like when this feature is fully implemented. Tie to strategic goals if upstream `brief.md` was available.

---

## Personas

| Persona | Role | Interaction with this feature | Source |
|---------|------|-------------------------------|--------|
| {name} | {role} | {how they use or are affected by this feature} | [[entities/slug]] |

---

## Functional Scope

Detailed description of what this feature does. Organized by behavior area if needed.

### In scope

- {behavior}: {description} [[sources/slug]]

### Out of scope

- {behavior} — {reason from wiki} [[sources/slug]]

---

## Business Rules

Rules and constraints that govern this feature's behavior, extracted from the wiki:

| # | Rule | Source |
|---|------|--------|
| BR-1 | {Rule statement} | [[sources/slug]] |

---

## Entity & Data Interactions

Entities created, read, updated, or deleted by this feature:

| Entity | Operation | Notes | Source |
|--------|-----------|-------|--------|
| {EntityName} | Create / Read / Update / Delete | {context} | [[entities/slug]] |

---

## Feature-Level Acceptance Criteria

High-level conditions for this feature to be considered complete:

| # | Criterion | Source |
|---|-----------|--------|
| FAC-1 | {Specific, testable condition at feature scope} | [[sources/slug]] |

---

## Proposed User Story Breakdown

Stories required to fully deliver this feature, shaped by the **INVEST** principle. Each row maps to a file that will be generated at the Tactical level.

| Story ID | Story | Persona | Priority | INVEST Notes | Depends On |
|----------|-------|---------|----------|-------------|------------|
| US-001 | As a {persona}, I want {action}, so that {benefit}. | {persona} | MVP / Post-MVP | — | — |
| US-002 | ... | ... | ... | {e.g., "S: split from US-001 — too large for one sprint"} | US-001 |

**INVEST criteria applied to each story:**
- **I**ndependent — minimize coupling; dependencies on other stories are explicit in the table.
- **N**egotiable — this breakdown is guidance, not a locked contract; stories can be merged or split.
- **V**aluable — every story delivers observable value to a named persona; no purely technical tasks.
- **E**stimable — stories the team cannot size due to missing information are flagged with `> [!gap]`.
- **S**mall — stories that span multiple sub-flows or sessions are split into smaller, completable units.
- **T**estable — each story must map to at least one verifiable acceptance criterion; untestable behaviors are flagged.

**Story naming convention when generating at Tactical level:**
`{SELECTED_FEATURE_ID}-US-001-{slug}.md` inside `artifacts/user-stories/`.

---

## Dependencies

| Type | Item | Direction | Source |
|------|------|-----------|--------|
| Feature dependency | [[artifacts/feature-list]] F-00X | requires / enables | [[sources/slug]] |
| External dependency | {system or team} | {known / unknown} | [[sources/slug]] |

---

## Gaps

Areas where the wiki described a need but without enough detail to specify behavior:

> [!gap] {Description of what is unclear and what type of source would resolve it}

---

## Open Questions

Questions that affect this feature's scope or design but remain unresolved:

- [ ] {Question} — needs input from {stakeholder type}

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
```

---

## Step 6 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}]] — Feature Detail: {SELECTED_FEATURE_NAME} (generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Feature Detail — {SELECTED_FEATURE_ID}

Feature: {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}
File: artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md
Personas: N
Business rules: N
Entities touched: N
Proposed user stories: N
Gaps flagged: N
Sources read: N pages
```

---

## Step 7 — Close the loop

```
Done. Feature detail generated at {OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md.

Personas: N
Business rules: N
Entities touched: N
Proposed user stories: N (ready to generate with `/artifact user-story` at the Tactical level)
Gaps flagged: N
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Require `feature-list.md` before proceeding.** This skill cannot run without it.
- **Always ask for the feature ID (Step 2) before reading the wiki.** Do not guess or auto-select.
- **Never write files before Step 4 is confirmed.** The analysis must be approved first.
- **File path is fixed:** `artifacts/feature-detail/{feature_id}-{slug}.md`. Do not deviate.
- **Never invent behaviors not present in the wiki.** Use `> [!gap]` for anything inferred.
- **Business rules must be individually sourced.** Never write a rule without a [[wikilink]].
- **User story breakdown is a proposal, not a commitment.** Stories are generated later at the Tactical level — this breakdown is guidance, not a locked contract.
- **Apply INVEST to every proposed story.** Flag violations explicitly in the INVEST Notes column: split stories that violate **S** (too large for one sprint); mark as `> [!gap]` stories that violate **E** or **T** (cannot estimate or verify due to missing wiki detail); note explicit dependencies for stories that violate **I**. Never write a story that fails **V** — if no persona benefits, it is a technical task, not a user story.
- **Never write to source/concept/entity pages.** This skill is read-only on the wiki.
- **This skill is Product-only.** If invoked for Strategic or Tactical, stop immediately.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path: `[[docs/strategic/initiatives/20260504-foo/output/artifacts/brief.md]]`. Never use short names (`[[brief.md]]`) or computed relative paths (`[[../../...]]`) for cross-work-item references — they resolve to the wrong location.
