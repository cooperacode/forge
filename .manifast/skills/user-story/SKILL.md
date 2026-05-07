---
name: user-story
description: "Generate User Story artifacts with Gherkin acceptance scenarios, Definition of Done, and dependency map from the active wiki. Tactical level only. Stories are scoped to a specific feature and saved individually under artifacts/user-stories/."
---

# Skill: User Story

You were invoked by the orchestrator because the user wants to generate User Stories from the active wiki. Your job is to identify which feature the stories will cover, decompose it into implementable stories, confirm the breakdown with the user, then write one file per story.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, `WORK_ITEM_TYPE`, `CONTEXT_PATH`, and `LANGUAGE` — use those values for all file operations and metadata.

This skill is for **Tactical-level work items only** (User Story, Task, Bug). If `{WORK_ITEM_TYPE}` is Strategic or Product, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

> ⚠️ **Language lock:** Write the entire artifact — content, headings, table values, and all messages — in `{LANGUAGE}`. Source documents may be in a different language; never mirror them. This constraint is active from the first character to the last, throughout every step.

---

## Step 1 — Detect parent mode

Attempt to read `{OUTPUT_PATH}index.md` and set `LOCAL_WIKI`:

| `{OUTPUT_PATH}index.md` | Action |
|--------------------------|--------|
| exists and has content   | Set `LOCAL_WIKI = true`. Note the total number of pages indexed. |
| missing or empty         | Set `LOCAL_WIKI = false`. The skill will rely on the parent's artifacts or work item description as the sole source. |

`{CONTEXT_PATH}` points to the **direct parent** work item's `output/artifacts/`. What is available there determines the parent mode. Check `{CONTEXT_PATH}`:

- **If `{CONTEXT_PATH}` is empty**, set `PARENT_MODE = STANDALONE` and continue to Step 2.

- **If `{CONTEXT_PATH}` is non-empty**, inspect its contents and set `PARENT_MODE`:

  | What exists in `{CONTEXT_PATH}` | `PARENT_MODE` | Meaning |
  |----------------------------------|---------------|---------|
  | `feature-detail/` folder with at least one `.md` file | `FEATURE` | Parent is a Feature work item |
  | `feature-list.md` | `EPIC` | Parent is an Epic work item |
  | Neither | — | Stop (see below) |

  - **If neither exists**, stop and tell the user:

    > The parent work item has no artifacts that can drive user story generation.
    > - If the parent is a **Feature**: run `/draft feature-detail` on it first.
    > - If the parent is an **Epic**: run `/draft feature-list` on it first.

Record `PARENT_MODE` before continuing to Step 2.

---

## Step 2 — Resolve feature scope

### If `PARENT_MODE = STANDALONE`

There is no parent work item. The scope comes from the work item itself.

Read the active work item entry from `docs/manifast.yaml` (match by `{MWI_PATH}`). Extract:
- `title` → use as `SELECTED_FEATURE_NAME`
- `description` → use as the primary narrative for story derivation

Set:
```
PARENT_MODE           = STANDALONE
SELECTED_FEATURE_ID   = (none)
SELECTED_FEATURE_NAME = {title from manifast.yaml}
FEATURE_DETAIL_PATH   = (empty)
```

If `LOCAL_WIKI = true`, the wiki pages read in Step 3 will enrich the stories. If `LOCAL_WIKI = false`, stories will be derived exclusively from the work item description — warn the user:

> No ingested sources found. Stories will be based solely on the work item description. Run `/ingest` to add local sources for richer output.

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
run /ingest and /draft feature-detail on it, then return here.

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

### If `PARENT_MODE = STANDALONE` (work item description is the primary source)

The work item description (extracted in Step 2) is the **primary source**.

**If `LOCAL_WIKI = true`**, also read:

1. `docs/wiki/overview.md` — global synthesis (read directly)
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
3. All `concepts/` and `entities/` pages listed in `{OUTPUT_PATH}index.md`

From the description and wiki, extract:
- **Personas** — who is affected by this demand
- **Behaviors** — what the system or user must do
- **Business rules** — constraints or validations mentioned

### If `PARENT_MODE = FEATURE` (feature-detail is the primary source)

Read in this order:

1. `FEATURE_DETAIL_PATH` — **primary source**. Contains pre-analysed personas, behaviors, business rules, entity interactions, and a proposed story breakdown.

**If `LOCAL_WIKI = true`**, also read:

2. `docs/wiki/overview.md` — global synthesis (read directly)
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`

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

2. `docs/wiki/overview.md` — global synthesis (read directly)
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
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
{If PARENT_MODE = STANDALONE}
For "{SELECTED_FEATURE_NAME}", I propose {N} user stories:

{Otherwise}
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

## Step 5 — Lock the output language

Before writing any file, resolve and declare the language that will be used throughout:

1. Read `{LANGUAGE}` from the parameters passed by the orchestrator.
2. Map to the expected locale:
   - `pt-BR` → Brazilian Portuguese
   - `en` → English
   - anything else → English (and warn the user)
3. If `{LANGUAGE}` is not set or is empty, default to `en` and warn: "LANGUAGE was not set — defaulting to English."
4. State the resolved language explicitly before proceeding:

```
Output language locked: {resolved language} ({LANGUAGE})
All artifact content, headings, and messages will be written in this language.
```

**Do not begin writing any file until this step is complete.** This prevents language drift across multiple generated files.

---

## Step 6 — Write one file per user story

For each story in `STORIES`, create the file using the naming rule for the active mode:

| `PARENT_MODE` | File path |
|---------------|-----------|
| `FEATURE` or `EPIC` | `{OUTPUT_PATH}artifacts/user-stories/{SELECTED_FEATURE_ID}-{story.id}-{story.slug}.md` |
| `STANDALONE` | `{OUTPUT_PATH}artifacts/user-stories/{story.id}-{story.slug}.md` |

Example (FEATURE): `output/artifacts/user-stories/F-001-US-001-cadastrar-produto-catalogo.md`
Example (STANDALONE): `output/artifacts/user-stories/US-001-corrigir-label-botao.md`

Use the template from `template.md` in this same skill directory. Fill all placeholders and preserve the section order.

Optional quality check: run `scripts/validate.sh <generated-story-file.md>` for each generated story file.


Write all stories before moving to Step 6. If a story has a `> [!gap]` confirmed by the user as acceptable, write the file with the gap note included.

---
## Step 7 — Update navigation files

**`{OUTPUT_PATH}artifacts/index.md`** — create if it does not exist, then add or update user stories entries using the same naming rule from Step 6:

```markdown
{FEATURE/EPIC mode}
- [[user-stories/{SELECTED_FEATURE_ID}-US-001-{slug}]] — {story.action short title} (generated YYYY-MM-DD)

{STANDALONE mode}
- [[user-stories/US-001-{slug}]] — {story.action short title} (generated YYYY-MM-DD)
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

## Step 8 — Close the loop

```
{FEATURE/EPIC mode}
Done. {N} user stories generated for feature {SELECTED_FEATURE_ID} — {SELECTED_FEATURE_NAME}.

Files written to {OUTPUT_PATH}artifacts/user-stories/:
  {SELECTED_FEATURE_ID}-US-001-{slug}.md — {short title}
  {SELECTED_FEATURE_ID}-US-002-{slug}.md — {short title}
  ...

{STANDALONE mode}
Done. {N} user stories generated for "{SELECTED_FEATURE_NAME}" (standalone).

Files written to {OUTPUT_PATH}artifacts/user-stories/:
  US-001-{slug}.md — {short title}
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
- **`PARENT_MODE = STANDALONE`:** work item description is the primary source; no parent artifacts are read. File names omit the feature ID prefix (`US-001-{slug}.md`). Warn the user if `LOCAL_WIKI = false`.
- **Never write files before Step 4 is confirmed.** The decomposition must be approved before any file is created.
- **Never skip Step 5.** Language must be locked before any file is written — never assume or infer the language mid-generation.
- **One story per file.** Never merge multiple stories into one file.
- **File naming is fixed:** `{feature_id}-{story_id}-{slug}.md` inside `artifacts/user-stories/`. Do not deviate.
- **Never invent acceptance criteria not backed by the wiki.** Use `> [!gap]` for missing criteria.
- **Gherkin must be syntactically valid.** Each scenario must have Given / When / Then in that order. Avoid "And" as the first keyword.
- **One scenario per distinct behavior.** Do not combine multiple behaviors into one scenario.
- **Never write to source/concept/entity pages.** User story generation is read-only on the wiki.
- **This skill is Tactical-only.** If invoked for Strategic or Product, stop immediately.
- **Business rules must be individually sourced.** Never write a rule without a [[wikilink]] to the page it came from.
