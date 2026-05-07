---
name: focus
description: "Create a new work item for the manifesto project. Use when: adding a new task or feature to the project backlog."
tools: [vscode/askQuestions, read, edit, search, todo, vscode/memory]
argument-hint: "For most types: provide a title, description, and tags. For Feature: you will select from an Epic's feature-list."
---

You are helping create a new work item for the project backlog. Follow the workflow below without unnecessary questions outside the defined steps.

## Setup

Read `docs/manifast.yaml` **once** before any step — this single read serves language detection and the existence check used in Step 0.

- If the file **exists**: extract the `language` field and set `{{language}}`. Note whether any items are present.
- If the file **does not exist**: use #tool:vscode/askQuestions to ask:
  > Q: What language should this project use?
  Options: **en** (English) · **pt-BR** (Brazilian Portuguese). Default: `en`.
  Store the answer as `{{language}}`. Treat the item list as empty.

Use `{{language}}` for **all messages displayed to the user** and **all artifact content** written throughout this command. If `{{language}}` is `pt-BR`, communicate in Brazilian Portuguese. If `{{language}}` is `en`, communicate in English.

## Reference

### Agile hierarchy

| Level     | Type       | Sample |
|-----------|------------|--------|
| Strategic | Theme      | "Improve User Experience" |
| Strategic | Initiative | "Redesign the onboarding process" |
| Product   | Epic       | "User Authentication System" |
| Product   | Feature    | "Implement social media login" |
| Tactical  | User Story | "As a user, I want to reset my password so that I can regain access to my account." |
| Tactical  | Task       | "Design the password reset page" |
| Tactical  | Bug        | "Fix the login page error when using special characters in the password" |

### Work item schema (`docs/manifast.yaml`)

```yaml
items:
  - id: title_in_underscore_slug_format
    title: A concise title for the work item
    description: A detailed description of the work item, including any relevant information or requirements
    tags: [comma-separated tags]
    hierarchyLevel: Strategic | Product | Tactical
    workItemType: Theme | Initiative | Epic | Feature | User Story | Task | Bug
    createdAt: ISO date-time
    updatedAt: ISO date-time
    path: path to the work item folder in the repository
    parent: path to the parent work item folder, or ""
```

## Workflow Overview

```
Setup: read docs/manifast.yaml once; set {{language}}
  │
  └─► Step 0: if file exists, ask Create or Select
            ├─ Create (or file missing) ──► Step 1 (1.1 → 1.2 → 1.3 → [1.4] → 1.5 → 1.6)
            │
            └─ Select ───────────-────────► Step 2
                                               │
                                           Step 3: Write .env
                                               │
                                           Step 4: Save memory
                                               │
                                           Step 5: Finish
```

Step 1.3 dispatches to sub-flows for Feature and User Story types — both return directly to Step 1.5, bypassing Step 1.4.

## Step 0: Choose Action

If `docs/manifast.yaml` **does not exist** (detected in Setup), go directly to **Step 1**.

If it **already exists**, use #tool:vscode/askQuestions to ask:
> Q: What action would you like to perform?

Options:
- **Create a new work item**: Guide through creating a new work item for the project backlog.
- **Select an existing work item**: View and select an existing work item from the project backlog.

If the user chooses `Create a new work item`, go to **Step 1**. If `Select an existing work item`, go to **Step 2**.

## Step 1: Create Work Item

### Step 1.1: Choose hierarchy level

Use #tool:vscode/askQuestions to ask:
> Q: What hierarchy level should this work item be?

Options:
- **Strategic**: Theme, Initiative
- **Product**: Epic, Feature
- **Tactical**: User Story, Task, Bug

Store the answer as `{{hierarchyLevel}}`.

### Step 1.2: Gather work item type

Based on `{{hierarchyLevel}}` from Step 1.1, ask:
> Q: What type of work item is this? (options depend on the chosen level)

Store the answer as `{{workItemType}}`.

### Step 1.3: Gather work item details

| Condition | Action |
|-----------|--------|
| `{{workItemType}}` is **Feature** | Execute [Feature Selection Flow](#feature-selection-flow). Returns with `{{workItemTitle}}`, `{{workItemDescription}}`, `{{workItemTags}}`, `{{parentPath}}` set. Then skip Step 1.4 and go to Step 1.5. |
| `{{workItemType}}` is **User Story** | Execute [User Story Selection Flow](#user-story-selection-flow). Returns with `{{workItemTitle}}`, `{{workItemDescription}}`, `{{workItemTags}}`, `{{parentPath}}` set. Then skip Step 1.4 and go to Step 1.5. |
| All other types | Ask the user to provide the fields below, then continue to Step 1.4. |

**Manual entry fields (all other types):**

- `workItemTitle` (required): A concise title for the work item.
- `workItemDescription` (optional, default: `"No description provided."`): A detailed description of the work item, including any relevant information or requirements.
- `workItemTags` (optional, default: `"No tags provided."`): Any relevant tags or labels to help categorize and prioritize the work item (comma-separated).

### Step 1.4: Select parent work item

> **Skip** if `{{workItemType}}` is **Feature** or **User Story** — parent already resolved in Step 1.3.

Valid parent types by child level:

| Child level | Valid parent types                                | Behavior |
|-------------|---------------------------------------------------|----------|
| Strategic   | *(none)*                                          | Skip silently. Set `{{parentPath}} = ""`. |
| Epic        | Strategic (Theme, Initiative)                     | Ask if candidates exist; otherwise skip silently. |
| Tactical    | Product (Epic, Feature)                           | Ask if candidates exist; otherwise skip silently. |

Using `docs/manifast.yaml` already read in Setup, filter existing items to show only valid parents for `{{hierarchyLevel}}`.

**If valid parent candidates exist**, use #tool:vscode/askQuestions to ask:
> Q: Select the parent work item (or "None" for a root-level item):

Present each candidate as:
```
{title} ({workItemType} · {hierarchyLevel}) — {path}
```
Plus a **"None — root-level item"** option at the bottom.

Set `{{parentPath}}` to the selected item's `path`, or `""` if "None".

**If no valid parent candidates exist**, skip silently and set `{{parentPath}} = ""`.

### Step 1.5: Create the work item folder

Derive `{{id}}` from `{{workItemTitle}}`: lowercase, spaces replaced with underscores, special characters removed (e.g., `"Redesign the Onboarding Process"` → `redesign_the_onboarding_process`).

Use the following mapping to determine `{{folderName}}`:

| workItemType | folderName   |
|--------------|--------------|
| Theme        | themes       |
| Initiative   | initiatives  |
| Epic         | epics        |
| Feature      | features     |
| User Story   | user-stories |
| Task         | tasks        |
| Bug          | bugs         |

Build `{{workItemPath}}` as follows:

- **If `{{workItemType}}` is User Story and `{{userStoryFromFeature}}` is `true`**:
  ```
  docs/{{hierarchyLevel}}/{{folderName}}/{{featureId}}-{{slug workItemTitle}}-stories/
  ```
  Where `{{featureId}}` is the feature ID in lowercase with hyphens (e.g., `f-001`) and `{{slug workItemTitle}}` is the lowercase, hyphen-separated version of the story action title.

- **For all other work item types**:
  ```
  docs/{{hierarchyLevel}}/{{folderName}}/{{yyyymmdd}}-{{slug workItemTitle}}/
  ```
  Where `{{yyyymmdd}}` is the current date and `{{slug workItemTitle}}` is the lowercase, hyphen-separated version of the title.

Create the following structure using #tool:edit/createDirectory:

```
docs/
  {{hierarchyLevel}}/
    {{folderName}}/
      {{yyyymmdd}}-{{slug workItemTitle}}/
        input/.gitkeep             ← place source documents here
        output/index.md            ← local wiki index (subset view of docs/wiki/)
        output/log.md              ← artifact generation log
        output/artifacts/.gitkeep  ← generated artifacts go here
```

Create `output/index.md` with this content:

```markdown
---
title: "Local Index — {{workItemTitle}}"
type: local-index
work_item: {{workItemPath}}
last_updated: {{yyyymmdd}}
---

# Local Index: {{workItemTitle}}

Pages ingested for this work item. Run `/ingest` to populate.

## Sources

## Concepts

## Entities
```

Create `output/log.md` with this content:

```markdown
# Log: {{workItemTitle}}

Activity log for this work item. Entries are prepended by `/ingest` and `/draft`.
```

### Step 1.6: Create or update manifast.yaml

**If `docs/manifast.yaml` does not exist**, create it with the full structure:

```yaml
language: {{language}}

items:
  - id: {{id}}
    title: {{workItemTitle}}
    description: {{workItemDescription}}
    tags: [{{workItemTags}}]
    hierarchyLevel: {{hierarchyLevel}}
    workItemType: {{workItemType}}
    createdAt: {{creationDate}}
    updatedAt: {{creationDate}}
    path: {{workItemPath}}
    parent: {{parentPath}}
```

**If it already exists**, append only the new item entry under the existing `items:` list — do not duplicate `language:` or any other top-level key:

```yaml
  - id: {{id}}
    title: {{workItemTitle}}
    description: {{workItemDescription}}
    tags: [{{workItemTags}}]
    hierarchyLevel: {{hierarchyLevel}}
    workItemType: {{workItemType}}
    createdAt: {{creationDate}}
    updatedAt: {{creationDate}}
    path: {{workItemPath}}
    parent: {{parentPath}}
```

After completing Step 1.6, go to **Step 3**.

## Step 2: Select Work Item

Using `docs/manifast.yaml` already read in Setup, use #tool:vscode/askQuestions to display the list of existing work items. Once selected, display its details (title, description, tags, hierarchy level, work item type, creation date, update date). Go to **Step 3**.

## Step 3: Write .env

Write the `.env` file at the repository root with the following content. If the file already exists and contains variables unrelated to `MWI_*`, preserve those lines and replace only the `MWI_*` block.

```env
MWI_ID={{id}}
MWI_TITLE={{workItemTitle}}
MWI_TAGS=[{{workItemTags}}]
MWI_LEVEL={{hierarchyLevel}}
MWI_TYPE={{workItemType}}
MWI_PATH={{workItemPath}}
MWI_PARENT={{parentPath}}
MWI_LANG={{language}}
```

Use the `Write` tool (or equivalent file-creation tool) to create or overwrite `.env`. Do not use `Edit` on a file that may not yet exist.

## Step 4: Save Memory

Save a memory entry named **"Active Work Item"** with type `project` containing the same `MWI_*` variables written above and a one-line note explaining the work item context. This ensures the active work item is recoverable after `/clear` even if `.env` is deleted.

## Step 5: Finish

Display this exact message and stop — do not continue the conversation:

```
✅ Work item "{{workItemTitle}}" is ready.

Run /clear to start a fresh context for this work item.
```

## Restrictions

- Do not create files or folders outside of the `docs` directory (the `.env` file at the project root is the only exception).
- Ensure all work items are stored in `manifast.yaml` in the correct format.
- Do not modify or delete existing work items unless explicitly instructed by the user.
- Do not ask the user for information outside the defined question steps.

---

## Sub-flows

### Feature Selection Flow

Called from Step 1.3 when `{{workItemType}}` is **Feature**. Returns to Step 1.5 with all fields set.

**Step A — Select parent Epic**

Filter `docs/manifast.yaml` for all items where `workItemType: Epic`.

- If **no Epics exist**: warn the user that no Epics were found, then fall back to manual entry (ask title/description/tags as described in Step 1.3). Set `{{parentPath}} = ""`. Return to Step 1.5.
- If **Epics exist**: use #tool:vscode/askQuestions to ask:
  > Q: Which Epic does this Feature belong to?

  Present each candidate as:
  ```
  {title} — {path}
  ```
  Plus a **"None — root-level item"** option at the bottom.

  - If the user selects **"None"**: fall back to manual entry (ask title/description/tags as described in Step 1.3). Set `{{parentPath}} = ""`. Return to Step 1.5.
  - Otherwise: set `{{parentPath}}` to the selected Epic's `path`.

**Step B — Load feature-list from selected Epic**

If an Epic was selected (not "None"), attempt to read `{{parentPath}}output/artifacts/feature-list.md`.

- If the file **does not exist**: warn the user that no feature-list was found for the selected Epic and suggest running `/draft feature-list` first. Then fall back to manual entry (ask title/description/tags as described in Step 1.3). Return to Step 1.5.
- If the file **exists**: proceed to Step C.

**Step C — Select feature from list**

Parse the `## Features` table from the feature-list. Use #tool:vscode/askQuestions to ask:
> Q: Which feature do you want to create a work item for?

Present each row as:
```
{ID} · {Feature name} — {Description} [{Priority}]
```

Map the selected row's fields:
- `{Feature name}` → `{{workItemTitle}}`
- `{Description}` → `{{workItemDescription}}`
- `{Priority}`, `{ID}` → `{{workItemTags}}` (e.g., `mvp, F-001`)

Return to **Step 1.5** — `{{parentPath}}` is already set; Step 1.4 is skipped.

---

### User Story Selection Flow

Called from Step 1.3 when `{{workItemType}}` is **User Story**. Returns to Step 1.5 with all fields set.

**Step A — List all available feature-details**

Scan `docs/manifast.yaml` for all items where `workItemType: Feature`. For each Feature item, check whether any `.md` file exists inside `{path}output/artifacts/feature-detail/`.

Build a list of Features that have at least one feature-detail artifact. Use #tool:vscode/askQuestions to ask:
> Q: Which feature do you want to derive a user story from?

Present each candidate as:
```
{Feature ID} · {title} — {description}
```
Plus a **"Standalone — create from scratch"** option at the bottom.

- If **no Features with feature-detail exist**: warn the user, automatically fall into Standalone mode (Step D below).

**Step B — Load user stories from selected feature-detail**

Read the feature-detail file found at `{selectedFeature.path}output/artifacts/feature-detail/`. If multiple files exist, read the most recent one (sort by filename descending).

Parse the **Proposed User Story Breakdown** section (a table with columns: ID, Persona, Action, Benefit or equivalent). Use #tool:vscode/askQuestions to ask:
> Q: Which user story do you want to create a work item for?

Present each row as:
```
{ID} · As a {persona}, I want {action}, so that {benefit}
```
Plus a **"← Cancel / Exit"** option that **stops the entire flow immediately**.

- If the user selects **"← Cancel / Exit"**: display "Flow cancelled." and stop — do not create any files or entries.

**Step C — Map selected story to work item fields**

From the selected user story row:
- `{action}` (short title) → `{{workItemTitle}}`
- Full sentence "As a {persona}, I want {action}, so that {benefit}." → `{{workItemDescription}}`
- `{featureId}`, `{storyId}` → `{{workItemTags}}` (e.g., `F-001, US-003`)
- Set `{{featureId}}` = the feature's ID (e.g., `F-001`)
- Set `{{parentPath}}` = `{selectedFeature.path}`

Set `{{userStoryFromFeature}} = true`. This flag changes the directory naming in Step 1.5.

Return to **Step 1.5** — `{{parentPath}}` is already set; Step 1.4 is skipped.

**Step D — Standalone mode**

Ask the user to provide title, description, and tags (same fields as the default manual entry in Step 1.3). Then display this note:
> ℹ️ Standalone user story created. Run `/ingest` to add source documents and enrich the context before generating artifacts.

Set `{{userStoryFromFeature}} = false`. Set `{{parentPath}} = ""`.

Return to **Step 1.5**.
