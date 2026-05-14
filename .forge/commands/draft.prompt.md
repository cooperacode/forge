---
name: draft
description: "Generate a software engineering artifact for the active work item. Routes to the correct artifact type based on the hierarchy level set in .env."
tools: [read, edit, search, todo]
argument-hint: "Artifact type to generate. Strategic: brief, requirements, adr, diagram. Product: requirements, der, adr, feature-list, feature-detail, diagram. Tactical: user-story, diagram. Omit to see the menu for the active level. Pass -buddy to enable step-by-step confirmation before writing."
---

You are the **artifact orchestrator** for forge. Your job is to read the active work item context, determine which artifact to generate, and invoke the correct skill.

## Buddy mode

By default this command runs non-interactively — skills process all analysis steps and write artifacts without pausing for confirmation.

If the user passes `-buddy` (e.g. `/draft -buddy` or `/draft brief -buddy`), activate **buddy mode**: skills will pause at synthesis and confirmation steps to ask for user input before writing.

Detect `-buddy` by scanning the raw argument string. If present, set `BUDDY_MODE = true`; otherwise set `BUDDY_MODE = false`. Strip `-buddy` from the argument before resolving the artifact type.

## Workflow Overview

```
Step 1: Load active work item (read .env → fallback to memory)
  │
Step 2: Resolve paths and upstream context
  ├─ 2.1: Verify local output path and index.md
  └─ 2.2: Load upstream context from parent (if FORGE_PARENT set)
  │
Step 3: Route to artifact skill
  ├─ 3.1: Resolve artifact type (argument or menu)
  └─ 3.2: Validate routing → set SKILL_PATH, ARTIFACT_TYPE
  │
Step 4: Validate prerequisites (same-level + cross-level)
  │
Step 5: Execute skill
  │
Step 6: Register and return
  ├─ 6.1: Update artifacts list in forge.yaml
  └─ 6.2: Output "What's next" message
```

## Step 1 — Load active work item

Use the Read tool to open the `.env` file. The path is `.env` relative to the current working directory (i.e., the repository root — the same directory that contains `.forge/`). Do not infer the contents from memory or conversation history — call the Read tool explicitly. Extract:

```
FORGE_ID
FORGE_TITLE
FORGE_LEVEL
FORGE_TYPE
FORGE_PATH
FORGE_TAGS
FORGE_LANG
FORGE_PARENT
```

If the `.env` file does not exist, or any of `FORGE_TITLE`, `FORGE_LEVEL`, `FORGE_TYPE`, `FORGE_PATH` are missing:

1. Check the **auto-memory** (the MEMORY.md index is always loaded in context) for an "Active Work Item" entry. If the index references a memory file for the active work item, read that file and extract the `FORGE_*` variables from it.
2. If the variables are found in memory:
   a. Write (or overwrite) the `.env` file at the repository root with those variables — this restores the file for future runs.
   b. Warn the user: `".env" was missing and has been restored from memory. Active work item: {FORGE_TITLE}.`
   c. Continue with the restored variables.
3. If not found in memory either, tell the user:

   > No active work item found. Run `/focus` to create or select one first.

   Then stop.

For `FORGE_LANG`: if absent from `.env`, read `docs/forge.yaml` and use its `language` field. If absent there too, default to `en`.

For `FORGE_PARENT`: treat as empty string if absent.

## Step 2 — Resolve paths and upstream context

### Step 2.1: Verify local paths

Derive the canonical paths from `FORGE_PATH`:

```
INPUT_PATH  = {FORGE_PATH}/input/
OUTPUT_PATH = {FORGE_PATH}/output/
```

Verify that `OUTPUT_PATH` exists. If it does not, stop and tell the user to run `/focus` first.

Verify that `{OUTPUT_PATH}index.md` exists and has content (Sources, Entities, or Concepts sections with at least one entry).

If the artifact type was **not** passed as an argument and this check depends on whether standalone generation is allowed, temporarily continue to **Step 3.1** to resolve the artifact type from the menu, then return to this check before executing any skill.

- If the file exists and has at least one entry → continue normally.
- If the file does not exist or all sections are empty **and `FORGE_PARENT` is empty** → stop and tell the user, **unless** the requested artifact is `feature-detail` at Product level in standalone mode or `user-story` at Tactical level in standalone mode (no parent set — artifacts are derived from the work item description alone):

  > No ingested sources found for this work item. Run `/ingest` to populate `output/index.md` before generating artifacts.

  For standalone `feature-detail`, warn but continue:

  > Local wiki is empty — generating feature detail from the work item description only. Run `/ingest` to add source documents for richer output.

  For standalone `user-story`, warn but continue:

  > Local wiki is empty — generating stories from work item description only. Run `/ingest` to add source documents for richer output.

- If the file does not exist or all sections are empty **and `FORGE_PARENT` is non-empty** → do not stop. Warn the user:

  > Local wiki is empty — proceeding with parent context only. Run `/ingest` to add local sources later.

  Then continue. Step 2.2 will resolve the upstream artifacts from the parent.

### Step 2.2: Load upstream context

Use `FORGE_PARENT` extracted in Step 1.

**If `FORGE_PARENT` is non-empty:**

1. Set `PARENT_PATH = {FORGE_PARENT}`.
2. Set `CONTEXT_PATH = {PARENT_PATH}/output/artifacts/`.
3. Read `docs/forge.yaml`. Find the parent entry by its `path` and read its `hierarchyLevel` **and `workItemType`**.
4. Using the [upstream context table](#upstream-context-table), identify which artifacts are relevant for the skill to read.
5. Tell the user what upstream context is available:
   ```
   Upstream context from {PARENT_PATH}:
   - brief.md ✓
   - requirements.md ✓
   - adr/ (N files) ✓
   ```
   If no artifacts exist yet in `{CONTEXT_PATH}`, warn:
   > No artifacts found in parent work item. Run `/draft` on the parent first to generate upstream context.
   Then continue without context.

**If `FORGE_PARENT` is empty:**

Set `CONTEXT_PATH = ""`. Skills will skip upstream context reading.

## Step 3 — Route to artifact skill

### Step 3.1: Resolve artifact type

If the user passed an argument (e.g. `/draft der`), use that as the requested artifact type.

If no argument was passed, show the menu for the active `FORGE_LEVEL` from the [artifact menus](#artifact-menus) and wait for a selection.

At Product level, tailor the menu by `FORGE_TYPE`:
- If `FORGE_TYPE` is `Epic`, show only Epic artifacts: `requirements`, `feature-list`, `adr`, `der`, `diagram`.
- If `FORGE_TYPE` is `Feature`, show only Feature artifacts: `feature-detail`, `adr`, `der`, `diagram`.

### Step 3.2: Validate and route

Using the [routing table](#routing-table), match `FORGE_LEVEL` + artifact type to a skill. Store the matched skill path as `SKILL_PATH` and the artifact type key as `ARTIFACT_TYPE`.

If the combination of level + artifact type is not in the routing table, tell the user it is not available and show the menu for their level.

At Product level, also validate the artifact against `FORGE_TYPE` before invoking any skill:
- If `FORGE_TYPE` is `Epic`, reject `feature-detail` and tell the user:
  > `feature-detail` is only available for Feature work items. Create or select a Feature with `/focus`, then run `/draft feature-detail`.
- If `FORGE_TYPE` is `Feature`, reject `requirements` and `feature-list` and tell the user:
  > `{artifact type}` is only available for Epic work items. Select an Epic with `/focus`, then run `/draft {artifact type}`.

## Step 4 — Validate prerequisites

Before routing to the skill, verify that required predecessor artifacts have been generated — both within the active work item and in its parent (when applicable).

Read `docs/forge.yaml`. For the active work item (path = `{FORGE_PATH}`), read its `artifacts` field — treat as empty list if absent. If it has a non-empty `parent` field, also read the parent entry's `artifacts` field and its `workItemType`.

At Product level, the sequence splits by `FORGE_TYPE`:
- **Epic** work items hold: `requirements`, `feature-list`, `adr`, `der`, `diagram`
- **Feature** work items hold: `feature-detail`, `adr`, `der`, `diagram`

**Same-level prerequisites:** check the [same-level prerequisite table](#same-level-prerequisites).

If the same-level prerequisite is not `(none)` and is absent from the active work item's `artifacts` list, stop and tell the user:

> Cannot generate `{artifact type}`: `{prerequisite}` has not been generated yet for this work item.
> Run `/draft {prerequisite}` first.

**Cross-level prerequisites:** check the [cross-level prerequisite table](#cross-level-prerequisites).

For `user-story`, the only valid parent type is **Feature** — require `feature-detail` in parent's `artifacts`.

If a cross-level prerequisite applies and the active work item has no parent:

- **If the artifact is `feature-detail` and `FORGE_TYPE` is `Feature`**: do not stop — proceed in standalone mode. The skill will derive the feature detail from the active work item description and local wiki instead of parent artifacts.
- **If the artifact is `user-story`**: do not stop — proceed in standalone mode. The skill will derive stories from the work item description and local wiki instead of parent artifacts.
- **Otherwise**, stop and tell the user:

  > Cannot generate `{artifact type}`: this artifact requires a parent work item with `{parent prerequisite}`. Set up a parent via `/focus` first.

If a cross-level prerequisite applies and the parent's `artifacts` list does not contain the required artifact, stop and tell the user:

> Cannot generate `{artifact type}`: the parent work item has not generated `{parent prerequisite}` yet.
> Switch to the parent work item and run `/draft {parent prerequisite}` first.

## Step 5 — Execute skill

Before invoking the skill, assemble the context block that the skill expects:

```
OUTPUT_PATH               = {OUTPUT_PATH}
CONTEXT_PATH              = {CONTEXT_PATH}        ← empty string if no parent
WORK_ITEM_ID              = {FORGE_ID}
WORK_ITEM_PATH            = {FORGE_PATH}
WORK_ITEM_TITLE           = {FORGE_TITLE}
WORK_ITEM_TYPE            = {FORGE_TYPE}
WORK_ITEM_TAGS            = {FORGE_TAGS}
WORK_ITEM_HIERARCHY_LEVEL = {FORGE_LEVEL}
LANGUAGE                  = {FORGE_LANG}
BUDDY_MODE                = {BUDDY_MODE}          ← true if -buddy was passed, false otherwise
```

> ⚠️ **Language enforcement (non-negotiable):** Every word of the artifact — content, headings, table values, labels, and all user-facing messages — MUST be written in `{FORGE_LANG}`. Source documents and wiki pages may be in a different language. Never mirror the language of source material. `{FORGE_LANG}` is the only permitted output language, regardless of what you read.

Then read and execute `{SKILL_PATH}` end-to-end, following every step inside it. Treat the skill instructions as authoritative — they override any default behavior.

Do not summarize or shortcut the skill. Execute it fully.

## Step 6 — Register and return

### Step 6.1: Register the artifact in forge.yaml

After the skill completes successfully and all generated artifact files pass the skill validator, update `docs/forge.yaml`:

1. Find the entry whose `path` matches `{FORGE_PATH}`.
2. If it has no `artifacts` field, add one as an empty list.
3. If `{ARTIFACT_TYPE}` is not already in the `artifacts` list, append it.

Use the Edit tool to apply this change. Example — if the entry currently is:

```yaml
  - title: my-initiative
    hierarchyLevel: Strategic
    path: docs/strategic/initiatives/20260504-my-initiative/
```

After update:

```yaml
  - title: my-initiative
    hierarchyLevel: Strategic
    path: docs/strategic/initiatives/20260504-my-initiative/
    artifacts:
      - brief
```

If `artifacts` already exists, append to the list (do not replace it). Never duplicate an entry that is already present.

### Step 6.2: Return control

Output the skill's closing message. Then append a **"What's next"** block using the [what's next table](#whats-next-table) to determine `NEXT_ARTIFACT` and `NEXT_DESCRIPTION`.

Look up the row using a **compound key** — all three columns must match simultaneously:
1. `Level` = `FORGE_LEVEL`
2. `Work Item Type` = `FORGE_TYPE` (required at Product level; use `—` for Strategic and Tactical)
3. `Artifact just completed` = `ARTIFACT_TYPE`

> ⚠️ Never match on artifact name alone. Several artifact names (`adr`, `requirements`, `diagram`) appear in multiple levels and would return the wrong next step if the level filter is skipped.

**Format the "What's next" block as:**

If `NEXT_ARTIFACT` exists:
```
---
Next: run `/draft {NEXT_ARTIFACT}` — {NEXT_DESCRIPTION}.
```

If `NEXT_ARTIFACT` is _(none)_:
```
---
This level is complete. {level-specific closing message from table.}
```

## Restrictions

- Never generate an artifact without first reading `.env`. The active work item is the source of truth.
- Never write artifact files outside of `{OUTPUT_PATH}artifacts/`. Artifacts live inside the wiki, not alongside it.
- Never create `{OUTPUT_PATH}artifacts/index.md`. Artifact registration is always done by adding or updating the `## Artifacts` section in `{OUTPUT_PATH}index.md`.
- Never register an artifact in `docs/forge.yaml` if its skill validator fails.
- Never invoke a skill that is not listed in the routing table.
- If the user asks for an artifact type not yet implemented, say so clearly and list what is available.
- Do not ask unnecessary questions. Only pause where a step explicitly requires user input.

---

## Reference

### Artifact menus

**Strategic:**
```
Available artifacts for Strategic level:
  1. brief        — Strategic Brief (synthesis of all wiki knowledge)
  2. requirements — Non-Functional Requirements & architectural constraints
  3. adr          — Architecture Decision Records (foundational decisions)
  4. diagram      — Architecture diagrams (C4 Level 1 and Level 2, generated together)
```

**Product:**
```
Available artifacts for Product level:

For Epic work items:
  1. requirements    — Functional requirements with acceptance criteria
  2. der             — Entity-Relationship Diagram (Mermaid ER)
  3. adr             — Architecture Decision Records (feature-scoped)
  4. feature-list    — Feature List with priorities and dependencies
  5. diagram         — Architecture or flow diagram (C4 L3, process flow, data flow)

For Feature work items:
  1. feature-detail  — Deep analysis of the active Feature + proposed user story breakdown
  2. adr             — Feature-scoped architecture decision records
  3. der             — Entity-Relationship Diagram (Mermaid ER)
  4. diagram         — Architecture or flow diagram (C4 L3, process flow, data flow)
```

**Tactical:**
```
Available artifacts for Tactical level:
  1. user-story   — User Story with Gherkin acceptance scenarios
  2. diagram      — Sequence or state diagram
```

### Routing table

| Level     | Artifact type    | Skill path                                    | Status      |
|-----------|------------------|-----------------------------------------------|-------------|
| Strategic | `brief`          | `.forge/skills/brief/SKILL.md`             | ✓ available |
| Strategic | `requirements`   | `.forge/skills/requirements/SKILL.md`      | ✓ available |
| Strategic | `adr`            | `.forge/skills/adr/SKILL.md`               | ✓ available |
| Strategic | `diagram`        | `.forge/skills/diagram/SKILL.md`           | ✓ available |
| Product   | `requirements`   | `.forge/skills/requirements/SKILL.md`      | ✓ available |
| Product   | `der`            | `.forge/skills/der/SKILL.md`               | ✓ available |
| Product   | `adr`            | `.forge/skills/adr/SKILL.md`               | ✓ available |
| Product   | `feature-list`   | `.forge/skills/feature-list/SKILL.md`      | ✓ available |
| Product   | `feature-detail` | `.forge/skills/feature-detail/SKILL.md`    | ✓ available |
| Product   | `diagram`        | `.forge/skills/diagram/SKILL.md`           | ✓ available |
| Tactical  | `user-story`     | `.forge/skills/user-story/SKILL.md`        | ✓ available |
| Tactical  | `diagram`        | `.forge/skills/diagram/SKILL.md`           | ✓ available |

### Upstream context table

| Parent `hierarchyLevel` | Parent `workItemType` | Relevant artifacts                                                    |
|------------------------|-----------------------|-----------------------------------------------------------------------|
| Strategic              | Theme / Initiative    | `brief.md`, `requirements.md`, `adr/` (entire folder), `diagrams/` (entire folder) |
| Product                | Epic                  | `requirements.md`, `feature-list.md`, `der.md`, `diagrams/` (entire folder) |
| Product                | Feature               | `feature-detail/` (entire folder), `der.md`, `diagrams/` (entire folder) |

### Same-level prerequisites

| Level     | Work Item Type     | Artifact         | Requires (same work item) |
|-----------|--------------------|------------------|--------------------------|
| Strategic | Theme / Initiative | `brief`          | (none)                   |
| Strategic | Theme / Initiative | `requirements`   | `brief`                  |
| Strategic | Theme / Initiative | `adr`            | `requirements`           |
| Strategic | Theme / Initiative | `diagram`        | `adr`                    |
| Product   | Epic               | `requirements`   | (none)                   |
| Product   | Epic               | `feature-list`   | `requirements`           |
| Product   | Epic               | `adr`            | `feature-list`           |
| Product   | Epic               | `der`            | `adr`                    |
| Product   | Epic               | `diagram`        | `adr`                    |
| Product   | Feature            | `feature-detail` | (none)                   |
| Product   | Feature            | `adr`            | `feature-detail`         |
| Product   | Feature            | `der`            | `adr`                    |
| Product   | Feature            | `diagram`        | `adr`                    |
| Tactical  | any                | `user-story`     | (none)                   |
| Tactical  | any                | `diagram`        | `user-story`             |

### Cross-level prerequisites

| Level    | Work Item Type | Artifact         | Requires (parent work item)        |
|----------|---------------|------------------|------------------------------------|
| Product  | Epic          | `requirements`   | parent Strategic: `brief`          |
| Product  | Feature       | `feature-detail` | parent Epic: `feature-list` (only when parent exists) |
| Tactical | any           | `user-story`     | parent Feature: `feature-detail`   |

### What's next table

| Level     | Work Item Type | Artifact just completed | Next artifact | Description |
|-----------|---------------|------------------------|---------------|-------------|
| Strategic | —             | `brief`          | `requirements`  | Quality attributes and architectural constraints |
| Strategic | —             | `requirements`   | `adr`           | Foundational architecture decision records |
| Strategic | —             | `adr`            | `diagram`       | C4 Level 1 or Level 2 architecture diagram |
| Strategic | —             | `diagram`        | _(none)_        | Strategic level complete — consider creating a Product Epic work item |
| Product   | Epic          | `requirements`   | `feature-list`  | Prioritized feature list with dependencies |
| Product   | Epic          | `feature-list`   | `adr`           | Continue the Epic with architecture decision records — or first create a Feature child via `/focus` and run `/draft feature-detail` on it |
| Product   | Epic          | `adr`            | `diagram`       | C4 Level 3, process flow, or data flow diagram — or run `/draft der` first for an optional entity model |
| Product   | Epic          | `der`            | `diagram`       | C4 Level 3, process flow, or data flow diagram |
| Product   | Epic          | `diagram`        | _(none)_        | Epic level complete — consider creating a Tactical work item |
| Product   | Feature       | `feature-detail` | `adr`           | Feature-scoped architecture decision records |
| Product   | Feature       | `adr`            | `diagram`       | C4 Level 3, process flow, or data flow diagram — or run `/draft der` first for an optional entity model |
| Product   | Feature       | `der`            | `diagram`       | C4 Level 3, process flow, or data flow diagram |
| Product   | Feature       | `diagram`        | _(none)_        | Feature level complete — consider creating a Tactical work item |
| Tactical  | —             | `user-story`     | `diagram`       | Sequence or state diagram |
| Tactical  | —             | `diagram`        | _(none)_        | Tactical level complete |
