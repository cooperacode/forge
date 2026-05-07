---
name: feature-detail
description: "Generate a Feature Detail artifact for the active Feature work item. Uses the feature itself as scope and optionally enriches it with parent Epic artifacts and local wiki context."
---

# Skill: Feature Detail

You were invoked by the orchestrator because the user wants to detail the active Feature work item. Your job is to analyze that feature in depth across the available wiki and upstream context, then produce a detailed specification with a proposed user story breakdown.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_ID`, `WORK_ITEM_PATH`, `WORK_ITEM_TITLE`, `WORK_ITEM_TYPE`, `WORK_ITEM_TAGS`, `CONTEXT_PATH`, and `LANGUAGE` — use those values for all file operations and metadata.

This skill is for **Product-level Feature work items only**. If `{WORK_ITEM_TYPE}` is not `Feature`, tell the user this artifact is not applicable for the active work item and stop.

Follow every step in order.

> ⚠️ **Language lock:** Write the entire artifact — content, headings, table values, and all messages — in `{LANGUAGE}`. Source documents may be in a different language; never mirror them. This constraint is active from the first character to the last, throughout every step.

---

## Step 1 — Detect parent mode

Attempt to read `{OUTPUT_PATH}index.md` and set `LOCAL_WIKI`:

| `{OUTPUT_PATH}index.md` | Action |
|--------------------------|--------|
| exists and has content   | Set `LOCAL_WIKI = true`. Note the total number of pages indexed. |
| missing or empty         | Set `LOCAL_WIKI = false`. The skill will rely on the active work item description and any available parent artifacts. |

`{CONTEXT_PATH}` points to the **direct parent** work item's `output/artifacts/`. What is available there determines the parent mode. Check `{CONTEXT_PATH}`:

- **If `{CONTEXT_PATH}` is empty**, set `PARENT_MODE = STANDALONE` and continue to Step 2.

- **If `{CONTEXT_PATH}` is non-empty**, inspect its contents:

  | What exists in `{CONTEXT_PATH}` | `PARENT_MODE` | Meaning |
  |----------------------------------|---------------|---------|
  | `feature-list.md` | `EPIC` | Parent is an Epic work item with product context |
  | Anything else but no `feature-list.md` | — | Stop (see below) |

  - **If `feature-list.md` does not exist**, stop and tell the user:

    > The parent work item has no `feature-list.md`, so it cannot provide Product context for this Feature.
    > Switch to the parent Epic and run `/draft feature-list` first. To work without an Epic, create a standalone Feature with `/focus`.

  - **If it exists**, set `PARENT_MODE = EPIC` and continue to Step 2.

Record `PARENT_MODE` before continuing.

## Step 2 — Resolve feature scope from the active work item

Read `docs/manifast.yaml` and find the item whose `path` matches `{WORK_ITEM_PATH}`.

- If no item matches `{WORK_ITEM_PATH}`, stop and tell the user:

  > The active Feature work item could not be found in `docs/manifast.yaml`. Run `/focus` again to restore the active context.

Extract from the matched item:

```
SELECTED_FEATURE_NAME = {title}
SELECTED_FEATURE_DESC = {description}
SELECTED_FEATURE_SLUG = {kebab-case short name, ASCII only}
ACTIVE_WORK_ITEM_SOURCE = [[docs/manifast.yaml]]
```

Resolve `SELECTED_FEATURE_ID` in this order:

1. If `tags` contains a token matching `F-[A-Za-z0-9-]+`, use the first match and normalize it to uppercase.
2. Otherwise, derive it deterministically from `{WORK_ITEM_ID}` as `F-{ASCII-UPPER-KEBAB of WORK_ITEM_ID}` and warn the user:

   > No explicit feature ID tag was found. Using derived feature ID: `{SELECTED_FEATURE_ID}`.

If `PARENT_MODE = EPIC`, read `{CONTEXT_PATH}feature-list.md` in full and extract all feature rows: `ID`, name, description, beneficiary, priority, and dependencies.

Try to match the active feature against the feature list using this order:

1. Row `ID` equals `SELECTED_FEATURE_ID`
2. Row feature name equals `SELECTED_FEATURE_NAME` (case-insensitive)

If a match is found, record:

```
PARENT_FEATURE_MATCH = true
PARENT_FEATURE_PRIORITY = {priority}
PARENT_FEATURE_DEPENDENCIES = {dependencies}
PARENT_FEATURE_BENEFICIARY = {beneficiary}
```

If no match is found, set `PARENT_FEATURE_MATCH = false` and warn the user:

> This Feature is not present in the parent Epic's `feature-list.md`. Continuing with the active work item description as the primary scope and using the Epic artifacts only as supporting context.

Check whether `{OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md` already exists. If it does, warn the user:

> A detail for `{SELECTED_FEATURE_ID}` already exists. Continuing will overwrite it. Proceed?

Wait for confirmation before continuing.

---

## Step 3 — Read all wiki pages

### If `PARENT_MODE = STANDALONE`

The active work item description is the **primary source**.

When a statement comes directly from the active work item entry rather than the local wiki, cite `[[docs/manifast.yaml]]`.

If `LOCAL_WIKI = false`, warn the user:

> No ingested sources found for this work item. The feature detail will be based solely on the work item description.

**If `LOCAL_WIKI = true`**, also read:

1. `docs/wiki/overview.md` — global synthesis (read directly)
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
3. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
4. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

### If `PARENT_MODE = EPIC`

The active work item description remains the **primary source**. The parent Epic artifacts provide upstream product context.

When a statement comes directly from the active work item entry rather than the local wiki or parent artifacts, cite `[[docs/manifast.yaml]]`.

If `LOCAL_WIKI = false`, warn the user:

> No ingested sources found for this work item. The feature detail will rely on the work item description and the parent Epic artifacts only.

Read in this order:

1. `{CONTEXT_PATH}feature-list.md` (already read in Step 2)

**If `LOCAL_WIKI = true`**, also read:

2. `docs/wiki/overview.md` — global synthesis (read directly)
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
4. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
5. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

6. Any other files present in `{CONTEXT_PATH}`:
   - `requirements.md` — functional or product constraints that shape the feature; carry them into the business rules and acceptance criteria sections.
   - `der.md` — canonical entity names; use them verbatim in the entity interactions section.
   - `adr/` and `diagrams/` — use them only when they materially clarify dependencies, data flow, or implementation constraints.
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

## Step 6 — Write the feature detail artifact

Create `{OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md`.

Use the template from `template.md` in this same skill directory. Fill all placeholders, preserve the section order, and do not add, remove, or rename headings outside the template.

Keep the INVEST guidance applied in the `Proposed User Story Breakdown` section.

Run `scripts/validate.sh {OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md`. If validation fails, fix the artifact until it passes. Do not update navigation files or report success before validation passes.


---
## Step 7 — Update navigation files

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

## Step 8 — Close the loop

```
Done. Feature detail generated at {OUTPUT_PATH}artifacts/feature-detail/{SELECTED_FEATURE_ID}-{SELECTED_FEATURE_SLUG}.md.

Personas: N
Business rules: N
Entities touched: N
Proposed user stories: N (ready to generate with `/draft user-story` at the Tactical level)
Gaps flagged: N
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **This skill is for Product-level `Feature` work items only.** If the active work item is not a Feature, stop immediately.
- **Always detect `PARENT_MODE` in Step 1 before doing anything else.** The mode determines whether Epic artifacts are available.
- **The active work item is the authoritative feature scope.** Never ask the user to select a different feature from the parent's `feature-list.md`.
- **If a parent Epic exists, `feature-list.md` is required.** Without it, stop and ask the user to generate the parent's feature list first or create a standalone Feature with `/focus`.
- **If no explicit feature ID tag exists, derive `SELECTED_FEATURE_ID` deterministically from `{WORK_ITEM_ID}` and warn the user.** Never leave `feature_id` blank.
- **Never write files before Step 4 is confirmed.** The analysis must be approved first.
- **Never skip Step 5.** Language must be locked before any file is written — never assume or infer the language mid-generation.
- **File path is fixed:** `artifacts/feature-detail/{feature_id}-{slug}.md`. Do not deviate.
- **Never invent behaviors not present in the available sources.** Use `> [!gap]` for anything inferred or underspecified.
- **Business rules must be individually sourced.** Never write a rule without a [[wikilink]].
- **User story breakdown is a proposal, not a commitment.** Stories are generated later at the Tactical level — this breakdown is guidance, not a locked contract.
- **Apply INVEST to every proposed story.** Flag violations explicitly in the INVEST Notes column: split stories that violate **S** (too large for one sprint); mark as `> [!gap]` stories that violate **E** or **T** (cannot estimate or verify due to missing wiki detail); note explicit dependencies for stories that violate **I**. Never write a story that fails **V** — if no persona benefits, it is a technical task, not a user story.
- **Never write to source/concept/entity pages.** This skill is read-only on the wiki.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For facts derived directly from the active work item entry, use `[[docs/manifast.yaml]]`. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path. Never use short names or computed relative paths for cross-work-item references.
