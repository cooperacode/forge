---
name: user-story
description: "Generate User Story artifacts with Gherkin acceptance scenarios, Definition of Done, and dependency map from the active wiki. Tactical level only. Stories are scoped to a specific feature and saved individually under artifacts/user-stories/."
---

# Skill: User Story

You were invoked by the orchestrator because the user wants to generate User Stories from the active wiki. Your job is to identify which feature the stories will cover, decompose it into implementable stories, confirm the breakdown with the user, then write one file per story.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, `WORK_ITEM_TYPE`, `CONTEXT_PATH`, and `LANGUAGE` — use those values for all file operations and metadata.

This skill is for **Tactical-level work items only** (User Story, Task, Bug). If `{WORK_ITEM_TYPE}` is Strategic or Product, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

---

## Step 1 — Detect parent mode

Attempt to read `{OUTPUT_PATH}index.md` and set `LOCAL_WIKI`:

| `{OUTPUT_PATH}index.md` | Action |
|-------------------------|--------|
| exists and has content  | Set `LOCAL_WIKI = true`. Note the total number of pages indexed. |
| missing or empty        | Set `LOCAL_WIKI = false`. The skill will rely on the parent's artifacts as the sole local source. |

`{CONTEXT_PATH}` points to the **direct parent** work item's `output/artifacts/`. What is available there determines the parent mode. Check `{CONTEXT_PATH}`:

- **If `{CONTEXT_PATH}` is empty**, stop and tell the user:

  > No parent work item is configured. User stories require a Product-level parent. Set up a parent work item via `/workitem` first.

- **If `{CONTEXT_PATH}` is non-empty**, inspect its contents and set `PARENT_MODE`:

  | What exists in `{CONTEXT_PATH}` | `PARENT_MODE` | Meaning |
  |----------------------------------|---------------|---------|
  | `feature-detail/` folder with at least one `.md` file | `FEATURE` | Parent is a Feature work item |
  | `feature-list.md` | `EPIC` | Parent is an Epic work item |
  | Neither | — | Stop (see below) |

  - **If neither exists**, stop and tell the user:

    > The parent work item has no artifacts that can drive user story generation.
    > - If the parent is a **Feature**: run `/artifact feature-detail` on it first.
    > - If the parent is an **Epic**: run `/artifact feature-list` on it first.

Record `PARENT_MODE` before continuing to Step 2.

---

## Step 2 — Resolve feature scope

### If `PARENT_MODE = FEATURE`

The feature scope is already defined by the parent work item itself. Read all `.md` files in `{CONTEXT_PATH}feature-detail/`.

- If there is exactly one file, use it as `FEATURE_DETAIL_PATH`. Extract `SELECTED_FEATURE_ID` and `SELECTED_FEATURE_NAME` from its frontmatter (`feature_id` and `title` fields).
- If there are multiple files (unusual), show them and ask which to use:

  ```
  Multiple feature details found in the parent work item. Which feature do you want to generate stories for?

  1. {SELECTED_FEATURE_ID} — {feature name}   ({filename})
  2. ...

  Reply with the number.
  ```

  Wait for the user's reply, then set `FEATURE_DETAIL_PATH` accordingly.

Record:
```
PARENT_MODE           = FEATURE
SELECTED_FEATURE_ID   = {from feature-detail frontmatter}
SELECTED_FEATURE_NAME = {from feature-detail frontmatter}
FEATURE_DETAIL_PATH   = {CONTEXT_PATH}feature-detail/{filename}
```

### If `PARENT_MODE = EPIC`

Read `{CONTEXT_PATH}feature-list.md` in full. Extract all feature rows: `ID`, name, description, beneficiary, priority, and dependencies.

Show the list and ask which feature to generate stories for:

```
Feature list loaded. Which feature do you want to break into user stories?

| ID    | Feature         | Priority        |
|-------|----------------|-----------------|
| F-001 | {name}         | {priority}      |
| F-002 | {name}         | {priority}      |
...

Note: for richer stories, first create a Feature work item as a child of this Epic,
run /ingest and /artifact feature-detail on it, then return here.

Reply with the feature ID (e.g. F-001).
```

Wait for the user's reply. Record:

```
PARENT_MODE           = EPIC
SELECTED_FEATURE_ID   = {e.g. F-001}
SELECTED_FEATURE_NAME = {full name from feature-list}
SELECTED_FEATURE_DESC = {description from feature-list}
FEATURE_DETAIL_PATH   = (empty — not available in Epic context)
```

---

## Step 3 — Read all wiki pages for context

### If `PARENT_MODE = FEATURE` (feature-detail is the primary source)

Read in this order:

1. `FEATURE_DETAIL_PATH` — **primary source**. Contains pre-analysed personas, behaviors, business rules, entity interactions, and a proposed story breakdown.

**If `LOCAL_WIKI = true`**, also read:

2. `{OUTPUT_PATH}overview.md`
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md`

4. Any other files present in `{CONTEXT_PATH}`:
   - `requirements.md` — acceptance criteria candidates; carry them forward.
   - `der.md` — canonical entity names; use them verbatim in Gherkin.

From `FEATURE_DETAIL_PATH`, extract directly:
- **Personas** from `## Personas`
- **Story candidates** from `## Proposed User Story Breakdown` — use as the starting list for Step 4
- **Business rules** from `## Business Rules`
- **Feature-level acceptance criteria** from `## Feature-Level Acceptance Criteria` — carry into individual stories' AC tables
- **Entity interactions** from `## Entity & Data Interactions`
- **Gaps** already flagged — carry forward rather than re-deriving

### If `PARENT_MODE = EPIC` (derive from wiki, no feature-detail available)

Read in this order:

1. `{CONTEXT_PATH}feature-list.md` (already read)

**If `LOCAL_WIKI = true`**, also read:

2. `{OUTPUT_PATH}overview.md`
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
4. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
5. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

6. Any other files present in `{CONTEXT_PATH}`:
   - `requirements.md` (functional) — acceptance criteria candidates; carry them forward.
   - `der.md` — canonical entity names; use them verbatim in Gherkin.

Identify and extract from scratch, focused on `{SELECTED_FEATURE_ID}`:

**Persona candidates** — roles or user types who interact with this feature. Look in `entities/` pages with `subtype: person` and in source pages.

**Behaviors to implement** — discrete actions or outcomes the feature must deliver. One behavior = one story candidate.

**Business value per behavior** — why each behavior matters to the persona.

**Constraints and rules** — validations, limits, or business rules scoped to this feature.

---

## Step 4 — Propose the story breakdown and confirm with the user

Before writing anything, present the proposed decomposition:

```
For feature {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}, I propose {N} user stories:

US-001 · As a {persona}, I want {action}, so that {benefit}.
US-002 · As a {persona}, I want {action}, so that {benefit}.
...

{If a behavior has no clear wiki support:}
> [!gap] US-00X — the behavior "{description}" is not explicitly documented in the wiki. Confirm or discard before I write this story.

Does this breakdown look right? Any stories to add, remove, or merge?
```

Wait for confirmation or corrections. Do not write any file until the user approves the breakdown.

Record the approved list as:

```
STORIES = [
  { id: "US-001", persona: "...", action: "...", benefit: "...", slug: "..." },
  ...
]
```

The `slug` is a short kebab-case description (3–5 words, ASCII only, no stopwords). Example: `cadastrar-produto-catalogo`.

---

## Step 5 — Write one file per user story

For each story in `STORIES`, create the file:

```
{OUTPUT_PATH}artifacts/user-stories/{SELECTED_FEATURE_ID}-{story.id}-{story.slug}.md
```

Example path: `output/artifacts/user-stories/F-001-US-001-cadastrar-produto-catalogo.md`

Use the template below for each file:

```markdown
---
title: "{SELECTED_FEATURE_ID} · {story.id} — {WORK_ITEM_TITLE}"
type: artifact
subtype: user-story
feature_id: {SELECTED_FEATURE_ID}
story_id: {story.id}
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Tactical
persona: {story.persona}
generated: YYYY-MM-DD
sources_read: N
---

# User Story: {story.action short title}

> As a **{story.persona}**,
> I want **{story.action}**,
> so that **{story.benefit}**.

**Feature:** [{SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}](../feature-list.md)

---

## Business Context

1–2 paragraphs: why this story matters, what problem it solves for the persona, and how it connects to the feature and broader initiative.
Cite wiki pages using [[wikilinks]].

---

## Acceptance Criteria

| # | Criterion | Source |
|---|-----------|--------|
| AC-1 | {Specific, testable condition} | [[sources/slug]] |
| AC-2 | ... | [[concepts/slug]] |

If acceptance criteria were not defined in the wiki:
> [!gap] Acceptance criteria are not documented in the ingested sources. Define with the product owner before sprint planning.

---

## Gherkin Scenarios

```gherkin
Feature: {story.action short title}

  Background:
    Given {shared precondition from wiki}

  Scenario: {happy path — AC-1}
    Given {initial state}
    When {action taken by persona}
    Then {expected outcome}
    And {additional assertion if needed}

  Scenario: {edge case or failure}
    Given {initial state}
    When {action that triggers the edge case}
    Then {expected system behavior}
```

Write only scenarios supported by wiki content. For uncovered scenarios use:
> [!gap] Scenario for {AC-N} could not be written — the wiki does not describe the expected behavior in sufficient detail.

---

## Business Rules

| # | Rule | Source |
|---|------|--------|
| BR-1 | {Rule statement} | [[sources/slug]] |

---

## Definition of Done

- [ ] All acceptance criteria verified
- [ ] All Gherkin scenarios pass
- [ ] Code reviewed
- [ ] Tests written for each scenario
- [ ] No regression in related features
{Add any DoD items explicitly stated in the wiki sources below:}
- [ ] {wiki-stated requirement}

---

## Dependencies & Blockers

| Type | Item | Status | Source |
|------|------|--------|--------|
| Feature dependency | [[artifacts/feature-list]] {SELECTED_FEATURE_ID} | required | [[sources/slug]] |
| Story dependency | {SELECTED_FEATURE_ID}-US-00X | {required before / parallel} | [[sources/slug]] |
| External dependency | {system or team} | {known / unknown} | [[sources/slug]] |

If no dependencies were detected: "No dependencies identified in the wiki."

---

## Out of Scope

Behaviors explicitly excluded or deferred in the wiki:

- {behavior} — {reason from wiki} [[sources/slug]]

---

## Open Questions

- [ ] {Question} — needs input from {stakeholder type}

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
```

Write all stories before moving to Step 6. If a story has a `> [!gap]` confirmed by the user as acceptable, write the file with the gap note included.

---

## Step 6 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section, listing every generated file:

```markdown
## Artifacts

- [[artifacts/user-stories/{SELECTED_FEATURE_ID}-US-001-{slug}]] — {story.action short title} (generated YYYY-MM-DD)
- [[artifacts/user-stories/{SELECTED_FEATURE_ID}-US-002-{slug}]] — ...
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | User Stories — {SELECTED_FEATURE_ID}

Feature: {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}
Stories generated: N
Files written:
  - artifacts/user-stories/{SELECTED_FEATURE_ID}-US-001-{slug}.md
  - artifacts/user-stories/{SELECTED_FEATURE_ID}-US-002-{slug}.md
  ...
Gaps flagged: N
Sources read: N pages
```

---

## Step 7 — Close the loop

```
Done. {N} user stories generated for feature {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}.

Files written to {OUTPUT_PATH}artifacts/user-stories/:
  {SELECTED_FEATURE_ID}-US-001-{slug}.md — {short title}
  {SELECTED_FEATURE_ID}-US-002-{slug}.md — {short title}
  ...

Gaps flagged: N
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Always detect `PARENT_MODE` in Step 1 before doing anything else.** The mode determines which artifacts are available and how the feature scope is resolved.
- **`PARENT_MODE = FEATURE`:** `feature-detail` is the primary source; feature scope is implicit. Do not ask the user to "select a feature from a list".
- **`PARENT_MODE = EPIC`:** `feature-list` is required; ask the user to select a feature; no `feature-detail` available in this context. Recommend creating a child Feature work item for richer stories.
- **Never write files before Step 4 is confirmed.** The decomposition must be approved before any file is created.
- **One story per file.** Never merge multiple stories into one file.
- **File naming is fixed:** `{feature_id}-{story_id}-{slug}.md` inside `artifacts/user-stories/`. Do not deviate.
- **Never invent acceptance criteria not backed by the wiki.** Use `> [!gap]` for missing criteria.
- **Gherkin must be syntactically valid.** Each scenario must have Given / When / Then in that order. Avoid "And" as the first keyword.
- **One scenario per distinct behavior.** Do not combine multiple behaviors into one scenario.
- **Never write to source/concept/entity pages.** User story generation is read-only on the wiki.
- **This skill is Tactical-only.** If invoked for Strategic or Product, stop immediately.
- **Business rules must be individually sourced.** Never write a rule without a [[wikilink]] to the page it came from.
