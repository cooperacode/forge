---
name: workitem
description: "Create a new work item for the manifesto project. Use when: adding a new task or feature to the project backlog."
tools: [vscode/askQuestions, read, edit, search, todo, vscode/memory]
argument-hint: "Provide a title for the work item, a detailed description, and any relevant tags or labels."
---

You are helping create a new work item for the project backlog. Follow the workflow below without unnecessary questions outside the defined steps.

## Preamble: Resolve Global Variables

Before doing anything else, attempt to read `docs/manifast.yaml` **once** — this single read serves both the language detection and the existence check used in step 0.

- If the file **exists**: extract the `language` field and set `{{language}}`. Note whether any items are present.
- If the file **does not exist**: set `{{language}} = "en"`. Treat the item list as empty.

Use `{{language}}` for **all messages displayed to the user** and **all artifact content** written throughout this command. If `{{language}}` is `pt-BR`, communicate in Brazilian Portuguese. If `{{language}}` is `en`, communicate in English.

## Context

Here is the most widely accepted hierarchy in the agile model, organized from the most strategic (macro) to the most tactical and technical (micro) level:

```yaml
hierarchy:
  - strategic:
    - Theme:
        description: A collection of related work that supports a common goal or area of focus.
        composition: Themes help organize and prioritize work across multiple epics and initiatives.
        sample: "Improve User Experience"
    - Initiative:
        description: A high-level effort that drives significant business value and aligns with strategic goals.
        composition: It often encompasses multiple epics and is focused on achieving a specific outcome or objective.
        sample: "Redesign the onboarding process"
  - product:
    - Epic:
        description: A large body of work that can be broken down into smaller tasks or user stories.
        composition: Epics are typically focused on a specific feature or functionality and may span multiple sprints.
        sample: "User Authentication System"
    - Feature:
        description: A distinct piece of functionality that delivers value to the user.
        composition: Features are often derived from epics and can be completed within a single sprint.
        sample: "Implement social media login"
  - tactical:
    - User Story:
        description: A short, simple description of a feature or functionality from the perspective of the end user.
        composition: User stories are typically written in the format "As a [user], I want [feature] so that [benefit]."
        sample: "As a user, I want to reset my password so that I can regain access to my account."
    - Task:
        description: A specific piece of work that needs to be completed.
        composition: Tasks are often derived from user stories and represent the individual steps required to implement a feature or functionality.
        sample: "Design the password reset page"
    - Bug:
        description: An issue or defect in the software that needs to be fixed.
        composition: Bugs are typically reported by users or testers and require investigation and resolution.
        sample: "Fix the login page error when using special characters in the password"
```

All work items are stored in `docs/manifast.yaml`. Each work item includes:

```yaml
items:
  - title: A concise title for the work item
    description: A detailed description of the work item, including any relevant information or requirements
    tags: Any relevant tags or labels to help categorize and prioritize the work item (comma-separated)
    hierarchyLevel: The hierarchy level of the work item (e.g., Strategic, Product, Tactical)
    workItemType: The specific type of work item (e.g., Theme, Initiative, Epic, Feature, User Story, Task, Bug)
    createdAt: The date and time when the work item was created
    updatedAt: The date and time when the work item was last updated
    path: The path to the work item folder in the repository
    parent: The path to the parent work item folder, or "" for root-level items
```

## Instructions

### step 0: Choose the action to perform

If `docs/manifast.yaml` **does not exist** (resolved in Preamble), go directly to **step 1**.

If it **already exists**, use #tool:vscode/askQuestions to ask:
> Q: What action would you like to perform?

Options:
- **Create a new work item**: Guide through creating a new work item for the project backlog.
- **Select an existing work item**: View and select an existing work item from the project backlog.

If the user chooses "Create a new work item", go to **step 1**. If "Select an existing work item", go to **step 2**.

### step 1: Create a new work item

#### step 1.1: Choose the hierarchy level

Use #tool:vscode/askQuestions to ask:
> Q: What hierarchy level should this work item be?

Options:
- **Strategic**: Theme, Initiative
- **Product**: Epic, Feature
- **Tactical**: User Story, Task, Bug

Store the answer as `{{hierarchyLevel}}`.

#### step 1.2: Gather work item type

Based on `{{hierarchyLevel}}` from step 1.1, ask:
> Q: What type of work item is this? (options depend on the chosen level)

Store the answer as `{{workItemType}}`.

#### step 1.3: Gather work item details

Ask the user to provide:

```yaml
arguments:
  - name: workItemTitle
    description: A concise title for the work item
    required: true
  - name: workItemDescription
    description: A detailed description of the work item, including any relevant information or requirements
    required: false
    default: "No description provided."
  - name: workItemTags
    description: Any relevant tags or labels to help categorize and prioritize the work item (comma-separated)
    required: false
    default: "No tags provided."
```

#### step 1.3b: Select parent work item

Using `docs/manifast.yaml` already read in the Preamble, filter existing items to show only **valid parents** for `{{hierarchyLevel}}`:

| Child level | Valid parent types                              |
|-------------|--------------------------------------------------|
| Strategic   | *(none — Strategic items are always root-level)* |
| Product     | Strategic (Theme, Initiative)                    |
| Tactical    | Product (Epic, Feature)                          |

**If `{{hierarchyLevel}}` is Strategic**, skip this question silently and set `{{parentPath}} = ""`.

**If valid parent candidates exist** for other levels, use #tool:vscode/askQuestions to ask:
> Q: Select the parent work item (or "None" for a root-level item):

Present each candidate as:
```
{title} ({workItemType} · {hierarchyLevel}) — {path}
```
Plus a **"None — root-level item"** option at the bottom.

Set `{{parentPath}}` to the selected item's `path`, or `""` if "None".

**If no valid parent candidates exist**, skip silently and set `{{parentPath}} = ""`.

#### step 1.4: Create the work item folder

Use the following mapping to determine the folder name for `{{workItemType}}`:

| workItemType | folderName   |
|--------------|--------------|
| Theme        | themes       |
| Initiative   | initiatives  |
| Epic         | epics        |
| Feature      | features     |
| User Story   | user-stories |
| Task         | tasks        |
| Bug          | bugs         |

Build `{{workItemPath}}` as:
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

Activity log for this work item. Entries are prepended by `/ingest` and `/artifact`.
```

#### step 1.5: Create/Edit the manifast.yaml file

**If `docs/manifast.yaml` does not exist**, create it with the full structure:

```yaml
language: {{language}}

items:
  - title: {{workItemTitle}}
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
  - title: {{workItemTitle}}
    description: {{workItemDescription}}
    tags: [{{workItemTags}}]
    hierarchyLevel: {{hierarchyLevel}}
    workItemType: {{workItemType}}
    createdAt: {{creationDate}}
    updatedAt: {{creationDate}}
    path: {{workItemPath}}
    parent: {{parentPath}}
```

### step 2: Select an existing work item

Using `docs/manifast.yaml` already read in the Preamble, use #tool:vscode/askQuestions to display the list of existing work items. Once selected, display its details (title, description, tags, hierarchy level, work item type, creation date, update date). Go to **step 3**.

### step 3: Edit environment variables file

If `.env` does not exist, use #tool:edit/createFile to create it. If it already exists, use #tool:edit/editFiles to replace only the `MWI_*` variables, preserving any other variables already present in the file.

```env
MWI_TITLE={{workItemTitle}}
MWI_TAGS=[{{workItemTags}}]
MWI_LEVEL={{hierarchyLevel}}
MWI_TYPE={{workItemType}}
MWI_PATH={{workItemPath}}
MWI_PARENT={{parentPath}}
MWI_LANG={{language}}
```

### Step 4: Store the .env content in memory

Read the `.env` file using #tool:read/readFile and store its content in memory using #tool:vscode/memory

### Step 5: Finish

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
