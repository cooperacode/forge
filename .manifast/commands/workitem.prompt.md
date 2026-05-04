---
name: workitem
description: "Create a new work item for the manifesto project. Use when: adding a new task or feature to the project backlog."
tools: [vscode/askQuestions, read, edit, search, todo, vscode/memory]
argument-hint: "Provide a title for the work item, a detailed description, and any relevant tags or labels."
---

You are helping create a new work item for the project backlog.

> DON'T ASK NOTHING. JUST FOLLOW THE INSTRUCTIONS BELOW TO CREATE A NEW WORK ITEM AND STORE IT IN THE `manifast.yaml` FILE LOCATED IN THE `docs` FOLDER OF THE PROJECT REPOSITORY.

## Language

Before doing anything else, read `docs/manifast.yaml` and extract the `language` field. Store it as `{{language}}`. If the field is absent, default to `en`.

Use `{{language}}` for **all messages you display to the user** and **all artifact content** you write throughout this command. If `{{language}}` is `pt-BR`, communicate in Brazilian Portuguese. If `{{language}}` is `en`, communicate in English.

## Context

Here is the most widely accepted division and {{hierarchyLevel}} in the agile model, organized from the most strategic (macro) to the most tactical and technical (micro) level:

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

All work items should be stored in a `manifast.yaml` file located in the `docs` folder of the project repository. Each work item should include the following details:

```yaml
items:
  - title: A concise title for the work item
    description: A detailed description of the work item, including any relevant information or requirements
    tags: Any relevant tags or labels to help categorize and prioritize the work item (comma-separated)
    hierarchyLevel: The hierarchy level of the work item (e.g., Strategic, Product, Tactical)
    workItemType: The specific type of work item (e.g., Theme, Initiative, Epic, Feature, User Story, Task, Bug)
    createdAt: The date and time when the work item was created
    updatedAt: The date and time when the work item was last updated
```

The `.env` file should be used to store environment variables related to the currently selected work item, such as its title, tags, hierarchy level, type, and path in the repository.

## Instructions

> FOLLOW THE INSTRUCTIONS BELOW TO CREATE A NEW WORK ITEM AND STORE IT IN THE `manifast.yaml` FILE LOCATED IN THE `docs` FOLDER OF THE PROJECT REPOSITORY.

### step 0: Choose the action to perform

If the `manifast.yaml` file does not exist in the `docs` folder, go to **step 1**. If it already exists, Use #tool:vscode/askQuestions to ask:
> Q: What action would you like to perform?

The user should choose one of the following actions:
- **Create a new work item**: This will guide you through the process of creating a new work item for the project backlog.
- **Select an existing work item**: This will allow you to view and edit the details of an existing work item in the project backlog.

If the user chooses "Create a new work item", go to **step 1**. If the user chooses "Select an existing work item", go to **step 2**.

### step 1: Create a new work item

#### step 1.1: Choose the hierarchy level 

Use #tool:vscode/askQuestions to ask:
> Q: What hierarchy level should this work item be?

The user to choose the `{{hierarchyLevel}}` level for the new work item. The options should include:
- **Strategic**: Theme, Initiative
- **Product**: Epic, Feature
- **Tactical**: User Story, Task, Bug

#### step 1.2: Gather work item type

Verify the `{{hierarchyLevel}}` chosen in step 1.1 and then ask the user to specify the `{{workItemType}}` within that hierarchy level. For example, if the user chose "Product", ask:
> Q: What type of work item is this? (e.g., Epic, Feature).

#### step 1.3: Gather work item details

Ask the user to provide the following details for the new `{{workItemType}}`:

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

After gathering the details above, read `docs/workitems.yaml` (if it exists).

Filter the existing items to show only **valid parents** for the chosen `{{hierarchyLevel}}`:

| Child level | Valid parent levels |
|-------------|-------------------|
| Strategic   | Strategic          |
| Product     | Strategic          |
| Tactical    | Product            |

**If valid parent candidates exist**, use #tool:vscode/askQuestions to ask:
> Q: Select the parent work item (or "None" for a root-level item):

Present each candidate as:
```
{title} ({workItemType} · {hierarchyLevel}) — {path}
```
Plus a **"None — root-level item"** option at the bottom of the list.

Set `{{parentPath}}` to the selected item's `path`, or `""` if the user chose "None".

**If no valid parent candidates exist** (file absent or no items at the valid levels), skip this question silently and set `{{parentPath}} = ""`.

#### step 1.4: Create the work item folder

Based on the `{{hierarchyLevel}}` and `{{workItemType}}` provided, create a new folder (`{{workItemPath}}`) in the appropriate directory structure. For example:

- For a "Feature" under "Product", use #tool:edit/createDirectory to create a folder at `docs/product/features/{{yyyymmdd}}-{{slug workItemTitle}}/`.
- For a "User Story" under "Tactical", use #tool:edit/createDirectory to create a folder at `docs/tactical/user-stories/{{yyyymmdd}}-{{slug workItemTitle}}/`.
...

The `{{workItemPath}}` shold be created following the structure: `docs/{{hierarchyLevel}}/{{workItemType}}s/{{yyyymmdd}}-{{slug workItemTitle}}/`. Make sure to replace `{{hierarchyLevel}}`, `{{workItemType}}`, `{{yyyymmdd}}`, and `{{slug workItemTitle}}` with the appropriate values based on the user's input and the current date.

The `{{workItemPath}}` should have two subfolders: `input` and `output`, which will be used to store any relevant files or documentation related to the work item.
The final folder structure for the new work item should look like this:

```
docs/
  {{hierarchyLevel}}/
    {{workItemType}}s/
      {{yyyymmdd}}-{{slug workItemTitle}}/
        input/.gitkeep
        output/.gitkeep
        context/.gitkeep
```

#### step 1.5: Create/Edit the manifast.yaml file

If the `manifast.yaml` file does not exist in the `docs` folder, use #tool:edit/createFile to create it. 
If it already exists, read its content and append the new work item details to the existing list of items.
Inside the `docs` folder, create a `manifast.yaml` file that includes the following structure:

```yaml
language: {{language}}

items:
  - title: {{slug workItemTitle}}
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

Use #tool:read to read the existing `manifast.yaml` file and use #tool:vscode/askQuestions to display a list of existing work items to the user. The user can then select a work item.
Once a work item is selected, display its details (title, description, tags, hierarchy level, work item type, creation date, update date) to the user. Go to **step 3** to update the environment variables for the selected work item.

### step 3: Edit environment variables file

If the file `.env` does not exist, use #tool:edit/createFile to create it. If it already exists, use #tool:edit/editFiles and replace or append the existing content with the updated environment variables. The `.env` file should include the following structure:

```env
MWI_TITLE={{slug workItemTitle}}
MWI_TAGS=[{{workItemTags}}]
MWI_LEVEL={{hierarchyLevel}}
MWI_TYPE={{workItemType}}
MWI_PATH={{workItemPath}}
MWI_PARENT={{parentPath}}
MWI_LANG={{language}}
```

Use the details of the selected work item to populate the environment variables in the `.env` file. Make sure to replace `{{workItemTitle}}`, `{{workItemTags}}`, `{{hierarchyLevel}}`, `{{workItemType}}`, and `{{workItemPath}}` with the appropriate values based on the selected work item.

### Step 4: Store the .env file content in memory

After successfully creating a new work item or selecting an existing one and updating the environment variables, 
use #tool:read/readFile to read the `.env` file and store its content in memory using #tool:vscode/memory.

## Summary

In this prompt, you will create a new work item for the project backlog and store it in the `manifast.yaml` file located in the `docs` folder of the project repository. You will follow a structured workflow that includes choosing the hierarchy level and work item type, gathering details about the work item, creating the necessary folder structure, and updating the `manifast.yaml` file with the new work item information. Additionally, you will update the `.env` file with environment variables related to the currently selected work item.

## Algorithmically, the process can be summarized as follows:

1. Check if `manifast.yaml` exists in the `docs` folder.
2. If it does not exist, prompt the user to create a new work item and go to **step 1**.
3. If it exists, ask the user if they want to create a new work item or select an existing one.
4. If the user chooses to create a new work item, follow the steps to gather details, create the folder structure, and update the `manifast.yaml` file.
5. If the user chooses to select an existing work item, display the list of existing work items and allow them to select one.
6. Once a work item is selected, display its details and update the environment variables in the `.env` file accordingly.

## Restrictions
- Do not create any files or folders outside of the `docs` directory.
- Ensure that all work items are stored in the `manifast.yaml` file in the correct format.
- Do not modify or delete existing work items in the `manifast.yaml` file unless explicitly instructed by the user.
- Ensure that the environment variables in the `.env` file are updated correctly based on the selected work item.
- Do not ask the user for any information that is not relevant to creating or selecting a work item.
- JUST FOLLOW THE INSTRUCTIONS AND WORKFLOW OUTLINED IN THIS PROMPT TO ENSURE CONSISTENCY AND ACCURACY IN MANAGING WORK ITEMS FOR THE PROJECT BACKLOG. DO NOT DEVIATE FROM THE STEPS OR REQUIREMENTS SPECIFIED IN THIS PROMPT.
